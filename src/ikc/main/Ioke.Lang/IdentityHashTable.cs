
namespace Ioke.Lang {
    using Ioke.Lang.Util;

    using System.Collections;
    using System.Collections.Generic;
    public class IdentityHashTable {
        public class IdentityEqualityComparer : IEqualityComparer, IEqualityComparer<object> {
            bool IEqualityComparer.Equals(object x, object y) {
                return object.ReferenceEquals(x, y);
            }

            bool IEqualityComparer<object>.Equals(object x, object y) {
                return object.ReferenceEquals(x, y);
            }
            
            public int GetHashCode(object obj) {
                return System.Runtime.CompilerServices.RuntimeHelpers.GetHashCode(obj);
            }
        }

        public static IDictionary Create() {
            return new SaneHashtable(new IdentityEqualityComparer());
        }
    }
}
