
namespace NRegex {
    using System;
    using System.Text;

    public class PerlSubstitution : Substitution {
        static Pattern refPtn;
        static int NAME_ID;
        static int ESC_ID;
   
        private static readonly string groupRef="\\$(?:\\{({=name}\\w+)\\}|({=name}\\d+|&))|\\\\({esc}.)";
   
        static PerlSubstitution() {
            try {
                refPtn = new Pattern(groupRef);
                NAME_ID = refPtn.GroupId("name");
                ESC_ID = refPtn.GroupId("esc");
            } catch(PatternSyntaxException e){
                System.Console.Error.WriteLine(e.StackTrace);
            }
        }
   
        Element queueEntry;
   
        public PerlSubstitution(string s){
            Matcher refMatcher = new Matcher(refPtn);
            refMatcher.Target = s;
            queueEntry = MakeQueue(refMatcher);
        }
   
        public string Value(MatchResult mr){
            TextBuffer dest = Replacer.Wrap(new StringBuilder(mr.Length));
            AppendSubstitution(mr,dest);
            return dest.ToString();
        }
   
        static Element MakeQueue(Matcher refMatcher) {
            if(refMatcher.Find()){
                Element element;
                if(refMatcher.IsCaptured(NAME_ID)){
                    char c=refMatcher.CharAt(0,NAME_ID);
                    if(c=='&') {
                        element = new IntRefHandler(refMatcher.Prefix, 0);
                    } else if(char.IsDigit(c)){
                        element = new IntRefHandler(refMatcher.Prefix, Convert.ToInt32(refMatcher.Group(NAME_ID)));
                    } else 
                        element = new StringRefHandler(refMatcher.Prefix, refMatcher.Group(NAME_ID));
                } else {
                    //escaped char
                    element = new PlainElement(refMatcher.Prefix, refMatcher.Group(ESC_ID));
                }
                refMatcher.SetTarget(refMatcher, Matcher.SUFFIX);
                element.next = MakeQueue(refMatcher);
                return element;
            } else return new PlainElement(refMatcher.Target);
        }
   
        public void AppendSubstitution(MatchResult match, TextBuffer dest) {
            for(Element element=this.queueEntry; element!=null; element=element.next){
                element.Append(match,dest);
            }
        }
   
        public override string ToString() {
            StringBuilder sb = new StringBuilder();
            for(Element element=this.queueEntry;element!=null;element=element.next){
                sb.Append(element.ToString());
            }
            return sb.ToString();
        }
   
        private abstract class Element {
            protected string prefix;
            internal Element next;
            internal abstract void Append(MatchResult match, TextBuffer dest);
        }
   
        private class PlainElement : Element {
            private string str;
            internal PlainElement(string s) {
                str=s;
            }
            internal PlainElement(string pref, string s){
                prefix=pref;
                str=s;
            }
            internal override void Append(MatchResult match, TextBuffer dest){
                if(prefix!=null) dest.Append(prefix);
                if(str!=null) dest.Append(str);
            }
        }
   
        private class IntRefHandler : Element {
            private int index;
            internal IntRefHandler(String s, int ind){
                prefix = s;
                index = ind;
            }
            internal override void Append(MatchResult match, TextBuffer dest) {
                if(prefix!=null) dest.Append(prefix);
                if(index>=match.Pattern.GroupCount) return;
                if(match.IsCaptured(index)) match.Group(index,dest);
            }
        }
   
        private class StringRefHandler : Element {
            private string index;
            internal StringRefHandler(string s, string ind){
                prefix = s;
                index = ind;
            }

            internal override void Append(MatchResult match, TextBuffer dest) {
                if(prefix!=null) dest.Append(prefix);
                if(index==null) return;
                int id=match.Pattern.GroupId(index);
                if(match.IsCaptured(id)) match.Group(id,dest);
            }
        }
    }
}
