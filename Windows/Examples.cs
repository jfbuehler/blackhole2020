using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Blackhole
{
    class Examples
    {
        /// <summary>
        /// Erasure method examples and samples, not currently used
        /// </summary>
        void file_erase_example()
        {
            //foreach (var file in files)
            //{
            //    //
            //    // Some basic notes and ideas about how to erase files in UWP.
            //    //
            //    BasicProperties file_basic_props = await file.GetBasicPropertiesAsync();

            //    // don't use this method to write to files, it seems to overwrite the entire file with the string bytes (so what happens to the rest of the file? hard to know)
            //    //await PathIO.WriteTextAsync(file.Path, "Can we write to this??");
            //    //await file.DeleteAsync();

            //    // Create an array of a fixed known pattern of the same size as the file we are erasing
            //    // Note: do not use standard Array.Fill<> or lambda based array initializers as they take VERY VERY long. Files over 100 megabytes will take minutes here otherwise. 
            //    byte[] bytes = Superfast.InitByteArray(0xee, (int)file_basic_props.Size);

            //    // unauthorized access exceptions if you try to access and set ANY file settings using File or FileInfo
            //    // it seems this is a limitation of the UWP sandbox, at least in 2022. 
            //    //System.IO.File.SetCreationTime(file.Path, DateTime.Now);

            //    // Access to System.IO methods can be had via the WPF invokation workaround, but that is very heavy handed for this application
            //    // there must be a better way...

            //    var new_file = await StorageFile.GetFileFromPathAsync(file.Path);
            //    await PathIO.WriteBytesAsync(new_file.Path, bytes);
            //    await new_file.DeleteAsync(StorageDeleteOption.PermanentDelete);
            //}
        }
    }
}
