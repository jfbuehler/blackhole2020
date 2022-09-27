using Microsoft.UI.Xaml.Controls;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.WindowsRuntime;
using System.Threading;
using Windows.Foundation;
using Windows.Foundation.Collections;
//using Windows.System.Threading;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Controls.Primitives;
using Windows.UI.Xaml.Data;
using Windows.UI.Xaml.Input;
using Windows.UI.Xaml.Media;
using Windows.UI.Xaml.Navigation;

// The User Control item template is documented at https://go.microsoft.com/fwlink/?LinkId=234236

namespace Blackhole
{
    public sealed partial class File : UserControl, INotifyPropertyChanged
    {
        public File()
        {
            this.DataContext = this;
            this.InitializeComponent();

            animation_visual_player.RegisterPropertyChangedCallback(AnimatedVisualPlayer.IsAnimatedVisualLoadedProperty, handle_is_animated_visual_loaded);

        }

        private double animation_time_secs = 0;  // filled in when the JSON is loaded

        public int Top
        {
            get { return (int)GetValue(TopProperty); }
            set { SetValue(TopProperty, value); }
        }

        // Using a DependencyProperty as the backing store for Top.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty TopProperty =
            DependencyProperty.Register("Top", typeof(int), typeof(Int32), new PropertyMetadata(0));


        public int Left
        {
            get { return (int)GetValue(LeftProperty); }
            set { SetValue(LeftProperty, value); }
        }

        // better idea...don't need this anymore
        public void RemovalTimerStart()
        {
            TimeSpan period = TimeSpan.FromSeconds(60);

            //ThreadPoolTimer PeriodicTimer = ThreadPoolTimer.CreatePeriodicTimer((source) =>
            //{ 
            //}, period);
            //Debug.WriteLine("Starting removal timer..." + animation_visual_player.Duration.TotalSeconds);

            ThreadPool.QueueUserWorkItem(
                async (workItem) =>
                {

                    Debug.WriteLine("Sleeping timer... " + animation_time_secs * 1000);
                    Thread.Sleep((int)(animation_time_secs * 1000));
                    
                    Debug.WriteLine("Removal from canvas...");

                    await Dispatcher.RunAsync(Windows.UI.Core.CoreDispatcherPriority.Normal, async () =>
                    {
                        Debug.WriteLine("Removal from canvas id=" + parent_container.Children.IndexOf(this));
                        parent_container.Children.RemoveAt(parent_container.Children.IndexOf(this));
                        
                    });
                });

        }

        //private DispatcherTimer remove_timer;
        //private void start_removal_timer()
        //{
        //    remove_timer = new DispatcherTimer();
        //    remove_timer.Interval = TimeSpan.FromSeconds(5);
        //    remove_timer.Tick += new EventHandler(remove_timer_Elapsed());
        //    remove_timer.Start();
        //}

        //private void remove_timer_Elapsed<T>(object sender, EventArgs e)
        //{

        //}

        public Canvas parent_container;
        public int parent_index = 0;

        // Using a DependencyProperty as the backing store for Left.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty LeftProperty =
            DependencyProperty.Register("Left", typeof(int), typeof(Int32), new PropertyMetadata(0));

        public void SetDirection(int x, int y, int width, int height)
        {
            string json = "ms-appx:///";
            var dir = FileDisintegrationDirection.TopLeft;

            // divide the black hole up into 3rds and split left vs. right

            if (x < width / 2)
            {
                if (y < height / 3)
                    dir = FileDisintegrationDirection.TopLeft;

                else if (y <= height / 3 * 2)
                    dir = FileDisintegrationDirection.MidLeft;

                else // top 3rd
                    dir = FileDisintegrationDirection.BottomLeft;
            }
            else  // > width/2 ( >250 pixels)
            {
                if (y < height / 3)
                    dir = FileDisintegrationDirection.TopRight;

                else if (y <= height / 3 * 2)
                    dir = FileDisintegrationDirection.MidRight;

                else // top 3rd
                    dir = FileDisintegrationDirection.BottomRight;
            }

            switch (dir)
            {
                case FileDisintegrationDirection.TopLeft:  json += "File_Disintegration_TopLeft";       break;
                case FileDisintegrationDirection.TopRight: json += "File_Disintegration_TopRight";      break;
                case FileDisintegrationDirection.MidLeft: json += "File_Disintegration_MidLeft";        break;
                case FileDisintegrationDirection.MidRight: json += "File_Disintegration_MidRight";      break;
                case FileDisintegrationDirection.BottomLeft: json += "File_Disintegration_BottomLeft";  break;
                case FileDisintegrationDirection.BottomRight: json += "File_Disintegration_BottomRight";break;
            }

            json += ".json";
            lottie_disintegrate.SetSourceAsync(new Uri(json));

            //Debug.WriteLine("SetDirection - " + dir + " x=" + x + " y=" + y);

            //CurrentJson = new Uri("ms-appx:///File_Disintegration_TopRight.json");
            //this.RaisePropertyChanged(() => CurrentJson, PropertyChanged);
        }

        public Uri CurrentJson
        {
            //set { current_json = value; this.RaisePropertyChanged(() => CurrentJson, PropertyChanged); }

            get => current_json; set
            { 
                current_json = value;
                PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(nameof(Name)));
            }
            
        }
        private Uri current_json = new Uri("ms-appx:///File_Disintegration_MidRight.json");

        private async void UserControl_Loaded(object sender, RoutedEventArgs e)
        {
            //await animate_scale_up.PlayAsync(0, 1, true);
            //await animate_disintegrate.PlayAsync(0.5, 0.5, false);
            //await lottie_disintegrate.RegisterPropertyChangedCallback(lo)
            animation_visual_player.RegisterPropertyChangedCallback(AnimatedVisualPlayer.IsAnimatedVisualLoadedProperty, handle_is_animated_visual_loaded);
        }

        private async void handle_is_animated_visual_loaded(DependencyObject sender, DependencyProperty prop)
        {
            var is_loaded = (bool)sender.GetValue(prop);
            //Debug.WriteLine("is visual loaded = " + is_loaded);

            // TODO -- can put animation delay here in background thread that invokes the UI to call play
            if (is_loaded)
            {
                animation_time_secs = animation_visual_player.Duration.TotalSeconds;
                //Debug.WriteLine("Animating...time=" + animation_time_secs);
                await animation_visual_player.PlayAsync(0, 1, false);               
            }            
        }

        private void handle_is_animation_playing(DependencyObject sender, DependencyProperty prop)
        {
            var is_playing = (bool)sender.GetValue(prop);
            Debug.WriteLine("Is animation[" + parent_container.Children.IndexOf(this) + "] is_playing=" + is_playing);

            //if (is_playing == false)
            //    parent_container.Children.IndexOf(this);
        }

        #region INotifyPropertyChanged Implementation
        public event PropertyChangedEventHandler PropertyChanged;
        // rest of INotifyPropertyChanged is defined in an extension method in Extensions.cs under the static class PropertyHelper
        #endregion
    }

    public enum FileDisintegrationDirection
    {
        TopLeft,
        TopRight,
        MidLeft,
        MidRight,
        BottomLeft,
        BottomRight
    }
}
