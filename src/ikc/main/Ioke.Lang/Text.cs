
namespace Ioke.Lang {
    using NRegex;
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.Text;

    using Ioke.Lang.Util;

    internal class UnicodeBlock {
        private static readonly string blockData = 
            "0000..007F:BASIC_LATIN;0080..00FF:LATIN_1_SUPPLEMENT;0100..017F:LATIN_EXTENDED_A;"
            +"0180..024F:LATIN_EXTENDED_B;0250..02AF:IPA_EXTENSIONS;02B0..02FF:SPACING_MODIFIER_LETTERS;"
            +"0300..036F:COMBINING_DIACRITICAL_MARKS;0370..03FF:GREEK;0400..04FF:CYRILLIC;0530..058F:ARMENIAN;"
            +"0590..05FF:HEBREW;0600..06FF:ARABIC;0700..074F:SYRIAC;0780..07BF:THAANA;0900..097F:DEVANAGARI;"
            +"0980..09FF:BENGALI;0A00..0A7F:GURMUKHI;0A80..0AFF:GUJARATI;0B00..0B7F:ORIYA;0B80..0BFF:TAMIL;"
            +"0C00..0C7F:TELUGU;0C80..0CFF:KANNADA;0D00..0D7F:MALAYALAM;0D80..0DFF:SINHALA;0E00..0E7F:THAI;"
            +"0E80..0EFF:LAO;0F00..0FFF:TIBETAN;1000..109F:MYANMAR;10A0..10FF:GEORGIAN;1100..11FF:HANGULJAMO;"
            +"1200..137F:ETHIOPIC;13A0..13FF:CHEROKEE;1400..167F:UNIFIED_CANADIAN_ABORIGINAL_SYLLABICS;"
            +"1680..169F:OGHAM;16A0..16FF:RUNIC;1780..17FF:KHMER;1800..18AF:MONGOLIAN;"
            +"1E00..1EFF:LATIN_EXTENDED_ADDITIONAL;1F00..1FFF:GREEK_EXTENDED;2000..206F:GENERAL_PUNCTUATION;"
            +"2070..209F:SUPERSCRIPTS_AND_SUBSCRIPTS;20A0..20CF:CURRENCY_SYMBOLS;"
            +"20D0..20FF:COMBINING_MARKS_FOR_SYMBOLS;2100..214F:LETTERLIKE_SYMBOLS;2150..218F:NUMBER_FORMS;"
            +"2190..21FF:ARROWS;2200..22FF:MATHEMATICAL_OPERATORS;2300..23FF:MISCELLANEOUS_TECHNICAL;"
            +"2400..243F:CONTROL_PICTURES;2440..245F:OPTICAL_CHARACTER_RECOGNITION;"
            +"2460..24FF:ENCLOSED_ALPHANUMERICS;2500..257F:BOX_DRAWING;2580..259F:BLOCK_ELEMENTS;"
            +"25A0..25FF:GEOMETRIC_SHAPES;2600..26FF:MISCELLANEOUS_SYMBOLS;2700..27BF:DINGBATS;"
            +"2800..28FF:BRAILLE_PATTERNS;2E80..2EFF:CJK_RADICALS_SUPPLEMENT;2F00..2FDF:KANGXI_RADICALS;"
            +"2FF0..2FFF:IDEOGRAPHIC_DESCRIPTION_CHARACTERS;3000..303F:CJK_SYMBOLS_AND_PUNCTUATION;"
            +"3040..309F:HIRAGANA;30A0..30FF:KATAKANA;3100..312F:BOPOMOFO;3130..318F:HANGUL_COMPATIBILITY_JAMO;"
            +"3190..319F:KANBUN;31A0..31BF:BOPOMOFO_EXTENDED;3200..32FF:ENCLOSED_CJK_LETTERS_AND_MONTHS;"
            +"3300..33FF:CJK_COMPATIBILITY;3400..4DB5:CJK_UNIFIED_IDEOGRAPHS_EXTENSION_A;"
            +"4E00..9FFF:CJK_UNIFIED_IDEOGRAPHS;A000..A48F:YI_SYLLABLES;A490..A4CF:YI_RADICALS;"
            +"AC00..D7A3:HANGUL_SYLLABLES;D800..DB7F:HIGH_SURROGATES;DB80..DBFF:HIGH_PRIVATE_USE_SURROGATES;"
            +"DC00..DFFF:LOW_SURROGATES;E000..F8FF:PRIVATE_USE_AREA;F900..FAFF:CJK_COMPATIBILITY_IDEOGRAPHS;"
            +"FB00..FB4F:ALPHABETIC_PRESENTATION_FORMS;FB50..FDFF:ARABIC_PRESENTATION_FORMS_A;"
            +"FE20..FE2F:COMBINING_HALF_MARKS;FE30..FE4F:CJK_COMPATIBILITY_FORMS;FE50..FE6F:SMALL_FORM_VARIANTS;"
            +"FE70..FEFE:ARABIC_PRESENTATION_FORMS_B;FEFF..FEFF:SPECIALS;FF00..FFEF:HALFWIDTH_AND_FULLWIDTH_FORMS;"
            +"FFF0..FFFD:SPECIALS";

        private static string[] blocks = new string[65536];

        static UnicodeBlock() {
            string[] separate = blockData.Split(';');
            foreach(string part in separate) {
                string[] parts = part.Split(':');
                string name = parts[1];
                int firstIndex = Convert.ToInt32(parts[0].Substring(0,4), 16); 
                int lastIndex = Convert.ToInt32(parts[0].Substring(6,4), 16);
                for(; firstIndex <= lastIndex; firstIndex++) {
                    blocks[firstIndex] = name;
                }
            }
        }

        public static string Of(char c) {
            return blocks[(int)c];
        }
    }

    public class Text : IokeData {
        private readonly string text;
        
        public Text(string text) {
            this.text = text;
        }

        public static string GetText(object on) {
            return ((Text)(IokeObject.dataOf(on))).GetText();
        }

        public string GetText() {
            return text;
        }

        public static bool IsText(object on) {
            return IokeObject.dataOf(on) is Text;
        }

        public override string ToString(IokeObject self) {
            return text;
        }

        public override bool IsEqualTo(IokeObject self, object other) {
            return ((other is IokeObject) && 
                    (IokeObject.dataOf(other) is Text) 
                    && ((self == self.runtime.Text || other == self.runtime.Text) ? self == other :
                        this.text.Equals(((Text)IokeObject.dataOf(other)).text)));
        }
        
        public override int HashCode(IokeObject self) {
            return this.text.GetHashCode();
        }

        public override void Init(IokeObject obj) {
            Runtime runtime = obj.runtime;
            
            obj.Kind = "Text";
            obj.Mimics(IokeObject.As(runtime.Mixins.GetCell(null, null, "Comparing"), null), runtime.nul, runtime.nul);
            obj.SetCell("==",        runtime.Base.Cells["=="]);

            obj.RegisterMethod(runtime.NewNativeMethod("Returns a text representation of the object", 
                                                       new NativeMethod.WithNoArguments("asText",
                                                                                        (method, context, message, on, outer) => {
                                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, new SaneArrayList(), new SaneDictionary<string, object>());
                                                                                            return on;
                                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("Takes any number of arguments, and expects the text receiver to contain format specifications. The currently supported specifications are only %s and %{, %}. These have several parameters that can be used. See the spec for more info about these. The format method will return a new text based on the content of the receiver, and the arguments given.", 
                                                       new TypeCheckingNativeMethod("format", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithRest("replacements")
                                                                                    .Arguments,
                                                                                    (self, on, args, keywords, context, message) => {
                                                                                        StringBuilder result = new StringBuilder();
                                                                                        Format(on, message, context, args, result);
                                                                                        return context.runtime.NewText(result.ToString());
                                                                                    })));


            obj.RegisterMethod(obj.runtime.NewNativeMethod("Converts the content of this text into a rational value", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("toRational", obj,
                                                                                                        (self, on, args, keywords, context, message) => {
                                                                                                            return Text.ToRational(on, context, message);
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("Converts the content of this text into a decimal value", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("toDecimal", obj,
                                                                                                        (self, on, args, keywords, context, message) => {
                                                                                                            return Text.ToDecimal(on, context, message);
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("Returns a text inspection of the object", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("inspect", obj,
                                                                                                        (self, on, args, keywords, context, message) => {
                                                                                                            return self.runtime.NewText(Text.GetInspect(on));
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("Returns a brief text inspection of the object", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("notice", obj,
                                                                                                        (self, on, args, keywords, context, message) => {
                                                                                                            return self.runtime.NewText(Text.GetInspect(on));
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("Returns a lower case version of this text", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("lower", obj,
                                                                                                        (self, on, args, keywords, context, message) => {
                                                                                                            return self.runtime.NewText(Text.GetText(on).ToLower());
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("Returns an upper case version of this text", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("upper", obj,
                                                                                                        (self, on, args, keywords, context, message) => {
                                                                                                            return self.runtime.NewText(Text.GetText(on).ToUpper());
                                                                                                        })));
            
            obj.RegisterMethod(obj.runtime.NewNativeMethod("Returns a version of this text with leading and trailing whitespace removed", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("trim", obj,
                                                                                                        (self, on, args, keywords, context, message) => {
                                                                                                            return self.runtime.NewText(Text.GetText(on).Trim());
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("Returns an array of texts split around the argument", 
                                                           new TypeCheckingNativeMethod("split", TypeCheckingArgumentsDefinition.builder()
                                                                                        .ReceiverMustMimic(obj)
                                                                                        .WithOptionalPositional("splitAround", "")
                                                                                        .Arguments,
                                                                                        (self, on, args, keywords, context, message) => {
                                                                                            string real = Text.GetText(on);
                                                                                            var r = new SaneArrayList();
                                                                                            Pattern p = null;

                                                                                            if(args.Count == 0) {
                                                                                                p = new Pattern("\\s");
                                                                                            } else {
                                                                                                object arg = args[0];
                                                                                                if(IokeObject.dataOf(arg) is Regexp) {
                                                                                                    p = Regexp.GetRegexp(arg);
                                                                                                } else {
                                                                                                    string around = Text.GetText(arg);
                                                                                                    p = new Pattern(Pattern.Quote(around));
                                                                                                }
                                                                                            }

                                                                                            RETokenizer tok = new RETokenizer(p, real);
                                                                                            tok.EmptyEnabled = false;
                                                                                            while(tok.HasMore) {
                                                                                                r.Add(context.runtime.NewText(tok.NextToken));
                                                                                            }

                                                                                            return context.runtime.NewList(r);
                                                                                        })));
            
            obj.RegisterMethod(obj.runtime.NewNativeMethod("Takes two text arguments where the first is the substring to replace, and the second is the replacement to insert. Will only replace the first match, if any is found, and return a new Text with the result.", 
                                                           new TypeCheckingNativeMethod("replace", TypeCheckingArgumentsDefinition.builder()
                                                                                        .ReceiverMustMimic(obj)
                                                                                        .WithRequiredPositional("pattern")
                                                                                        .WithRequiredPositional("replacement")
                                                                                        .Arguments,
                                                                                        (self, on, args, keywords, context, message) => {
                                                                                            string initial = Text.GetText(on);
                                                                                            string repl = Text.GetText(args[1]);

                                                                                            object arg = args[0];

                                                                                            Pattern pat = null;
                                                                                            if(IokeObject.dataOf(arg) is Regexp) {
                                                                                                pat = Regexp.GetRegexp(arg);
                                                                                            } else {
                                                                                                string around = Text.GetText(arg);
                                                                                                pat = new Pattern(Pattern.Quote(around));
                                                                                            }

                                                                                            Replacer r = pat.Replacer(repl);
                                                                                            string result = r.ReplaceFirst(initial);

                                                                                            return context.runtime.NewText(result);
                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("Takes two text arguments where the first is the substring to replace, and the second is the replacement to insert. Will replace all matches, if any is found, and return a new Text with the result.", 
                                                           new TypeCheckingNativeMethod("replaceAll", TypeCheckingArgumentsDefinition.builder()
                                                                                        .ReceiverMustMimic(obj)
                                                                                        .WithRequiredPositional("pattern")
                                                                                        .WithRequiredPositional("replacement")
                                                                                        .Arguments,
                                                                                        (self, on, args, keywords, context, message) => {
                                                                                            string initial = Text.GetText(on);
                                                                                            string repl = Text.GetText(args[1]);

                                                                                            object arg = args[0];

                                                                                            Pattern pat = null;
                                                                                            if(IokeObject.dataOf(arg) is Regexp) {
                                                                                                pat = Regexp.GetRegexp(arg);
                                                                                            } else {
                                                                                                string around = Text.GetText(arg);
                                                                                                pat = new Pattern(Pattern.Quote(around));
                                                                                            }

                                                                                            Replacer r = pat.Replacer(repl);
                                                                                            String result = r.Replace(initial);

                                                                                            return context.runtime.NewText(result);
                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("Returns the length of this text", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("length", obj,
                                                                                                        (self, on, args, keywords, context, message) => {
                                                                                                            return context.runtime.NewNumber(GetText(on).Length);
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("compares this text against the argument, returning -1, 0 or 1 based on which one is lexically larger", 
                                                           new TypeCheckingNativeMethod("<=>", TypeCheckingArgumentsDefinition.builder()
                                                                                        .ReceiverMustMimic(obj)
                                                                                        .WithRequiredPositional("other")
                                                                                        .Arguments,
                                                                                        (self, on, args, keywords, context, message) => {
                                                                                            object arg = args[0];

                                                                                            if(!(IokeObject.dataOf(arg) is Text)) {
                                                                                                arg = IokeObject.ConvertToText(arg, message, context, false);
                                                                                                if(!(IokeObject.dataOf(arg) is Text)) {
                                                                                                    // Can't compare, so bail out
                                                                                                    return context.runtime.nil;
                                                                                                }
                                                                                            }

                                                                                            if(on == context.runtime.Text || arg == context.runtime.Text) {
                                                                                                if(on == arg) {
                                                                                                    return context.runtime.NewNumber(0);
                                                                                                }
                                                                                                return context.runtime.nil;
                                                                                            }

                                                                                            int result = string.CompareOrdinal(Text.GetText(on), Text.GetText(arg));
                                                                                            if(result < 0) {
                                                                                                result = -1;
                                                                                            } else if(result > 0) {
                                                                                                result = 1;
                                                                                            }

                                                                                            return context.runtime.NewNumber(result);
                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("takes one argument, that can be either an index or a range of two indicis. this slicing works the same as for Lists, so you can index from the end, both with the single index and with the range.", 
                                                           new TypeCheckingNativeMethod("[]", TypeCheckingArgumentsDefinition.builder()
                                                                                        .ReceiverMustMimic(obj)
                                                                                        .WithRequiredPositional("index")
                                                                                        .Arguments,
                                                                                        (self, on, args, keywords, context, message) => {
                                                                                            object arg = args[0];
                                                                                            IokeData data = IokeObject.dataOf(arg);
                    
                                                                                            if(data is Range) {
                                                                                                int first = Number.ExtractInt(Range.GetFrom(arg), message, context); 
                        
                                                                                                if(first < 0) {
                                                                                                    return context.runtime.NewText("");
                                                                                                }

                                                                                                int last = Number.ExtractInt(Range.GetTo(arg), message, context);
                                                                                                bool inclusive = Range.IsInclusive(arg);

                                                                                                string str = GetText(on);
                                                                                                int size = str.Length;

                                                                                                if(last < 0) {
                                                                                                    last = size + last;
                                                                                                }

                                                                                                if(last < 0) {
                                                                                                    return context.runtime.NewText("");
                                                                                                }

                                                                                                if(last >= size) {
                                                                                                    last = inclusive ? size-1 : size;
                                                                                                }

                                                                                                if(first > last || (!inclusive && first == last)) {
                                                                                                    return context.runtime.NewText("");
                                                                                                }
                        
                                                                                                if(!inclusive) {
                                                                                                    last--;
                                                                                                }
                        
                                                                                                return context.runtime.NewText(str.Substring(first, (last+1)-first));
                                                                                            } else if(data is Number) {
                                                                                                string str = GetText(on);
                                                                                                int len = str.Length;

                                                                                                int ix = ((Number)data).AsNativeInteger();

                                                                                                if(ix < 0) {
                                                                                                    ix = len + ix;
                                                                                                }

                                                                                                if(ix >= 0 && ix < len) {
                                                                                                    return context.runtime.NewNumber(str[ix]);
                                                                                                } else {
                                                                                                    return context.runtime.nil;
                                                                                                }
                                                                                            }

                                                                                            return on;
                                                                                        })));
        
            obj.RegisterMethod(obj.runtime.NewNativeMethod("Returns a symbol representing the Unicode category of the character", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("category", obj,
                                                                                                        (self, on, args, keywords, context, message) => {
                                                                                                            string character = GetText(on);
                                                                                                            if(character.Length == 1) {
                                                                                                                return context.runtime.GetSymbol(UnicodeBlock.Of(character[0]));                  
                                                                                                            }
                
                                                                                                            IokeObject condition = IokeObject.As(IokeObject.GetCellChain(runtime.Condition, 
                                                                                                                                                                         message,
                                                                                                                                                                         context,
                                                                                                                                                                         "Error",
                                                                                                                                                                         "Default"), context).Mimic(message, context);
                                                                                                            condition.SetCell("message", message);
                                                                                                            condition.SetCell("context", context);
                                                                                                            condition.SetCell("receiver", on);
                                                                                                            condition.SetCell("text", context.runtime.NewText("Text does not contain exactly one character"));

                                                                                                            runtime.ErrorCondition(condition);
                                                                                                            return null;
                                                                                                        })));
        }

        public static string GetInspect(object on) {
            return ((Text)(IokeObject.dataOf(on))).Inspect(on);
        }

        public override IokeObject ConvertToText(IokeObject self, IokeObject m, IokeObject context, bool signalCondition) {
            return self;
        }

        public override IokeObject TryConvertToText(IokeObject self, IokeObject m, IokeObject context) {
            return self;
        }

        public static void Format(object on, IokeObject message, IokeObject context, IList positionalArgs, StringBuilder result) {
            FormatString(Text.GetText(on), 0, message, context, positionalArgs, result);
        }

        private delegate object DoEvaluation (IokeObject ctx, object ground, object receiver);
        private class EvaluatingMessage : Message {
            private DoEvaluation code;
            public EvaluatingMessage(Runtime runtime, string name, DoEvaluation code) : base(runtime, name) {
                this.code = code;
            }

            public override object EvaluateCompleteWithReceiver(IokeObject self, IokeObject ctx, object ground, object receiver) {
                return code(ctx, ground, receiver);
            }                                

            public override object EvaluateCompleteWith(IokeObject self, IokeObject ctx, object ground) {
                return code(ctx, ground, ctx);
            }                                
        }

        private static int FormatString(string format, int index, IokeObject message, IokeObject context, IList positionalArgs, StringBuilder result) {
            int argIndex = 0;
            int formatIndex = index;
            int justify = 0;
            bool splat = false;
            bool splatPairs = false;
            bool negativeJustify = false;
            bool doAgain = false;
            int formatLength = format.Length;
            object arg = null;
            StringBuilder missingText = new StringBuilder();

            while(formatIndex < formatLength) {
                char c = format[formatIndex++];
                switch(c) {
                case '%':
                    justify = 0;
                    missingText.Append(c);
                    do {
                        doAgain = false;
                        if(formatIndex < formatLength) {
                            c = format[formatIndex++];
                            missingText.Append(c);
                        
                            switch(c) {
                            case '*':
                                splat = true;
                                doAgain = true;
                                break;
                            case ':':
                                splatPairs = true;
                                doAgain = true;
                                break;
                            case ']':
                                return formatIndex;
                            case '[':
                                arg = positionalArgs[argIndex++];
                                int startLoop = formatIndex;
                                int endLoop = -1;
                                bool doSplat = splat;
                                bool doSplatPairs = splatPairs;
                                splat = false;
                                splatPairs = false;
                                ((Message)IokeObject.dataOf(context.runtime.eachMessage)).SendTo(context.runtime.eachMessage, context, arg, 
                                                                                                 context.runtime.CreateMessage(
                                                                                                                               new EvaluatingMessage(context.runtime, "internal:collectDataForText#format", 
                                                                                                                                                     (ctx, ground, receiver) => {
                                                                                                                                                         IList args = null;
                                                                                                                                                         if(doSplat) {
                                                                                                                                                             args = IokeList.GetList(receiver);
                                                                                                                                                         } else if(doSplatPairs) {
                                                                                                                                                             args = new SaneArrayList() {Pair.GetFirst(receiver), Pair.GetSecond(receiver)};
                                                                                                                                                         } else {
                                                                                                                                                             args = new SaneArrayList() {receiver};
                                                                                                                                                         }

                                                                                                                                                         int newVal = FormatString(format, startLoop, message, context, args, result);
                                                                                                                                                         endLoop = newVal;
                                                                                                                                                         return ctx.runtime.nil;
                                                                                                                                                     })));
                                if(endLoop == -1) {
                                    int opened = 1;
                                    while(opened > 0 && formatIndex < formatLength) {
                                        char c2 = format[formatIndex++];
                                        if(c2 == '%' && formatIndex < formatLength) {
                                            c2 = format[formatIndex++];
                                            if(c2 == '[') {
                                                opened++;
                                            } else if(c2 == ']') {
                                                opened--;
                                            }
                                        }
                                    }
                                } else {
                                    formatIndex = endLoop;
                                }
                                break;
                            case 's':
                                arg = positionalArgs[argIndex++];
                                object txt = IokeObject.TryConvertToText(arg, message, context);
                                if(txt == null) {
                                    txt = ((Message)IokeObject.dataOf(context.runtime.asText)).SendTo(context.runtime.asText, context, arg);
                                }
                                string outTxt = Text.GetText(txt);

                                if(outTxt.Length < justify) {
                                    int missing = justify - outTxt.Length;
                                    char[] spaces = new char[missing];
                                    for(int ixx=0; ixx<spaces.Length; ixx++) spaces[ixx] = ' ';
                                    if(negativeJustify) {
                                        result.Append(outTxt);
                                        result.Append(spaces);
                                    } else {
                                        result.Append(spaces);
                                        result.Append(outTxt);
                                    }
                                } else {
                                    result.Append(outTxt);
                                }
                                break;
                            case '0':
                            case '1':
                            case '2':
                            case '3':
                            case '4':
                            case '5':
                            case '6':
                            case '7':
                            case '8':
                            case '9':
                                justify *= 10;
                                justify += (c - '0');
                                doAgain = true;
                                break;
                            case '-':
                                negativeJustify = !negativeJustify;
                                doAgain = true;
                                break;
                            default:
                                result.Append(missingText);
                                missingText = new StringBuilder();
                                break;
                            }
                        } else {
                            result.Append(missingText);
                            missingText = new StringBuilder();
                        }
                    } while(doAgain);
                    break;
                default:
                    result.Append(c);
                    break;
                }
            }
            return formatLength;
        }


        private class TakeLongestRational : Restart.ArgumentGivingRestart {
            string namex;
            object[] place;
            public TakeLongestRational(string name, object[] place) : base("takeLongest") {
                this.namex = name;
                this.place = place;
            }

            public override string Report() {
                return "Parse the longest number possible from " + namex;
            }
            
            public override IList<string> ArgumentNames {
                get { return new SaneList<string>(); }
            }

            public override IokeObject Invoke(IokeObject context, IList arguments) {
                int ix = 0;
                int len = namex.Length;
                while(ix < len) {
                    char c = namex[ix];
                    switch(c) {
                    case '-':
                    case '+':
                        if(ix != 0) {
                            goto breakOuter;
                        }
                        break;
                    case '0':
                    case '1':
                    case '2':
                    case '3':
                    case '4':
                    case '5':
                    case '6':
                    case '7':
                    case '8':
                    case '9':
                        break;
                    default:
                        goto breakOuter;
                    }
                    ix++;
                }
                breakOuter:
                place[0] = context.runtime.NewNumber(namex.Substring(0, ix));
                return context.runtime.nil;
            }
        }

        private class TakeLongestDecimal : Restart.ArgumentGivingRestart {
            string namex;
            object[] place;
            public TakeLongestDecimal(string name, object[] place) : base("takeLongest") {
                this.namex = name;
                this.place = place;
            }

            public override string Report() {
                return "Parse the longest number possible from " + namex;
            }
            
            public override IList<string> ArgumentNames {
                get { return new SaneList<string>(); }
            }

            public override IokeObject Invoke(IokeObject context, IList arguments) {
                int ix = 0;
                int len = namex.Length;
                bool hadDot = false;
                bool hadE = false;
                while(ix < len) {
                    char c = namex[ix];
                    switch(c) {
                    case '-':
                    case '+':
                        if(ix != 0 && namex[ix-1] != 'e' && namex[ix-1] != 'E') {
                            goto breakOuter;
                        }
                        break;
                    case '0':
                    case '1':
                    case '2':
                    case '3':
                    case '4':
                    case '5':
                    case '6':
                    case '7':
                    case '8':
                    case '9':
                        break;
                    case '.':
                        if(hadDot || hadE) {
                            goto breakOuter;
                        }
                        hadDot = true;
                        break;
                    case 'e':
                    case 'E':
                        if(hadE) {
                            goto breakOuter;
                        }
                        hadE = true;
                        break;
                    default:
                        goto breakOuter;
                    }
                    ix++;
                }
                breakOuter:
                place[0] = context.runtime.NewDecimal(namex.Substring(0, ix));
                return context.runtime.nil;
            }
        }

        public static object ToRational(object on, IokeObject context, IokeObject message) {
            string tvalue = GetText(on);
            try {
                return context.runtime.NewNumber(tvalue);
            } catch(Exception) {
                Runtime runtime = context.runtime;
                IokeObject condition = IokeObject.As(IokeObject.GetCellChain(runtime.Condition, 
                                                                             message, 
                                                                             context, 
                                                                             "Error", 
                                                                             "Arithmetic",
                                                                             "NotParseable"), context).Mimic(message, context);
                condition.SetCell("message", message);
                condition.SetCell("context", context);
                condition.SetCell("receiver", on);
                condition.SetCell("text", on);

                object[] newCell = new object[]{null};

                runtime.WithRestartReturningArguments(()=>{runtime.ErrorCondition(condition);},
                                                      context,
                                                      new IokeObject.UseValue("rational", newCell),
                                                      new TakeLongestRational(tvalue, newCell));
                return newCell[0];
            }
        }

        public static object ToDecimal(object on, IokeObject context, IokeObject message) {
            string tvalue = GetText(on);
            try {
                return context.runtime.NewDecimal(tvalue);
            } catch(Exception) {
                Runtime runtime = context.runtime;
                IokeObject condition = IokeObject.As(IokeObject.GetCellChain(runtime.Condition, 
                                                                             message, 
                                                                             context, 
                                                                             "Error", 
                                                                             "Arithmetic",
                                                                             "NotParseable"), context).Mimic(message, context);
                condition.SetCell("message", message);
                condition.SetCell("context", context);
                condition.SetCell("receiver", on);
                condition.SetCell("text", on);

                object[] newCell = new object[]{null};

                runtime.WithRestartReturningArguments(()=>{runtime.ErrorCondition(condition);},
                                                      context,
                                                      new IokeObject.UseValue("decimal", newCell),
                                                      new TakeLongestDecimal(tvalue, newCell));
                return newCell[0];
            }
        }

        public string Inspect(object obj) {
            return "\"" + new StringUtils().Escape(text) + "\"";
        }
    }
}
