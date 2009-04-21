
namespace Ioke.Lang.Util {
    using System.Collections.Generic;

    public class SaneHashSet<T> : HashSet<T> {
        public SaneHashSet() : base() {}
        public SaneHashSet(ICollection<T> ic) : base(ic) {}
        public SaneHashSet(ICollection<T> ic, IEqualityComparer<T> iec) : base(ic, iec) {}
        
        public override bool Equals(object other) {
            if(this == other) {
                return true;
            }
            if(!(other is HashSet<T>)) {
                return false;
            }
            HashSet<T> _other = (HashSet<T>)other;
            return this.SetEquals(_other);
        }

        public override int GetHashCode() {
            int result = 7;
            foreach(T o in this) {
                result = result + o.GetHashCode();
            }
            return result;
        }
    }
}
