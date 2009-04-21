
namespace Ioke.Lang.Util {
    using System.Collections.Generic;

    public class SaneDictionary<U, V> : Dictionary<U, V> {
        public override bool Equals(object other) {
            if(this == other) {
                return true;
            }
            if(!(other is Dictionary<U, V>)) {
                return false;
            }
            Dictionary<U, V> _other = (Dictionary<U, V>)other;
            if(this.Count != _other.Count) {
                return false;
            }
            foreach(var entry in this) {
                if(!_other.ContainsKey(entry.Key) || !(entry.Value.Equals(_other[entry.Key])))
                    return false;
            }
            return true;
        }

        public override int GetHashCode() {
            int result = 7;
            foreach(var entry in this) {
                result = result + entry.Key.GetHashCode() * entry.Value.GetHashCode();
            }
            return result;
        }
    }
}
