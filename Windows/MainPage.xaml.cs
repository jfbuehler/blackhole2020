using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.WindowsRuntime;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Toolkit.Uwp.Helpers;
using Windows.ApplicationModel;
using Windows.ApplicationModel.DataTransfer;
using Windows.ApplicationModel.AppService;
using Windows.Foundation;
using Windows.Foundation.Collections;
using Windows.Foundation.Metadata;
using Windows.Storage;
using Windows.Storage.FileProperties;
using Windows.Storage.Search;
using Windows.UI.Core;
using Windows.UI.ViewManagement;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Controls.Primitives;
using Windows.UI.Xaml.Data;
using Windows.UI.Xaml.Input;
using Windows.UI.Xaml.Media;
using Windows.UI.Xaml.Navigation;

// these did not work
//using System.Security.AccessControl;
//using System.Security.Principal;

namespace Blackhole
{
    /// <summary>
    /// An empty page that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class MainPage : Page
    {
        // use this to keep a copy of the UI thread dispatcher
        internal static MainPage m_page = null;

        static ObFileList FilesObvCollection;

        /// <summary>
        /// Easier to just hard code this based on the JSON animation time
        /// </summary>
        static double file_animation_time_secs = 6.16 + 1;

        /// <summary>
        /// Keep track of whether or not files are being erased actively
        /// </summary>
        static bool files_erasing = false;

        static int num_erase_tasks_running = 0;

        public MainPage()
        {
            this.InitializeComponent();
            m_page = this;
            FilesObvCollection = this.Resources["FilesObvCollection"] as ObFileList;

            ApplicationView.PreferredLaunchViewSize = new Size(1200, 1000);
            ApplicationView.PreferredLaunchWindowingMode = ApplicationViewWindowingMode.PreferredLaunchViewSize;

            // Project In Work -- has some issues where the package crashes still...
            //launch_wpf();  // Must run with the Package as the Startup Project if this is enabled
        }

        /// <summary>
        /// An example of how to use WPF required resources inside UWP
        /// </summary>
        private async void launch_wpf()
        {
            if (ApiInformation.IsApiContractPresent("Windows.ApplicationModel.FullTrustAppContract", 1, 0))
            {
                await FullTrustProcessLauncher.LaunchFullTrustProcessForCurrentAppAsync();
            }
        }

        /// <summary>
        /// Main method for handling incoming file / folders
        /// </summary>
        private async void Page_Drop(object sender, DragEventArgs e)
        {
            //base.OnDragOver(e);
            //Console.WriteLine("Drop detected!!!");

            // the .net 4.5 method
            //string[] raw_files = (string[])e.Data.GetData(DataFormats.FileDrop, false);            

            // the body is getting a bit long but until we know how to handle the file access issues, don't refactor yet...

            try
            {
                if (num_erase_tasks_running > 0)
                {
                    return; // need to handle terminating the running operation first
                }

                num_erase_tasks_running += 1;
                Debug.WriteLine("num_erase_tasks_running = " + num_erase_tasks_running);

                // TODO -- support when a user drops new files/folders on top of an already running deletion task...
                files_erasing = false;

                if (e.DataView.Contains(StandardDataFormats.StorageItems))
                {
                    // consider this meaning we're deleting now
                    files_erasing = true;
                    
                    start_file_animation(1); // we don't know the file count yet, so pass (1)

                    var items = await e.DataView.GetStorageItemsAsync();
                    if (items.Count > 0)
                    {
                        // when the user drops, it can be 1 of 3 cases
                        // 1) a single file
                        // 2) a single folder
                        // 3) a combo of the two, files and folders

                        foreach (var item in items )
                        {
                            // check if its a folder
                            var folder = item as StorageFolder;
                            if (folder == null)
                            {
                                // it's a file
                                StorageFile file = item as StorageFile;
                                Debug.WriteLine("It's a file => " + file.Path);

                                //
                                // try to erase it
                                //
                                await Task.Run(() => erase_file(file.Path));
                            }
                            else
                            {
                                // dropped folder
                                Debug.WriteLine("It's a folder => " + folder.Path);

                                // option 1)
                                // jfb -- unfortunately, using the StorageFile methods to query the system is insanely slow
                                // testing on a folder with 14,000 files, the default behavior is to take MINUTES to return
                                // not sure at this time (march 2022) why this API is so borked. UWP makes file access kind of suck is my current hypothesis =\ 
                                // PS; its so easy on MacOS ;)
                                //var files = await fast_file_query(folder);

                                // option 2) is to enumate using System.IO, which is super fast but has endless access exception issues 
                                // unfortunately, I don't think this can be solved via UWP -- there's no way to request elevated permissions in the framework
                                // of course, maybe I missed something but nothing so far has worked reliably and so the hypothesis thus far is
                                // UWP is extremely fragile with file system access and should be avoided
                                //var files = list_files(folder.Path);
                                //foreach (var file in files)
                                //{
                                //    await erase_file(file);
                                //}

                                // option 3) -- use the WPF sub-project to do the actual file access and erasure
                                // it's a lot more complex to invoke a WPF application from UWP but all file system access is easy as cake in WPF
                                // TBD
                                // there's still some finicky timing issues with invoking the WPF app + getting it to terminate properly 
                                // But there's a lot to be gained from this method
                                // There are too many file system access issues to handle otherwise

                                // Example: Testing running this application on the C: drive, erasing files across the C: is OK 
                                // Trying to drag/drop files on a secondary drive E: throws constant access exceptions all over the place
                                // Rather than delve this rabbit hole, it seems bailing on UWP for WPF would be the ideal choice for access to the file system permissions
                                // See long running threads like this waiting YEARS for Microsoft to bother updating UWP's terrible performance / access issues 
                                // https://github.com/microsoft/WindowsAppSDK/issues/8

                                // option 4) -- basic workaround supports relatively flat folder structure (just so something works!)
                                var files = await folder.GetFilesAsync();

                                foreach (var file in files)
                                {
                                    await Task.Run(() => erase_file(file.Path));
                                }

                                // not yet -- the folder might have subfolders we didn't get to (and aren't handling yet)
                                //await folder.DeleteAsync();
                                //if (folder != null)
                                //{
                                //    var folder_to_delete = await StorageFolder.GetFolderFromPathAsync(folder.Path);
                                //    await folder_to_delete.DeleteAsync();
                                //}
                                //
                            }
                        }
                    }

                    files_erasing = false;
                    e.Handled = true;
                    
                    //
                    // This is how we would use a WPF process to interact with the file system
                    // I decided not to use it since its rather complex for the purposes of this project
                    // but kept the code around as a cool example of how to implement such functionality if/when desired!
                    //
                    // first -- give time for the background process to wake up, in practice it seemed to take >1 second and I never figured out why
                    //Thread.Sleep(3000);

                    // second -- attempt to send the file path to the WPF process
                    // sometimes getting an "app service unavailable" error so this method can be flaky. but other times it works...so play around with it! 
                    //ValueSet request = new ValueSet();
                    //request.Add("folder_path", input_dir_path.Path);
                    //AppServiceResponse response = await App.Connection.SendMessageAsync(request);

                }
            }
            catch (Exception ee)
            {
                Debug.WriteLine("argh we done died -- " + ee.ToString());
            }

            num_erase_tasks_running -= 1;

            e.Handled = true;
        }

        /// <summary>
        /// Recursively search a file path and provide all the files, subfolders and subfiles in a List object
        /// </summary>
        /// <param name="path">Valid full path to a folder</param>
        /// <returns>List object of whatever the search finds</returns>
        private List<string> list_files(string path)
        {
            List<string> files = new List<string>();

            // add the files in the current directory
            try
            {
                string[] entries = Directory.GetFiles(path);

                foreach (string entry in entries)
                    files.Add(System.IO.Path.Combine(path, entry));
            }
            catch (Exception e)
            {
                // an exception in directory.getfiles is not recoverable: the directory is not accessible
                Debug.WriteLine("Exception in list_files()! -- " + e);
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
            catch (Exception e)
            {
                // an exception in directory.getdirectories is not recoverable: the directory is not accessible
                Debug.WriteLine("Exception in list_files()! -- " + e);
            }

            foreach (var file in files)
                Debug.WriteLine("Found file => " + file);

            return files;
        }

        /// <summary>
        /// Asynchronously delete a file by overwriting it with a fixed pattern, then erasing it
        /// TODO -- upgrade to add a sufficiently pseudo-randomized pattern option
        /// TODO -- pattern writing is too slow, needs improvement in runtime speed
        /// </summary>
        /// <param name="file">Full path to the file to be deleted</param>
        async private Task erase_file(string file_path)
        {
            try
            {
                // TODO -- it would be ideal to upgrade this to use pseudo-randomized arrays
                // if we don't use this Superfast extension, the array creation can take >1 minute for 100+ megabytes .. it's bad all around so avoid that
                //byte[] bytes_to_write = Superfast.InitByteArray(0xee, (int)file_basic_props.Size);

                // Some prelim testing on my 12-core, AMD Ryzen 3 shows using a pattern size of only 6 bytes is brutally slow...
                // it takes multiple seconds to erase a 250,000 byte file. That won't scale at all. 
                //byte[] byte_pattern = { 0xc0, 0xff, 0xee };

                // slightly larger patterns to increase the speed (by decreasing excessive disk write calls)
                // but overall, this method is incredibly slow on even 100kb - 1 megabyte file ranges
                // a much larger bytes per write will be needed on larger files to keep run time quick
                byte[] byte_pattern = { 0xc0, 0xff, 0xee, 0xc0, 0xff, 0xee, 0xc0, 0xff, 0xee, 0xc0, 0xff, 0xee, 0xc0, 0xff, 0xee, 0xc0, 0xff, 0xee, 0xc0, 0xff, 0xee };
                int byte_offset = 0;

                // this is the key to writing in UWP -- we need to ask for the StorageFile from the system to clear the Readonly flags
                var file = await StorageFile.GetFileFromPathAsync(file_path);

                BasicProperties file_basic_props = await file.GetBasicPropertiesAsync();

                using (var stream = await file.OpenStreamForWriteAsync())
                {
                    Debug.WriteLine("Writing to file size -- " + file_basic_props.Size);
                    while (byte_offset < (int)file_basic_props.Size)
                    {
                        // per the API method "Write", this call advances the pointer for us so DONT pass the offset to offset                        
                        stream.Write(byte_pattern, 0, byte_pattern.Length);
                        //Debug.WriteLine("Writing file offset -- " + byte_offset); // careful, this slows the method down a lot to have on

                        byte_offset += byte_pattern.Length;
                    }
                    Debug.WriteLine("Writing done, offset = " + byte_offset);

                    stream.Close();
                }

                await file.DeleteAsync(StorageDeleteOption.PermanentDelete);
            }
            catch (Exception e)
            {
                Debug.WriteLine("argh we done died -- " + e.ToString());
            }
        }

        private void Page_DragOver(object sender, DragEventArgs e)
        {
            // oddly we need to handle this drag-over event in UWP (not my older WPF apps tho) or else drag/drop events won't fire
            //e.AcceptedOperation = Windows.ApplicationModel.DataTransfer.DataPackageOperation.Copy;
            e.AcceptedOperation = DataPackageOperation.Move;
        }

        private void start_file_animation(int num_files)
        {
            // spin up the animation thread
            ThreadPool.QueueUserWorkItem(
               async (workItem) =>
               {
                   // animation loop
                   while (files_erasing)
                   {
                       Debug.WriteLine("Starting an animation loop///");
                       await Dispatcher.RunAsync(Windows.UI.Core.CoreDispatcherPriority.Normal, async () =>
                       {
                           animate_files(num_files);
                       });
                       Debug.WriteLine("Completed an animation loop///");

                       Thread.Sleep((int)(file_animation_time_secs * 1000));
                   }
               });
        }

        /// <summary>
        /// A place to keep the custom file erasing animation logic
        /// </summary>
        private void animate_files(int num_files)
        {
            int files_to_animate = 1;

            // clear the existing destination
            cnvFiles.Children.Clear();

            // determine how many files to animate based on the input num_files
            if (num_files < 50)
                files_to_animate = 10;

            else if (num_files < 500)
                files_to_animate = 10;

            else if (num_files < 5000)
                files_to_animate = 15;

            else if (num_files < 50000)
                files_to_animate = 20;

            else if (num_files < 500000)
                files_to_animate = 25;

            else if (num_files < 1e9)
                files_to_animate = 30;

            for (int i = 0; i < files_to_animate; i++)
            {
                File file_json = new File();
                file_json.parent_container = cnvFiles;

                // generate random position around the radius of the black hole
                var random = new Random();

                var radius = random.Next(200, 250);
                var offset = 50;  // the file animation isn't perfectly centered so we need to re-center manually

                var angle = random.NextDouble() * Math.PI * 2;
                var x = Math.Cos(angle) * radius + radius - offset;
                var y = Math.Sin(angle) * radius + radius - offset;
                //Debug.WriteLine("generating x/y = " + x + " " + y);

                Canvas.SetLeft(file_json, x);
                Canvas.SetTop(file_json, y);
                file_json.Width = 150;
                file_json.Height = 200;

                file_json.SetDirection((int)x + offset, (int)y + offset, (int)cnvFiles.Width, (int)cnvFiles.Height);

                cnvFiles.Children.Add(file_json);
            }
        }
            
        /// <summary>
        /// An attempt at a file query method using the Storage API, but it fails to deliver enough performance
        /// Keep around for analysis
        /// </summary>
        private async Task<IReadOnlyList<StorageFile>> fast_file_query(StorageFolder folderToEnumerate)
        {
            const string dateAccessedProperty = "System.DateAccessed";
            const string fileOwnerProperty = "System.FileOwner";

            //StorageFolder folderToEnumerate = KnownFolders.PicturesLibrary;
            // Check if the folder is indexed before doing anything. 
            //IndexedState folderIndexedState = await folderToEnumerate.GetIndexedStateAsync();
            //if (folderIndexedState == IndexedState.NotIndexed || folderIndexedState == IndexedState.Unknown)
            //{
            //    // Only possible in indexed directories.  
            //    return;
            //}

            QueryOptions query_options = new QueryOptions()
            {
                FolderDepth = FolderDepth.Deep,
                // Filter out all files that have WIP enabled
                ApplicationSearchFilter = "System.Security.EncryptionOwners:[]",
                //IndexerOption = IndexerOption.OnlyUseIndexerAndOptimizeForIndexedProperties
            };

            //picturesQuery.FileTypeFilter.Add(".jpg");

            string[] otherProperties = new string[]
            {
                SystemProperties.GPS.LatitudeDecimal,
                SystemProperties.GPS.LongitudeDecimal
            };

            query_options.SetPropertyPrefetch(PropertyPrefetchOptions.BasicProperties | PropertyPrefetchOptions.ImageProperties,
             otherProperties);
            SortEntry sortOrder = new SortEntry()
            {
                AscendingOrder = true,
                PropertyName = "System.FileName" // FileName property is used as an example. Any property can be used here.  
            };
            query_options.SortOrder.Add(sortOrder);

            // Create the query and get the results 
            uint index = 0;
            const uint stepSize = 100;
            if (!folderToEnumerate.AreQueryOptionsSupported(query_options))
            {
                Debug.WriteLine("Querying for a sort order is not supported in this location");
                query_options.SortOrder.Clear();
            }
            StorageFileQueryResult queryResult = folderToEnumerate.CreateFileQueryWithOptions(query_options);
            IReadOnlyList<StorageFile> files = await queryResult.GetFilesAsync(index, stepSize);
            //IReadOnlyList<StorageFile> files = await queryResult.GetFilesAsync(); // don't use this, it never returns ALL files even on small-ish file counts of 14,000

            Debug.WriteLine("fast_file_query() - Found " + files.Count + " files");
            txtFileCounter.Text = files.Count + " files!";

            foreach (StorageFile file in files)
            {
                Debug.WriteLine("Found file = " + file.Path);
            }

            return files;

            // An idea that did not work -- but worth keeping for analysis
#if false
            while (files.Count != 0) // no limit on index
            {
                foreach (StorageFile file in files)
                {
                    // With the OnlyUseIndexerAndOptimizeForIndexedProperties set, this won't  
                    // be async. It will run synchronously. 
                    var imageProps = await file.Properties.GetImagePropertiesAsync();

                    // this code is somewhat problematic
                    // jfb -- TODO -- could explore further StorageFile here.... maybe....
                    // Get extended properties.
                    // Define property names to be retrieved.
                    var propertyNames = new List<string>();
                    propertyNames.Add(dateAccessedProperty);
                    propertyNames.Add(fileOwnerProperty);

                    IDictionary<string, object> extraProperties =
                        await file.Properties.RetrievePropertiesAsync(propertyNames);

                    // Build the UI 
                    Debug.WriteLine(String.Format("{0} at {1}, {2}",
                     file.Path,
                     imageProps.Latitude,
                     imageProps.Longitude));

                     // TODO -- this is the wrong way to open a file, while it looks OK, it will fail on access issues
                     // need to use this method --> var new_file = await StorageFile.GetFileFromPathAsync(file.Path);
                    var open_file = file.OpenAsync(FileAccessMode.ReadWrite);

                    // ** DANGER DANGER **//
                    await file.DeleteAsync(); 
                    
                }
                index += stepSize;
                files = await queryResult.GetFilesAsync(index, stepSize);
            }
#endif
        }
    }
}
