using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Threading;
using Windows.ApplicationModel;
using Windows.ApplicationModel.AppService;
using Windows.Foundation.Collections;

namespace Blackhole_WPF
{
    /// <summary>
    /// Interaction logic for App.xaml
    /// </summary>
    public partial class App : Application
    {
        static AppServiceConnection connection;

        /// <summary>
        ///  Enable to see verbose output
        /// </summary>
        bool debug_enabled = true;

        // Allocate erasure patterns only once for efficiency
        static int write_size = 1024 * 4;
        static byte[] byte_pattern = new byte[write_size];
        static byte[] pattern = { 0xc0, 0xff, 0xee };

        public App() : base()
        {
            // if unit testing and starting up as debug project, you need to disable the service calls
            InitializeAppServiceConnection();

            // initialize pattern once 
            // per Stackoverflow this is the most efficient method, it lets the JIT compiler optimize as it sees fit
            // rather than try to use any fancier later version operators (like lambdas)
            for (int i = 0; i < write_size; i++)
            {
                byte_pattern[i] = pattern[i % pattern.Length];
                //var debug = String.Format("#byte[{0}] = {1:X}", i, byte_pattern[i]);
                //Debug.WriteLine(debug);
            }

            //test_debugging();
        }

        private void test_debugging()
        {
            //string path = "E:\\Program Files (x86)";
            string path = "E:\\Users\\Jon\\Downloads\\acrobat9";
            //string path = "J:\\Python27\\include";

            Debug.WriteLine("eraser_gun on path=" + path);
            eraser_gun(path, null);

            Application.Current.Shutdown();
        }

        private async Task eraser_gun(string path, AppServiceRequestReceivedEventArgs args)
        {
            ValueSet request_response = new ValueSet();
            request_response.Add("Status", "");
            request_response.Add("Detail", "");
            request_response.Add("File", "");

            try
            {
                // check if folder, or if it's a single dropped file
                if (File.Exists(path))
                {
                    if (debug_enabled)
                    {
                        request_response["Status"] = "file.exists";
                        Debug.WriteLine("file.exists");
                        if (connection != null) await connection.SendMessageAsync(request_response);
                    }                    
                    await secure_file_erase(path, args);
                }
                else
                {
                    if (debug_enabled)
                    {
                        request_response["Status"] = "pre list_files";
                        Debug.WriteLine("pre list_files");
                        if (connection != null) await connection.SendMessageAsync(request_response);
                    }

                    var files = list_files(path);
                    request_response["Status"] = "post list_files -- found " + files.Count + " files";
                    if (connection != null) await connection.SendMessageAsync(request_response);

                    foreach (string file in files)
                    {
                        try
                        {
                            Debug.WriteLine("erasing => " + file);
                            await secure_file_erase(file, args);
                        }
                        catch (UnauthorizedAccessException ae)
                        {
                            // to be expected on many files
                            Debug.WriteLine("access violation on this file! => " + ae.ToString());
                            MessageBox.Show("access violation on this file! => " + ae.ToString());
                        }
                        catch (Exception ee)
                        {
                            request_response["Status"] = "Warning";
                            request_response["Detail"] = ee.ToString();
                            request_response["File"] = file;
                            if (connection != null) await connection.SendMessageAsync(request_response);
                        }
                    }

                    // when all files are done being deleted, we can go back and erase the folder trees
                    Debug.WriteLine("Directory.Delete");
                    Directory.Delete(path, true); 
                }                
                
                request_response["Status"] = "Complete";
                if (connection != null) await connection.SendMessageAsync(request_response);
                
            }
            catch (Exception e)
            {
                MessageBox.Show("Unexpected exception on the outer loop, on path=" + path + "  exception=> " + e.ToString());

                // Send a message back so the UWP app can respond accordingly
                request_response["Status"] = "Exception";
                request_response["Detail"] = e.ToString();
                if (connection != null) await connection.SendMessageAsync(request_response);
            }            
        }

        private async Task secure_file_erase(string file_path, AppServiceRequestReceivedEventArgs args)
        {
            try
            {
                // TODO -- could upgrade this to use pseudo-randomized arrays, but not necessary
                // slightly larger pattern increase speed (by decreasing excessive disk write calls)
                // can play with this on different file sizes as needed
                UInt64 byte_offset = 0;

                using (FileStream file = File.OpenWrite(file_path))
                {                    
                    Debug.WriteLine("Writing to file size -- " + file.Length + " using pattern size = " + byte_pattern.Length);

                    while (byte_offset < (UInt64)file.Length)
                    {
                        int length_to_write = byte_pattern.Length;

                        // Check for remainder case
                        if (byte_offset + (UInt64)byte_pattern.Length >= (UInt64)file.Length)
                        {
                            length_to_write = (int)((UInt64)file.Length - byte_offset);
                        }

                        // per the API method "Write", this call advances the pointer for us so DONT pass the offset to offset                        
                        file.Write(byte_pattern, 0, length_to_write);                        

                        byte_offset += (UInt64)byte_pattern.Length;

                        ValueSet request = new ValueSet();
                        request.Add("File", file.Name);
                        request.Add("Status", "Writing");
                        request.Add("Written", (UInt64)byte_pattern.Length);

                        if (connection != null)
                        {
                            var reply = await connection.SendMessageAsync(request);
                        }
                    }
                    //Debug.WriteLine("Writing done, offset = " + byte_offset);

                    //file.Close(); // per API, don't need this, rather just let the stream be disposed
                }
                
                // Mangle the creation time to further obscure this file
                File.SetCreationTime(file_path, DateTime.Now);
                File.Delete(file_path);

                {
                    ValueSet request = new ValueSet();
                    request.Add("File", file_path);
                    request.Add("Status", "Erased");
                    Debug.WriteLine("file_path=" + file_path + " Erased");
                    if (connection != null)
                    {
                        var reply = await connection.SendMessageAsync(request);
                    }
                }
            }
            catch (Exception e)
            {
                Debug.WriteLine("argh we died -- " + e.ToString());
            }
        }

        static int list_files_recursion_count = 0;

        // Recursively search files in every subdirectory ignoring access errors
        List<string> list_files(string path)
        {
            List<string> files = new List<string>();
            list_files_recursion_count++;

            Debug.WriteLine("list_files leve=" + list_files_recursion_count);

            // add the files in the current directory
            try
            {
                string[] entries = Directory.GetFiles(path);
                Debug.WriteLine("Dir.GetFiles #1");

                foreach (string entry in entries)
                {
                    files.Add(System.IO.Path.Combine(path, entry));
                    // forcibly remove any and all read-only flags
                    File.SetAttributes(entry, FileAttributes.Normal);
                }
                // and the directory
                var di = new DirectoryInfo(path);
                di.Attributes &= ~FileAttributes.ReadOnly;

                Debug.WriteLine("foreach GetFiles #1");
            }
            catch
            {
                // an exception in directory.getfiles is not recoverable: the directory is not accessible
            }

            // follow the subdirectories
            try
            {
                string[] entries = Directory.GetDirectories(path);
                Debug.WriteLine("Dir.GetDirectories #1");

                foreach (string entry in entries)
                {
                    string current_path = System.IO.Path.Combine(path, entry);
                    List<string> files_in_subdir = list_files(current_path);

                    foreach (string current_file in files_in_subdir)
                        files.Add(current_file);

                    Debug.WriteLine("foreach current_path=" + current_path);
                }

                Debug.WriteLine("foreach entry in entries ");
            }
            catch
            {
                // an exception in directory.getdirectories is not recoverable: the directory is not accessible
            }

            list_files_recursion_count--;
            return files;

            // a few future ideas, if we choose to go further
            //var files = Directory.EnumerateFiles(path, "*.*", SearchOption.AllDirectories);
            //.Where(s => s.EndsWith(".mp3") || s.EndsWith(".jpg"));
            //Debug.WriteLine("files => " + files.Count());
        }

        private async void InitializeAppServiceConnection()
        {            
            connection = new AppServiceConnection();
            connection.AppServiceName = "BlackholeWPF";
            connection.PackageFamilyName = Package.Current.Id.FamilyName;
            connection.RequestReceived += Connection_RequestReceived;
            connection.ServiceClosed += Connection_ServiceClosed;

            AppServiceConnectionStatus status = await connection.OpenAsync();
            if (status != AppServiceConnectionStatus.Success)
            {
                // something went wrong
                MessageBox.Show("WPF side ERROR status = " + status.ToString());
            }
            else
            {
                // Successful connection between UWP and WPF
                //MessageBox.Show("WPF side status = " + status.ToString());
            }
        }

        /// <summary>
        /// Handles the event when the desktop process receives a request from the UWP app
        /// </summary>
        private async void Connection_RequestReceived(AppServiceConnection sender, AppServiceRequestReceivedEventArgs args)
        {
            // Get a deferral because we use an awaitable API below to respond to the message
            // and we don't want this call to get canceled while we are waiting.
            var messageDeferral = args.GetDeferral();

            // retrive the reg key name from the ValueSet in the request
            string key = args.Request.Message["folder_path"] as string;
            int index = key.IndexOf('\\');
            if (index > 0)
            {
                // add escapes to the path before we try to use it
                string path = key.Replace(@"\", @"\\"); ;                

                ValueSet request = new ValueSet();
                request.Add("Status", "Starting Erasure");
                var response = await args.Request.SendResponseAsync(request);

                Task.Run(() => { eraser_gun(path, args); });
                messageDeferral.Complete();
            }
            else
            {
                messageDeferral.Complete();
            }

            // Complete the deferral so that the platform knows that we're done responding to the app service call.
            // Note for error handling: this must be called even if SendResponseAsync() throws an exception.
            //messageDeferral.Complete();
        }

        /// <summary>
        /// Handles the event when the app service connection is closed
        /// </summary>
        private void Connection_ServiceClosed(AppServiceConnection sender, AppServiceClosedEventArgs args)
        {
            // connection to the UWP lost, so we shut down the desktop process
            Dispatcher.BeginInvoke(DispatcherPriority.Normal, new Action(() =>
            {
                Application.Current.Shutdown();
            }));
        }
    }
}
