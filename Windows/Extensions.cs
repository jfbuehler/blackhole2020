using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Linq.Expressions;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace Blackhole
{
    /// <summary>
    /// Extension methods to simplify C# code
    /// </summary>
    public static class Extensions
    {
        // *************************************************************************************
        // Extension methods for INotifyPropertyChanged to remove dependency on magic strings
        // *************************************************************************************
        public static string ExtractPropertyName<T>(Expression<Func<T>> propertyExpression)
        {
            if (propertyExpression == null)
            {
                throw new ArgumentNullException("propertyExpression");
            }

            var memberExpression = propertyExpression.Body as MemberExpression;

            if (memberExpression == null)
            {
                throw new ArgumentException("The expression is not a member access expression.", "propertyExpression");
            }

            var property = memberExpression.Member as PropertyInfo;

            if (property == null)
            {
                throw new ArgumentException("The member access expression does not access a property.", "propertyExpression");
            }

            return memberExpression.Member.Name;
        }

        // The syntax RaisePropertyChanged("MyProperty")
        // is replaced by this syntax, RaisePropertyChanged(() => MyProperty, PropertyChanged); 
        public static void RaisePropertyChanged<T>(this INotifyPropertyChanged src, Expression<Func<T>> propertyExpression, PropertyChangedEventHandler handler)
        {
            if (handler != null)
            {
                handler(src, new PropertyChangedEventArgs(ExtractPropertyName(propertyExpression)));
            }
        }
    }

    public static class ArrayExtensions
    {
        // Inspired from several Stack Overflow discussions and an implementation by David Walker at http://coding.grax.com/2011/11/initialize-array-to-value-in-c-very.html
        public static void Fill<T>(this T[] destinationArray, params T[] value)
        {
            if (destinationArray == null)
            {
                throw new ArgumentNullException("destinationArray");
            }

            if (value.Length > destinationArray.Length)
            {
                throw new ArgumentException("Length of value array must not be more than length of destination");
            }

            // set the initial array value
            Array.Copy(value, destinationArray, value.Length);

            int copyLength, nextCopyLength;

            for (copyLength = value.Length; (nextCopyLength = copyLength << 1) < destinationArray.Length; copyLength = nextCopyLength)
            {
                Array.Copy(destinationArray, 0, destinationArray, copyLength, copyLength);
            }

            Array.Copy(destinationArray, 0, destinationArray, copyLength, destinationArray.Length - copyLength);
        }
    }

    public static class Superfast
    {
        [DllImport("msvcrt.dll",
                  EntryPoint = "memset",
                  CallingConvention = CallingConvention.Cdecl,
                  SetLastError = false)]
        private static extern IntPtr MemSet(IntPtr dest, int c, int count);

        //If you need super speed, calling out to M$ memset optimized method using P/invoke
        public static byte[] InitByteArray(byte fillWith, int size)
        {
            byte[] arrayBytes = new byte[size];
            GCHandle gch = GCHandle.Alloc(arrayBytes, GCHandleType.Pinned);
            MemSet(gch.AddrOfPinnedObject(), fillWith, arrayBytes.Length);
            gch.Free();
            return arrayBytes;
        }
    }
}
