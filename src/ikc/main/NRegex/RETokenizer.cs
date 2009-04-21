
namespace NRegex {
    using System.Collections.Generic;
    using System.IO;

    public class RETokenizer : IEnumerator<object> {
        Matcher matcher;
        bool _checked;
        bool hasToken;
        string token;
        bool endReached=false;
        bool emptyTokensEnabled=false;
   
        public RETokenizer(Pattern pattern, string text) : this(pattern.Matcher(text),false) {}
        public RETokenizer(Pattern pattern, char[] chars, int off, int len) : this(pattern.Matcher(chars,off,len),false) {}
        public RETokenizer(Pattern pattern, TextReader r, int len) : this(pattern.Matcher(r,len),false) {}
        public RETokenizer(Matcher m, bool emptyEnabled) {
            matcher = m;
            emptyTokensEnabled = emptyEnabled;
        }

        public bool EmptyEnabled {
            get { return emptyTokensEnabled; }
            set { emptyTokensEnabled = value; }
        }
   
        public bool HasMore {
            get {
                if(!_checked) Check();
                return hasToken;
            }
        }
   
        public string NextToken {
            get {
                if(!_checked) Check();
                if(!hasToken) throw new System.InvalidOperationException();
                _checked=false;
                return token;
            }
        }
   
        public string[] Split() {
            return Collect(this, null, 0);
        }
   
        public void Reset() {
            matcher.Position = 0;
        }
   
        private static string[] Collect(RETokenizer tok, string[] arr, int count) {
            if(tok.HasMore){
                string s=tok.NextToken;
                arr=Collect(tok,arr,count+1);
                arr[count]=s;
            } else {
                arr = new string[count];
            }
            return arr;
        }
   
        private void Check() {
            bool emptyOk = this.emptyTokensEnabled;
            _checked=true;
            if(endReached) {
                hasToken=false;
                return;
            }
            Matcher m=matcher;
            bool hasMatch=false;
            while(m.Find()){
                if(m.Start>0){
                    hasMatch=true;
                    break;
                } else if(m.End>0) {
                    if(emptyOk) {
                        hasMatch=true;
                        break;
                    } else m.SetTarget(m, Matcher.SUFFIX);
                }
            }
            if(!hasMatch) {
                endReached=true;
                if(m.GetLength(Matcher.TARGET) == 0 && !emptyOk) {
                    hasToken=false;
                } else {
                    hasToken = true;
                    token = m.Target;
                }
                return;
            }
            hasToken = true;
            token = m.Prefix;
            m.SetTarget(m, Matcher.SUFFIX);
        }

        private string curr = null;
   
        public object Current {
            get { 
                return curr; 
            }
        }

        public bool MoveNext() {
            bool result = HasMore;
            if(result)
                curr = NextToken;
            return result;
        }

        public void Dispose() {}
    }
}
