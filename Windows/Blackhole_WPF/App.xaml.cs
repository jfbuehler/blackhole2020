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
            InitializeAppServiceConnection();
            //test_debugging();
        }

        private void test_debugging()
        {
            //string path = "F:\\Software\\Guitar Pro 7.0.2 Build 102";
            //string path = "E:\\Games\\The Outer Worlds";
            //string path = "E:\\Program Files (x86)";
            string path = "E:\\Program Files (x86)\\Adobe\\Acrobat Reader DC\\Reader\\AcroApp\\ENU";

            eraser_gun(path);

            Application.Current.Shutdown();
        }

        private void eraser_gun(string path)
        {

            //var files = Directory.EnumerateFiles(path, "*.*", SearchOption.AllDirectories);
            //.Where(s => s.EndsWith(".mp3") || s.EndsWith(".jpg"));
            //Debug.WriteLine("files => " + files.Count());

            // try setting options to help with the constant UnauthorizedAccess exceptions we must expect

            // we need to handle bad accesses while we do this
            bool working_to_erase = true;

            //foreach (string file in files)
            //{
            //    try
            //    {
            //        Debug.WriteLine("erasing => " + file);
            //        //File.Delete(file);
            //    }
            //    catch (UnauthorizedAccessException ae)
            //    {
            //        // to be expected on many files
            //        Debug.WriteLine("access violation on this file! => " + ae.ToString());
            //    }

            //}

            //while (working_to_erase)
            //{
            //    try
            //    {
            //        foreach (string file in files)
            //        {
            //            Debug.WriteLine("erasing => " + file);
            //            //File.Delete(file);
            //        }
            //    }
            //    catch (UnauthorizedAccessException ae)
            //    {
            //        // to be expected on many files
            //        Debug.WriteLine("access violation on this file! => " + ae.ToString());
            //    }
            //}


            // this function is resilient to folders with access exceptions!!! fuck yeah.
            var files = list_files(path);

            foreach (string file in files)
            {
                try
                {
                    Debug.WriteLine("erasing => " + file);
                    File.Delete(file);
                }
                catch (UnauthorizedAccessException ae)
                {
                    // to be expected on many files
                    Debug.WriteLine("access violation on this file! => " + ae.ToString());
                    MessageBox.Show("access violation on this file! => " + ae.ToString());
                }

            }
        }

        // search file in every subdirectory ignoring access errors
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
        }

        // MainWindow.xaml.cs in WPF project
        private async void InitializeAppServiceConnection()
        {
            connection = new AppServiceConnection();
            connection.AppServiceName = "SampleInteropService";
            connection.PackageFamilyName = Package.Current.Id.FamilyName;
            connection.RequestReceived += Connection_RequestReceived;
            connection.ServiceClosed += Connection_ServiceClosed;

            AppServiceConnectionStatus status = await connection.OpenAsync();
            if (status != AppServiceConnectionStatus.Success)
            {
                // something went wrong ...
                MessageBox.Show("WPF side status = " + status.ToString());
                //this.IsEnabled = false;
            }
            else
            {
                MessageBox.Show("WPF side status = " + status.ToString());
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
                MessageBox.Show(path);

                //eraser_gun(path);                
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
