
namespace NRegex {
    using System.Text;

    public class WildcardPattern : Pattern {
        public static readonly string WORD_CHAR = "\\w";
        public static readonly string ANY_CHAR = ".";
   
        private static readonly string defaultSpecials = "[]().{}+|^$\\";
        private static readonly string defaultWcClass = ANY_CHAR;

        protected static string ConvertSpecials(string s, string wcClass, string specials) {
            int len=s.Length;
            StringBuilder sb=new StringBuilder();
            for(int i=0;i<len;i++){
                char c=s[i];
                switch(c){
                case '*':
                    sb.Append("(");
                    sb.Append(wcClass);
                    sb.Append("*)");
                    break;
                case '?':
                    sb.Append("(");
                    sb.Append(wcClass);
                    sb.Append(")");
                    break;
                default:
                    if(specials.IndexOf(c)>=0) sb.Append('\\');
                    sb.Append(c);
                    break;
                }
            }
            return sb.ToString();
        }
   
        string str;
   
        public WildcardPattern(string wc) : this(wc, true) {}
        public WildcardPattern(string wc, bool icase) : this(wc, icase ? REFlags.DEFAULT|REFlags.IGNORE_CASE : REFlags.DEFAULT) {}
        public WildcardPattern(string wc, REFlags flags){
            Compile(wc, defaultWcClass, defaultSpecials, flags);
        }
   
        public WildcardPattern(string wc, string wcClass, REFlags flags){
            Compile(wc, wcClass, defaultSpecials, flags);
        }
   
        protected WildcardPattern() {}
   
        protected void Compile(string wc, string wcClass, string specials, REFlags flags) {
            string converted = ConvertSpecials(wc, wcClass, specials);
            try {
                Compile(converted,flags);
            } catch(PatternSyntaxException e) {
                throw new System.Exception(e.Message+"; original expr: "+wc+", converted: "+converted);
            }
            str=wc;
        }
   
        public override string ToString() {
            return str;
        }
    }
}
