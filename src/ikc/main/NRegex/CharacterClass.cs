namespace NRegex { 
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.Text;

    internal class CharacterClass : Term {
        internal static readonly Bitset DIGIT=new Bitset();
        internal static readonly Bitset WORDCHAR = new Bitset();
        internal static readonly Bitset SPACE = new Bitset();
   
        internal static readonly Bitset UDIGIT = new Bitset();
        internal static readonly Bitset UWORDCHAR = new Bitset();
        internal static readonly Bitset USPACE = new Bitset();
   
        internal static readonly Bitset NONDIGIT = new Bitset();
        internal static readonly Bitset NONWORDCHAR = new Bitset();
        internal static readonly Bitset NONSPACE = new Bitset();
   
        internal static readonly Bitset UNONDIGIT = new Bitset();
        internal static readonly Bitset UNONWORDCHAR = new Bitset();
        internal static readonly Bitset UNONSPACE = new Bitset();
   
        private static bool namesInitialized = false;
   
        internal static readonly IDictionary<string, Bitset> namedClasses = new Dictionary<string, Bitset>();
        internal static readonly IList<string> unicodeBlocks = new List<string>();
        internal static readonly IList<string> posixClasses = new List<string>();
        internal static readonly IList<string> unicodeCategories = new List<string>();
   
        //modes; used in parseGroup(()
        private const int ADD = 1;
        private const int SUBTRACT = 2;
        private const int INTERSECT = 3;
   
        private static readonly string blockData = 
            "0000..007F:InBasicLatin;0080..00FF:InLatin-1Supplement;0100..017F:InLatinExtended-A;"
            +"0180..024F:InLatinExtended-B;0250..02AF:InIPAExtensions;02B0..02FF:InSpacingModifierLetters;"
            +"0300..036F:InCombiningDiacriticalMarks;0370..03FF:InGreek;0400..04FF:InCyrillic;0530..058F:InArmenian;"
            +"0590..05FF:InHebrew;0600..06FF:InArabic;0700..074F:InSyriac;0780..07BF:InThaana;0900..097F:InDevanagari;"
            +"0980..09FF:InBengali;0A00..0A7F:InGurmukhi;0A80..0AFF:InGujarati;0B00..0B7F:InOriya;0B80..0BFF:InTamil;"
            +"0C00..0C7F:InTelugu;0C80..0CFF:InKannada;0D00..0D7F:InMalayalam;0D80..0DFF:InSinhala;0E00..0E7F:InThai;"
            +"0E80..0EFF:InLao;0F00..0FFF:InTibetan;1000..109F:InMyanmar;10A0..10FF:InGeorgian;1100..11FF:InHangulJamo;"
            +"1200..137F:InEthiopic;13A0..13FF:InCherokee;1400..167F:InUnifiedCanadianAboriginalSyllabics;"
            +"1680..169F:InOgham;16A0..16FF:InRunic;1780..17FF:InKhmer;1800..18AF:InMongolian;"
            +"1E00..1EFF:InLatinExtendedAdditional;1F00..1FFF:InGreekExtended;2000..206F:InGeneralPunctuation;"
            +"2070..209F:InSuperscriptsAndSubscripts;20A0..20CF:InCurrencySymbols;"
            +"20D0..20FF:InCombiningMarksForSymbols;2100..214F:InLetterLikeSymbols;2150..218F:InNumberForms;"
            +"2190..21FF:InArrows;2200..22FF:InMathematicalOperators;2300..23FF:InMiscellaneousTechnical;"
            +"2400..243F:InControlPictures;2440..245F:InOpticalCharacterRecognition;"
            +"2460..24FF:InEnclosedAlphanumerics;2500..257F:InBoxDrawing;2580..259F:InBlockElements;"
            +"25A0..25FF:InGeometricShapes;2600..26FF:InMiscellaneousSymbols;2700..27BF:InDingbats;"
            +"2800..28FF:InBraillePatterns;2E80..2EFF:InCJKRadicalsSupplement;2F00..2FDF:InKangxiRadicals;"
            +"2FF0..2FFF:InIdeographicDescriptionCharacters;3000..303F:InCJKSymbolsAndPunctuation;"
            +"3040..309F:InHiragana;30A0..30FF:InKatakana;3100..312F:InBopomofo;3130..318F:InHangulCompatibilityJamo;"
            +"3190..319F:InKanbun;31A0..31BF:InBopomofoExtended;3200..32FF:InEnclosedCJKLettersAndMonths;"
            +"3300..33FF:InCJKCompatibility;3400..4DB5:InCJKUnifiedIdeographsExtensionA;"
            +"4E00..9FFF:InCJKUnifiedIdeographs;A000..A48F:InYiSyllables;A490..A4CF:InYiRadicals;"
            +"AC00..D7A3:InHangulSyllables;D800..DB7F:InHighSurrogates;DB80..DBFF:InHighPrivateUseSurrogates;"
            +"DC00..DFFF:InLowSurrogates;E000..F8FF:InPrivateUse;F900..FAFF:InCJKCompatibilityIdeographs;"
            +"FB00..FB4F:InAlphabeticPresentationForms;FB50..FDFF:InArabicPresentationForms-A;"
            +"FE20..FE2F:InCombiningHalfMarks;FE30..FE4F:InCJKCompatibilityForms;FE50..FE6F:InSmallFormVariants;"
            +"FE70..FEFE:InArabicPresentationForms-B;FEFF..FEFF:InSpecials;FF00..FFEF:InHalfWidthAndFullWidthForms;"
            +"FFF0..FFFD:InSpecials";
   
        static CharacterClass() {
            DIGIT.SetDigit(false);
            WORDCHAR.SetWordChar(false);
            SPACE.SetSpace(false);
      
            UDIGIT.SetDigit(true);
            UWORDCHAR.SetWordChar(true);
            USPACE.SetSpace(true);
      
            NONDIGIT.SetDigit(false); NONDIGIT.SetPositive(false); 
            NONWORDCHAR.SetWordChar(false); NONWORDCHAR.SetPositive(false); 
            NONSPACE.SetSpace(false); NONSPACE.SetPositive(false); 
      
            UNONDIGIT.SetDigit(true); UNONDIGIT.SetPositive(false);
            UNONWORDCHAR.SetWordChar(true); UNONWORDCHAR.SetPositive(false);
            UNONSPACE.SetSpace(true); UNONSPACE.SetPositive(false);
      
            InitPosixClasses();
        }
   
        private static void RegisterClass(string name, Bitset cls, IList<string> realm){
            namedClasses[name] = cls;
            if(!realm.Contains(name)) realm.Add(name);
        }
   
        private static void InitPosixClasses(){
            Bitset lower = new Bitset();
            lower.SetRange('a','z');
            RegisterClass("Lower", lower, posixClasses);

            Bitset upper = new Bitset();
            upper.SetRange('A','Z');
            RegisterClass("Upper",upper,posixClasses);

            Bitset ascii = new Bitset();
            ascii.SetRange((char)0,(char)0x7f);
            RegisterClass("ASCII",ascii,posixClasses);

            Bitset alpha = new Bitset();
            alpha.Add(lower);
            alpha.Add(upper);
            RegisterClass("Alpha",alpha,posixClasses);

            Bitset digit = new Bitset();
            digit.SetRange('0','9');
            RegisterClass("Digit",digit,posixClasses);

            Bitset alnum = new Bitset();
            alnum.Add(alpha);
            alnum.Add(digit);
            RegisterClass("Alnum",alnum,posixClasses);

            Bitset punct = new Bitset();
            punct.SetChars("!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~");
            RegisterClass("Punct",punct,posixClasses);

            Bitset graph = new Bitset();
            graph.Add(alnum);
            graph.Add(punct);
            RegisterClass("Graph",graph,posixClasses);
            RegisterClass("Print",graph,posixClasses);

            Bitset blank = new Bitset();
            blank.SetChars(" \t");
            RegisterClass("Blank",blank,posixClasses);

            Bitset cntrl = new Bitset();
            cntrl.SetRange((char)0,(char)0x1f);
            cntrl.SetChar((char)0x7f);
            RegisterClass("Cntrl",cntrl,posixClasses);

            Bitset xdigit = new Bitset();
            xdigit.SetRange('0','9');
            xdigit.SetRange('a','f');
            xdigit.SetRange('A','F');
            RegisterClass("XDigit",xdigit,posixClasses);

            Bitset space = new Bitset();
            space.SetChars(" \t\n\r\f\u000b");
            RegisterClass("Space",space,posixClasses);
        }
   
        private static void InitNames(){
            InitNamedCategory("C",new int[]{UnicodeConstants.Cn,UnicodeConstants.Cc,UnicodeConstants.Cf,UnicodeConstants.Co,UnicodeConstants.Cs}); 
            InitNamedCategory("Cn",UnicodeConstants.Cn); 
            InitNamedCategory("Cc",UnicodeConstants.Cc);
            InitNamedCategory("Cf",UnicodeConstants.Cf);
            InitNamedCategory("Co",UnicodeConstants.Co);
            InitNamedCategory("Cs",UnicodeConstants.Cs);
      
            InitNamedCategory("L",new int[]{UnicodeConstants.Lu,UnicodeConstants.Ll,UnicodeConstants.Lt,UnicodeConstants.Lm,UnicodeConstants.Lo}); 
            InitNamedCategory("Lu",UnicodeConstants.Lu);
            InitNamedCategory("Ll",UnicodeConstants.Ll);
            InitNamedCategory("Lt",UnicodeConstants.Lt);
            InitNamedCategory("Lm",UnicodeConstants.Lm);
            InitNamedCategory("Lo",UnicodeConstants.Lo);
      
            InitNamedCategory("M",new int[]{UnicodeConstants.Mn,UnicodeConstants.Me,UnicodeConstants.Mc}); 
            InitNamedCategory("Mn",UnicodeConstants.Mn);
            InitNamedCategory("Me",UnicodeConstants.Me);
            InitNamedCategory("Mc",UnicodeConstants.Mc);
      
            InitNamedCategory("N",new int[]{UnicodeConstants.Nd,UnicodeConstants.Nl,UnicodeConstants.No}); 
            InitNamedCategory("Nd",UnicodeConstants.Nd);
            InitNamedCategory("Nl",UnicodeConstants.Nl);
            InitNamedCategory("No",UnicodeConstants.No);
      
            InitNamedCategory("Z",new int[]{UnicodeConstants.Zs,UnicodeConstants.Zl,UnicodeConstants.Zp}); 
            InitNamedCategory("Zs",UnicodeConstants.Zs);
            InitNamedCategory("Zl",UnicodeConstants.Zl);
            InitNamedCategory("Zp",UnicodeConstants.Zp);
      
            InitNamedCategory("P",new int[]{UnicodeConstants.Pd,UnicodeConstants.Ps,UnicodeConstants.Pi,UnicodeConstants.Pe,UnicodeConstants.Pf,UnicodeConstants.Pc,UnicodeConstants.Po}); 
            InitNamedCategory("Pd",UnicodeConstants.Pd);
            InitNamedCategory("Ps",UnicodeConstants.Ps);
            InitNamedCategory("Pi",UnicodeConstants.Pi);
            InitNamedCategory("Pe",UnicodeConstants.Pe);
            InitNamedCategory("Pf",UnicodeConstants.Pf);
            InitNamedCategory("Pc",UnicodeConstants.Pc);
            InitNamedCategory("Po",UnicodeConstants.Po);
      
            InitNamedCategory("S",new int[]{UnicodeConstants.Sm,UnicodeConstants.Sc,UnicodeConstants.Sk,UnicodeConstants.So}); 
            InitNamedCategory("Sm",UnicodeConstants.Sm);
            InitNamedCategory("Sc",UnicodeConstants.Sc);
            InitNamedCategory("Sk",UnicodeConstants.Sk);
            InitNamedCategory("So",UnicodeConstants.So);
      
            Bitset bs = new Bitset();
            bs.SetCategory(UnicodeConstants.Cn);
            RegisterClass("UNASSIGNED",bs,unicodeCategories);
            bs = new Bitset();
            bs.SetCategory(UnicodeConstants.Cn);
            bs.SetPositive(false);
            RegisterClass("ASSIGNED",bs,unicodeCategories);
      
            string[] results = blockData.Split(new char[]{'.', ',', ':', ';'}, System.StringSplitOptions.RemoveEmptyEntries);
            int ix = 0;
            while(ix < results.Length) {
                int first = Convert.ToInt32(results[ix++], 16);
                int last = Convert.ToInt32(results[ix++], 16);
                string name = results[ix++];
                InitNamedBlock(name,first,last);
            }

            InitNamedBlock("ALL",0,0xffff);
      
            namesInitialized=true;
        }
   
        private static void InitNamedBlock(string name, int first, int last){
            if(first<char.MinValue || first>char.MaxValue) throw new ArgumentException("wrong start code ("+first+") in block "+name);
            if(last<char.MinValue || last>char.MaxValue) throw new ArgumentException("wrong end code ("+last+") in block "+name);
            if(last<first) throw new ArgumentException("end code < start code in block "+name);

            Bitset bs;
            if(namedClasses.ContainsKey(name)) {
                bs = namedClasses[name];
            } else {
                bs = new Bitset();
                RegisterClass(name,bs,unicodeBlocks);
            }
            bs.SetRange((char)first,(char)last);
        }
   
        private static void InitNamedCategory(string name, int cat){
            Bitset bs = new Bitset();
            bs.SetCategory(cat);
            RegisterClass(name,bs,unicodeCategories);
        }
   
        private static void InitNamedCategory(string name, int[] cats){
            Bitset bs = new Bitset();
            foreach(int cat in cats){
                bs.SetCategory(cat);
            }
            namedClasses[name] = bs;
        }
   
        private static Bitset GetNamedClass(string name){
            if(!namesInitialized) InitNames();
            return namedClasses[name];
        }
   
        internal static void MakeICase(Term term, char c){
            Bitset bs = new Bitset();
            bs.SetChar(char.ToLower(c));
            bs.SetChar(char.ToUpper(c));
            Bitset.Unify(bs,term);
        }
   
        internal static void MakeDigit(Term term, bool inverse, bool unicode) {
            Bitset digit = unicode ? inverse ? UNONDIGIT : UDIGIT : inverse ? NONDIGIT : DIGIT ;
            Bitset.Unify(digit,term);
        }
   
        internal static void MakeSpace(Term term, bool inverse, bool unicode){
            Bitset space = unicode ? inverse ? UNONSPACE : USPACE : inverse ? NONSPACE : SPACE ;
            Bitset.Unify(space,term);
        }
   
        internal static void MakeWordChar(Term term, bool inverse, bool unicode){
            Bitset wordChar = unicode ? inverse ? UNONWORDCHAR : UWORDCHAR : inverse ? NONWORDCHAR : WORDCHAR ;
            Bitset.Unify(wordChar,term);
        }
   
        internal static void MakeWordBoundary(Term term, bool inverse, bool unicode){
            MakeWordChar(term, inverse, unicode);
            term.type = unicode ? TermType.UBOUNDARY : TermType.BOUNDARY;
        }
   
        internal static void MakeWordStart(Term term, bool unicode){
            MakeWordChar(term, false, unicode);
            term.type = unicode ? TermType.UDIRECTION : TermType.DIRECTION;
        }
   
        internal static void MakeWordEnd(Term term, bool unicode){
            MakeWordChar(term, true, unicode);
            term.type=unicode ? TermType.UDIRECTION : TermType.DIRECTION;
        }
   
        internal static void ParseGroup(char[] data, int i, int _out, Term term, bool icase, bool skipspaces, bool unicode, bool xml) {
            Bitset sum = new Bitset();
            Bitset bs = new Bitset();
            int mode = ADD;
            for(;i<_out;){
                switch(data[i++]){
                case '+':
                    mode=ADD;
                    continue;
                case '-':
                    mode=SUBTRACT;
                    continue;
                case '&':
                    mode=INTERSECT;
                    continue;
                case '[':
                    bs.Reset();
                    i=ParseClass(data,i,_out,bs,icase,skipspaces,unicode,xml);
                    switch(mode){
                    case ADD:
                        sum.Add(bs);
                        break;
                    case SUBTRACT:
                        sum.Subtract(bs);
                        break;
                    case INTERSECT:
                        sum.Intersect(bs);
                        break;
                    }
                    continue;
                case ')':
                    throw new  PatternSyntaxException("unbalanced class group");
                }
            }
            Bitset.Unify(sum,term);
        }
   
        internal static int ParseClass(char[] data, int i, int _out, Term term, bool icase, bool skipspaces, bool unicode, bool xml) {
            Bitset bs = new Bitset();
            i = ParseClass(data,i,_out,bs,icase,skipspaces,unicode,xml);
            Bitset.Unify(bs,term);
            return i;
        }
   
        internal static int ParseName(char[] data, int i, int _out, Term term, bool inverse, bool skipspaces) {
            StringBuilder sb = new StringBuilder();
            i=ParseName(data,i,_out,sb,skipspaces);
            Bitset bs=GetNamedClass(sb.ToString());
            if(bs==null) throw new PatternSyntaxException("unknown class: {"+sb+"}");
            Bitset.Unify(bs,term);
            term.inverse=inverse;
            return i;
        }

        private static int ParseClass(char[] data, int i, int _out, Bitset bs, bool icase, bool skipspaces, bool unicode, bool xml) {
            char c;
            int prev=-1;
            bool isFirst=true, setFirst=false, inRange=false;
            Bitset bs1=null;
            StringBuilder sb=null;
            for(;i<_out;isFirst=setFirst,setFirst=false){
                switch(c=data[i++]){
                case ']':
                    if(isFirst) break; //treat as normal char
                    if(inRange){
                        bs.SetChar('-');
                    }
                    if(prev>=0){
                        char c1=(char)prev;
                        if(icase){
                            bs.SetChar(char.ToLower(c1));
                            bs.SetChar(char.ToUpper(c1));
                        }
                        else bs.SetChar(c1);
                    }
                    return i;
               
                case '-':
                    if(isFirst) break;
                    if(inRange) break;
                    inRange=true;
                    continue;
               
                case '[':
                    if(inRange && xml) {
                        if(prev>=0) bs.SetChar((char)prev);
                        if(bs1==null) bs1 = new Bitset();
                        else bs1.Reset();
                        i=ParseClass(data,i,_out,bs1,icase,skipspaces,unicode,xml);
                        bs.Subtract(bs1);
                        inRange=false;
                        prev=-1;
                        continue;
                    }
                    else break;
               
                case '^':
                    if(isFirst){
                        bs.SetPositive(false);
                        setFirst=true;
                        continue;
                    }
                    break;
               
                case ' ':
                case '\r':
                case '\n':
                case '\t':
                case '\f':
                    if(skipspaces) continue;
                    else break;
                case '\\':
                    Bitset negatigeClass = null;
                    bool inv = false;
                    bool handle_special = false;
                    switch(c=data[i++]){
                    case 'r':
                        c='\r';
                        handle_special = true;
                        break;
                     
                    case 'n':
                        c='\n';
                        handle_special = true;
                        break;
                     
                    case 'e':
                        c='\u001B';
                        handle_special = true;
                        break;
                     
                    case 't':
                        c='\t';
                        handle_special = true;
                        break;
                     
                    case 'f':
                        c='\f';
                        handle_special = true;
                        break;
                     
                    case 'u':
                        if(i>=_out-4) throw  new PatternSyntaxException("incomplete escape sequence \\uXXXX");
                        c=(char)((ToHexDigit(c)<<12)
                                 +(ToHexDigit(data[i++])<<8)
                                 +(ToHexDigit(data[i++])<<4)
                                 +ToHexDigit(data[i++]));
                        handle_special = true;
                        break;
                     
                    case 'v':
                        c=(char)((ToHexDigit(c)<<24)+
                                 (ToHexDigit(data[i++])<<16)+
                                 (ToHexDigit(data[i++])<<12)+
                                 (ToHexDigit(data[i++])<<8)+
                                 (ToHexDigit(data[i++])<<4)+
                                 ToHexDigit(data[i++]));
                        handle_special = true;
                        break;
                     
                    case 'b':
                        c=(char)8; // backspace
                        handle_special = true;
                        break;

                    case 'x':{   // hex 2-digit number
                        int hex=0;
                        char d;
                        if((d=data[i++])=='{'){
                            while((d=data[i++])!='}'){
                                hex=(hex<<4)+ToHexDigit(d);
                            }
                            if(hex>0xffff) throw new PatternSyntaxException("\\x{<out of range>}");
                        }
                        else{
                            hex=(ToHexDigit(d)<<4)+ToHexDigit(data[i++]);
                        }
                        c=(char)hex;
                        handle_special = true;
                        break;
                    }
                    case '0':   // oct 2- or 3-digit number
                    case 'o':   // oct 2- or 3-digit number
                        int oct=0;
                        for(;;){
                            char d=data[i++];
                            if(d>='0' && d<='7'){
                                oct*=8;
                                oct+=d-'0';
                                if(oct>0xffff) break;
                            }
                            else {
                                i--;
                                break;
                            }
                        }
                        c=(char)oct;
                        handle_special = true;
                        break;
                     
                    case 'm':   // decimal number -> char
                        int dec=0;
                        for(;;){
                            char d=data[i++];
                            if(d>='0' && d<='9'){
                                dec*=10;
                                dec+=d-'0';
                                if(dec>0xffff) break;
                            } else {
                                i--;
                                break;
                            }
                        }
                        c=(char)dec;
                        handle_special = true;
                        break;
                     
                    case 'c':   // ctrl-char
                        c=(char)(data[i++]&0x1f);
                        handle_special = true;
                        break;
                  
                    case 'D':   // non-digit
                        negatigeClass = unicode ? UNONDIGIT : NONDIGIT;
                    break;
                     
                    case 'S':   // space
                        negatigeClass =unicode ? UNONSPACE : NONSPACE;
                    break;
                     
                    case 'W':   // space
                        negatigeClass = unicode ? UNONWORDCHAR : NONWORDCHAR;
                    break;
                     
                    case 'd':   // digit
                        if(inRange) throw new PatternSyntaxException("illegal range: [..."+prev+"-\\d...]");
                        bs.SetDigit(unicode);
                        continue;
                     
                    case 's':   // digit
                        if(inRange) throw new PatternSyntaxException("illegal range: [..."+prev+"-\\s...]");
                        bs.SetSpace(unicode);
                        continue;
                     
                    case 'w':   // digit
                        if(inRange) throw new PatternSyntaxException("illegal range: [..."+prev+"-\\w...]");
                        bs.SetWordChar(unicode);
                        continue;
                     
                    case 'P':   // \\P{..}
                        inv=true;
                        goto case 'p';
                    case 'p':   // \\p{..}
                        if(inRange) throw new PatternSyntaxException("illegal range: [..."+prev+"-\\w...]");
                        if(sb==null) sb = new StringBuilder();
                        else sb.Length = 0;
                        i=ParseName(data,i,_out,sb,skipspaces);
                        Bitset nc=GetNamedClass(sb.ToString());
                        if(nc==null) throw new PatternSyntaxException("unknown named class: {"+sb+"}");
                        bs.Add(nc,inv);
                        continue;
                     
                    default:
                        handle_special = true;
                        break;
                    }
                    if(handle_special) break;
                    if(inRange) throw new PatternSyntaxException("illegal range: [..."+prev+"-\\"+c+"...]");
                    bs.Add(negatigeClass);
                    continue;
                default:
                    break;
                }
                if(prev<0){
                    prev=c;
                    inRange=false;
                    continue;
                }
                if(!inRange){
                    char c1=(char)prev;
                    if(icase){
                        bs.SetChar(char.ToLower(c1));
                        bs.SetChar(char.ToUpper(c1));
                    }
                    else bs.SetChar(c1);
                    prev=c;
                }
                else {
                    if(prev>c) throw new PatternSyntaxException("illegal range: "+prev+">"+c);
                    char c0=(char)prev;
                    inRange=false;
                    prev=-1;
                    if(icase){
                        bs.SetRange(char.ToLower(c0),char.ToLower(c));
                        bs.SetRange(char.ToUpper(c0),char.ToUpper(c));
                    }
                    else bs.SetRange(c0,c);
                }
            }
            throw new PatternSyntaxException("unbalanced brackets in a class def");
        }
   
      
        internal static int ParseName(char[] data, int i, int _out, StringBuilder sb, bool skipspaces) {
            char c;
            int start=-1;
            while(i<_out){
                switch(c=data[i++]){
                case '{':
                    start=i;
                    continue;
                case '}':
                    return i;
                case ' ':
                case '\r':
                case '\n':
                case '\t':
                case '\f':
                    if(skipspaces) continue;
                    if(start<0) throw new PatternSyntaxException("named class doesn't start with '{'");
                    sb.Append(c);
                    break;
                    //else pass on
                default:
                    if(start<0) throw new PatternSyntaxException("named class doesn't start with '{'");
                    sb.Append(c);
                    break;
                }
            }
            throw new PatternSyntaxException("wrong class name: "+new string(data,i,_out-i));
        }
   
        internal static string StringValue0(bool[] arr){
            StringBuilder b = new StringBuilder();
            int c=0;
            bool quit = false;
            
            for(;;){
                while(!arr[c]){
                    c++;
                    if(c>=0xff) {quit = true; break;}
                }
                if(quit) break;
                int first=c;
                while(arr[c]){
                    c++;
                    if(c>0xff) break;
                }     
                int last=c-1;
                if(last==first) b.Append(StringValue(last));
                else{
                    b.Append(StringValue(first));
                    b.Append('-');
                    b.Append(StringValue(last));
                }
                if(c>0xff) break;
            }
            return b.ToString();
        }
   
        internal static string StringValue2(bool[][] arr){
            StringBuilder b=new StringBuilder();
            int c=0;
            bool quit = false;
            for(;;){
                for(;;){
                    bool[] marks=arr[c>>8];
                    if(marks!=null && marks[c&255]) break;
                    c++;
                    if(c>0xffff) {quit = true; break;}
                }
                if(quit) break;
                int first=c;
                for(;c<=0xffff;){
                    bool[] marks=arr[c>>8];
                    if(marks==null || !marks[c&255]) break;
                    c++;
                }
                int last=c-1;
                if(last==first) b.Append(StringValue(last));
                else{
                    b.Append(StringValue(first));
                    b.Append('-');
                    b.Append(StringValue(last));
                }
                if(c>0xffff) break;
            }
            return b.ToString();
        }
   
        internal static string StringValue(int c){
            StringBuilder b=new StringBuilder(5);
            if(c<32){
                switch(c){
                case '\r':
                    b.Append("\\r");
                    break;
                case '\n':
                    b.Append("\\n");
                    break;
                case '\t':
                    b.Append("\\t");
                    break;
                case '\f':
                    b.Append("\\f");
                    break;
                default:
                    b.Append('(');
                    b.Append((int)c);
                    b.Append(')');
                    break;
                }
            }
            else if(c<256){
                b.Append((char)c);
            }
            else{
                b.Append('\\');
                b.Append('x');
                b.Append(Convert.ToString(c, 16));
            }
            return b.ToString();
        }
   
        internal static int ToHexDigit(char d) {
            int val=0;
            if(d>='0' && d<='9') val=d-'0';
            else if(d>='a' && d<='f') val=10+d-'a';
            else if(d>='A' && d<='F') val=10+d-'A';
            else throw new PatternSyntaxException("hexadecimal digit expected: "+d);
            return val;
        }
    }
}
