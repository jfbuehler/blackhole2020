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

        public App() : base()
        {
            // if unit testing and starting up as debug project, you need to disable the service calls
            InitializeAppServiceConnection();

            //test_debugging();
        }

        private void test_debugging()
        {
            //string path = "E:\\Program Files (x86)";
            //string path = "E:\\Program Files (x86)\\Adobe\\Acrobat Reader DC\\Reader\\AcroApp\\ENU";
            string path = "J:\\Python27\\Lib";

            eraser_gun(path);

            Application.Current.Shutdown();
        }

        private void eraser_gun(string path)
        {

            bool working_to_erase = true;            

            try
            {
                // check if folder, or if it's a single dropped file
                if (File.Exists(path))
                {
                    secure_file_erase(path);
                }
                else
                {
                    // this function appears resilient to folders with access exceptions
                    var files = list_files(path);

                    foreach (string file in files)
                    {
                        try
                        {
                            Debug.WriteLine("erasing => " + file);
                            secure_file_erase(file);
                        }
                        catch (UnauthorizedAccessException ae)
                        {
                            // to be expected on many files
                            Debug.WriteLine("access violation on this file! => " + ae.ToString());
                            MessageBox.Show("access violation on this file! => " + ae.ToString());
                        }
                    }

                    // when all files are done being deleted, we can go back and erase the folder trees
                    Directory.Delete(path, true);
                }
            }
            catch (Exception e)
            {
                MessageBox.Show("Unexpected exception on the outer loop => " + e.ToString());
            }
            
        }

        private void secure_file_erase(string file_path)
        {
            try
            {
                // TODO -- could upgrade this to use pseudo-randomized arrays, but not necessary
                // slightly larger pattern increase speed (by decreasing excessive disk write calls)
                // can play with this on different file sizes as needed
                byte[] byte_pattern = { 0xc0, 0xff, 0xee, 0xc0, 0xff, 0xee, 0xc0, 0xff, 0xee, 0xc0, 0xff, 0xee, 0xc0, 0xff, 0xee, 0xc0, 0xff, 0xee, 0xc0, 0xff, 0xee };
                int byte_offset = 0;
                                
                using (FileStream file = File.OpenWrite(file_path))
                {
                    //Debug.WriteLine("Writing to file size -- " + file_basic_props.Size + " using pattern size = " + byte_pattern.Length);
                    while (byte_offset < file.Length)
                    {
                        // per the API method "Write", this call advances the pointer for us so DONT pass the offset to offset                        
                        file.Write(byte_pattern, 0, byte_pattern.Length);

                        int byte_mod = byte_offset % (byte_pattern.Length * 10000); // ~210kb
                        //if (byte_mod == byte_pattern.Length)
                        //    Debug.WriteLine("Writing file [" + file.Name + "] offset -- " + byte_offset + " byte_mod = " + byte_mod); // careful, this slows the method down a lot to have on

                        byte_offset += byte_pattern.Length;
                    }
                    //Debug.WriteLine("Writing done, offset = " + byte_offset);

                    //file.Close(); // per API, don't need this, rather just let the stream be disposed
                }
                
                // Mangle the creation time to further obscure this file
                File.SetCreationTime(file_path, DateTime.Now);
                File.Delete(file_path);
            }
            catch (Exception e)
            {
                Debug.WriteLine("argh we died -- " + e.ToString());
            }
        }

        // Recursively search files in every subdirectory ignoring access errors
        static List<string> list_files(string path)
        {
            List<string> files = new List<string>();

            // add the files in the current directory
            try
            {
                string[] entries = Directory.GetFiles(path);

                foreach (string entry in entries)
                    files.Add(System.IO.Path.Combine(path, entry));
            }
            catch
            {
                // an exception in directory.getfiles is not recoverable: the directory is not accessible
            }

            // follow the subdirectories
            try
            {
                string[] entries = Directory.GetDirectories(path);

                foreach (string entry in entries)
                {
                    string current_path = System.IO.Path.Combine(path, entry);
                    List<string> files_in_subdir = list_files(current_path);

                    foreach (string current_file in files_in_subdir)
                        files.Add(current_file);
                }
            }
            catch
            {
                // an exception in directory.getdirectories is not recoverable: the directory is not accessible
            }

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
            // retrive the reg key name from the ValueSet in the request
            string key = args.Request.Message["folder_path"] as string;
            int index = key.IndexOf('\\');
            if (index > 0)
            {
                // add escapes to the path before we try to use it
                string path = key.Replace(@"\", @"\\"); ;
                //MessageBox.Show(path);

                eraser_gun(path);

                // Sample method to reply with two-way comms
                ValueSet request = new ValueSet();
                //request.Add("D1", d1);
                //request.Add("D2", d2);
                AppServiceResponse response = await connection.SendMessageAsync(request);
                double result = (double)response.Message["RESULT"];
                
            }            
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
