
namespace Ioke.Lang {
    public class Symbol : IokeData {
        readonly string text;

        public Symbol(string text) {
            this.text = text;
        }

        public override void Init(IokeObject obj) {
            obj.Kind = "Symbol";

            obj.RegisterMethod(obj.runtime.NewNativeMethod("Returns a text representation of the object", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("asText", obj,
                                                                                                        (method, on, args, keywords, context, message) => {
                                                                                                            return method.runtime.NewText(Symbol.GetText(on));
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("Returns a text inspection of the object", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("inspect", obj,
                                                                                                        (method, on, args, keywords, context, message) => {
                                                                                                            return method.runtime.NewText(Symbol.GetInspect(on));
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("Returns a brief text inspection of the object", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("notice", obj,
                                                                                                        (method, on, args, keywords, context, message) => {
                                                                                                            return method.runtime.NewText(Symbol.GetInspect(on));
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("compares this symbol against the argument, returning -1, 0 or 1 based on which one is lexically larger", 
                                                           new TypeCheckingNativeMethod ("<=>", TypeCheckingArgumentsDefinition.builder()
                                                                                         .ReceiverMustMimic(obj)
                                                                                         .WithRequiredPositional("other")
                                                                                         .Arguments,
                                                                                         (method, on, args, keywords, context, message) => {
                                                                                                 object arg = args[0];

                                                                                                 if(!(IokeObject.dataOf(arg) is Symbol)) {
                                                                                                     arg = IokeObject.ConvertToSymbol(arg, message, context, false);
                                                                                                     if(!(IokeObject.dataOf(arg) is Symbol)) {
                                                                                                         // Can't compare, so bail out
                                                                                                         return context.runtime.nil;
                                                                                                     }
                                                                                                 }
                                                                                                 return context.runtime.NewNumber(string.CompareOrdinal(Symbol.GetText(on), Symbol.GetText(arg)));
                                                                                             })));
        }

        public static string GetText(object on) {
            return ((Symbol)(IokeObject.dataOf(on))).GetText();
        }

        public static string GetInspect(object on) {
            return ((Symbol)(IokeObject.dataOf(on))).Inspect(on);
        }

        public string GetText() {
            return text;
        }

        public override bool IsSymbol {get{return true;}}

        public override void CheckMimic(IokeObject obj, IokeObject m, IokeObject context) {
            IokeObject condition = IokeObject.As(IokeObject.GetCellChain(context.runtime.Condition, 
                                                                         m, 
                                                                         context,
                                                                         "Error", 
                                                                         "CantMimicOddball"), context).Mimic(m, context);
            condition.SetCell("message", m);
            condition.SetCell("context", context);
            condition.SetCell("receiver", obj);
            context.runtime.ErrorCondition(condition);
        }

        public override IokeObject ConvertToSymbol(IokeObject self, IokeObject m, IokeObject context, bool signalCondition) {
            return self;
        }

        public override IokeObject ConvertToText(IokeObject self, IokeObject m, IokeObject context, bool signalCondition) {
            return self.runtime.NewText(GetText());
        }

        public override IokeObject TryConvertToText(IokeObject self, IokeObject m, IokeObject context) {
            return self.runtime.NewText(GetText());
        }

        public readonly static System.Text.RegularExpressions.Regex BAD_CHARS = new System.Text.RegularExpressions.Regex("[!=\\.:\\-\\+&|\\{\\[]");
        public static bool OnlyGoodChars(object sym) {
            string text = Symbol.GetText(sym);
            return !(text.Length == 0 || BAD_CHARS.Match(text).Success);
        }

        public override string ToString() {
            return text;
        }

        public override string ToString(IokeObject obj) {
            return text;
        }

        public string Inspect(object obj) {
            if(!Symbol.OnlyGoodChars(obj)) {
                return ":\"" + text + "\"";
            } else {
                return ":" + text;
            }
        }
    }
}
