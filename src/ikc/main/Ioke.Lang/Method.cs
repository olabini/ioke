
namespace Ioke.Lang {
    public class Method : IokeData, Named, Inspectable {
        protected string name;

        public Method(string name) {
            this.name = name;
        }

        public Method(IokeObject context) : this((string)null) {
        }

        public override void Init(IokeObject obj) {
            obj.Kind = "Method";
            obj.RegisterCell("activatable", obj.runtime.True);

            obj.RegisterMethod(obj.runtime.NewNativeMethod("activates this method with the arguments given to call", 
                                                           new NativeMethod("call", DefaultArgumentsDefinition.builder()
                                                                            .WithRestUnevaluated("arguments")
                                                                            .Arguments,
                                                                            (method, _context, message, on, outer) => {
                                                                                return IokeObject.As(on, _context).Activate(_context, message, _context.RealContext);
                                                                            })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the name of the method", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("name", obj,
                                                                                                        (method, on, args, keywords, _context, message) => {
                                                                                                            return _context.runtime.NewText(((Method)IokeObject.dataOf(on)).name);
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("Returns a text inspection of the object", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("inspect", obj,
                                                                                                        (method, on, args, keywords, _context, message) => {
                                                                                                            return _context.runtime.NewText(Method.GetInspect(on));
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("Returns a brief text inspection of the object", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("notice", obj,
                                                                                                        (method, on, args, keywords, _context, message) => {
                                                                                                            return _context.runtime.NewText(Method.GetNotice(on));
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the full code of this method, as a Text", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("code", obj,
                                                                                                        (method, on, args, keywords, _context, message) => {
                                                                                                            IokeData data = IokeObject.dataOf(on);
                                                                                                            if(data is Method) {
                                                                                                                return _context.runtime.NewText(((Method)data).CodeString);
                                                                                                            } else {
                                                                                                                return _context.runtime.NewText(((AliasMethod)data).CodeString);
                                                                                                            }
                                                                                                        })));
        }
        
        public virtual string CodeString {
            get { return "method(nil)"; }
        }

        public string Name {
            get { return name; }
            set { this.name = value; }
        }

        public override object Activate(IokeObject self, IokeObject context, IokeObject message, object on) {
            IokeObject condition = IokeObject.As(IokeObject.GetCellChain(context.runtime.Condition, 
                                                                         message, 
                                                                         context, 
                                                                         "Error", 
                                                                         "Invocation",
                                                                         "NotActivatable"), context).Mimic(message, context);
            condition.SetCell("message", message);
            condition.SetCell("context", context);
            condition.SetCell("receiver", on);
            condition.SetCell("method", self);
            condition.SetCell("report", context.runtime.NewText("You tried to activate a method without any code - did you by any chance activate the Method kind by referring to it without wrapping it inside a call to cell?"));
            context.runtime.ErrorCondition(condition);

            return self.runtime.nil;
        }

    public static string GetInspect(object on) {
        return ((Inspectable)(IokeObject.dataOf(on))).Inspect(on);
    }

    public static string GetNotice(object on) {
        return ((Inspectable)(IokeObject.dataOf(on))).Notice(on);
    }

    public virtual string Inspect(object self) {
        return CodeString;
    }

    public virtual string Notice(object self) {
        if(name == null) {
            return "method(...)";
        } else {
            return name + ":method(...)";
        }
    }
    }
}
