
namespace Ioke.Lang.Util {
    using System.Collections;

    public class SaneHashtable : Hashtable {
        public SaneHashtable() : base() {}
        public SaneHashtable(IDictionary id) : base(id) {}
        public SaneHashtable(IEqualityComparer iec) : base(iec) {}
        public SaneHashtable(int size) : base(size) {}
        
        public override bool Equals(object other) {
            if(this == other) {
                return true;
            }
            if(!(other is Hashtable)) {
                return false;
            }
            Hashtable _other = (Hashtable)other;
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
