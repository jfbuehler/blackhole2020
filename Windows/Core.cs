using System;
using System.Diagnostics;
using Windows.Storage;

/// <summary>
/// Communication between modules here
/// </summary>
public class Core
{
    public static UInt64 total_bytes_erased = 0;
    public static UInt64 files_erased = 0;
    public static UInt64 total_sessions = 0;

    public static void SaveBasicSettings()
    {
        ApplicationDataContainer localSettings = Windows.Storage.ApplicationData.Current.LocalSettings;

        localSettings.Values["files_erased"] = Core.files_erased;
        localSettings.Values["total_bytes_erased"] = Core.total_bytes_erased;
        localSettings.Values["total_sessions"] = Core.total_sessions;

        Debug.WriteLine("Saving settings ... files_erased=" + files_erased + " total_bytes_erased=" + total_bytes_erased + " total_sessions=" + total_sessions);

        // Save a composite setting locally on the device
        //Windows.Storage.ApplicationDataCompositeValue composite = new Windows.Storage.ApplicationDataCompositeValue();
        //composite["Font"] = "Calibri";
        //composite["FontSize"] = 11;
        //localSettings.Values["FontInfo"] = composite;
    }
}
