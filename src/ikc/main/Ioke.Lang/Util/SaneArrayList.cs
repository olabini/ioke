
namespace Ioke.Lang.Util {
    using System.Collections;
    using System.Text;

    public class SaneArrayList : ArrayList {
        public SaneArrayList() : base() {}
        public SaneArrayList(ICollection ic) : base(ic) {}
        public SaneArrayList(int size) : base(size) {}

        public override bool Equals(object other) {
            if(this == other) {
                return true;
            }
            if(!(other is IList)) {
                return false;
            }
            IList _other = (IList)other;
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
            foreach(object o in this) {
                result = result + 13*o.GetHashCode();
            }
            return result;
        }

        public override string ToString() {
            var sb = new StringBuilder();
            sb.Append("[");
            string sep = "";
            foreach(object o in this) {
                sb.Append(sep).Append(o.ToString());
                sep = ", ";
            }
            sb.Append("]");
            return sb.ToString();
        }

        // Stable insertion seort
        // TODO: Should really be merge sort
        public override void Sort(IComparer comparison) {
            if (comparison == null)
                throw new System.ArgumentNullException( "comparison" );
            int count = this.Count;
            for(int j = 1; j < count; j++) {
                object key = this[j];
                int i = j - 1;
                for (; i >= 0 && comparison.Compare(this[i], key) > 0; i--) {
                    this[i + 1] = this[i];
                }
                this[i + 1] = key;
            }
        }
    }
}
