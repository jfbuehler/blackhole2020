using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Blackhole
{
    /// <summary>
    /// Extending ObservbleCollection to allow access in both XAML and code behind, as well as customized event logic
    /// </summary>
    public class ObFileList : ObservableCollection<string>
    {
        public ObFileList()
            : base()
        {}

        public delegate void VoidDelegate();
        //public event VoidDelegate UpdateStatusSelection;

        protected override void OnCollectionChanged(System.Collections.Specialized.NotifyCollectionChangedEventArgs e)
        {
            // let collection do normal updates first
            base.OnCollectionChanged(e);

            // select the most recently added item by firing our custom event            
            //UpdateStatusSelection();

            // might need this dispatcher code if we need to modify UI on background worker thread
            //Application.Current.Dispatcher.Invoke(DispatcherPriority.Background, new MainWindow.UpdateStatusSelectionDelegate(UpdateStatusSelection));
        }
    }
}
