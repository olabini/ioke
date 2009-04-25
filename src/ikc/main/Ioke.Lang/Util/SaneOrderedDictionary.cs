

namespace Ioke.Lang.Util {
    using System.Collections;
    using System.Collections.Specialized;

    public class SaneOrderedDictionary : OrderedDictionary {
        public SaneOrderedDictionary() : base() {}
        
        public override bool Equals(object other) {
            if(this == other) {
                return true;
            }
            if(!(other is IDictionary)) {
                return false;
            }
            IDictionary _other = (IDictionary)other;
            if(this.Count != _other.Count) {
                return false;
            }
            foreach(DictionaryEntry entry in this) {
                if(!_other.Contains(entry.Key) || !(entry.Value.Equals(_other[entry.Key])))
                    return false;
            }
            return true;
        }

        public override int GetHashCode() {
            int result = 7;
            foreach(DictionaryEntry entry in this) {
                result = result + entry.Key.GetHashCode() * entry.Value.GetHashCode();
            }
            return result;
        }
    }
}
