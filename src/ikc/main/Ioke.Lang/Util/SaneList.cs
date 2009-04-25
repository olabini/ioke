
namespace Ioke.Lang.Util {
    using System.Collections.Generic;

    public class SaneList<T> : List<T> {
        public override bool Equals(object other) {
            if(this == other) {
                return true;
            }
            if(!(other is List<T>)) {
                return false;
            }
            List<T> _other = (List<T>)other;
            if(this.Count == _other.Count) {
                var enum1 = this.GetEnumerator();
                var enum2 = _other.GetEnumerator();
                while(enum1.MoveNext()) {
                    enum2.MoveNext();
                    if(!enum1.Current.Equals(enum2.Current)) {
                        return false;
                    }
                }
                return true;
            }
            return false;
        }

        public override int GetHashCode() {
            int result = 7;
            foreach(T o in this) {
                result = result + 13*o.GetHashCode();
            }
            return result;
        }
    }
}
