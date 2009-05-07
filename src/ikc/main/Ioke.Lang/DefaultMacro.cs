namespace Ioke.Lang {
    using System.Collections;
    using System.Collections.Generic;

    using Ioke.Lang.Util;

    public class DefaultMacro : IokeData, Named, Inspectable, AssociatedCode {
        string name;
        IokeObject code;

        public DefaultMacro(string name) {
            this.name = name;
        }

        public DefaultMacro(IokeObject context, IokeObject code) : this((string)null) {
            this.code = code;
        }

        public override void Init(IokeObject obj) {
            obj.Kind = "DefaultMacro";
            obj.RegisterCell("activatable", obj.runtime.True);

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the name of the macro", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("name", obj,
                                                                                                        (method, on, args, keywords, _context, message) => {
                                                                                                            return _context.runtime.NewText(((DefaultMacro)IokeObject.dataOf(on)).name);
                                                                                                        })));



            obj.RegisterMethod(obj.runtime.NewNativeMethod("activates this macro with the arguments given to call", 
                                                           new NativeMethod("call", DefaultArgumentsDefinition.builder()
                                                                            .WithRestUnevaluated("arguments")
                                                                            .Arguments,
                                                                            (method, _context, message, on, outer) => {
                                                                                return IokeObject.As(on, _context).Activate(_context, message, _context.RealContext);
                                                                            })));


            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the message chain for this macro", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("message", obj,
                                                                                                        (method, on, args, keywords, _context, message) => {
                                                                                                            return ((DefaultMacro)IokeObject.dataOf(on)).Code;
                                                                                                        })));


            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the code for the argument definition", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("argumentsCode", obj,
                                                                                                        (method, on, args, keywords, _context, message) => {
                                                                                                            return _context.runtime.NewText(((AssociatedCode)IokeObject.dataOf(on)).ArgumentsCode);
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("Returns a text inspection of the object", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("inspect", obj,
                                                                                                        (method, on, args, keywords, _context, message) => {
                                                                                                            return _context.runtime.NewText(DefaultMacro.GetInspect(on));
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("Returns a brief text inspection of the object", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("notice", obj,
                                                                                                        (method, on, args, keywords, _context, message) => {
                                                                                                            return _context.runtime.NewText(DefaultMacro.GetNotice(on));
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the full code of this macro, as a Text", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("code", obj,
                                                                                                        (method, on, args, keywords, _context, message) => {
                                                                                                            IokeData data = IokeObject.dataOf(on);
                                                                                                            if(data is DefaultMacro) {
                                                                                                                return _context.runtime.NewText(((DefaultMacro)data).CodeString);
                                                                                                            } else {
                                                                                                                return _context.runtime.NewText(((AliasMethod)data).CodeString);
                                                                                                            }
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns idiomatically formatted code for this macro", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("formattedCode", obj,
                                                                                                        (method, on, args, keywords, _context, message) => {
                                                                                                            return _context.runtime.NewText(((AssociatedCode)IokeObject.dataOf(on)).FormattedCode(method));
                                                                                                        })));
        }

        public string Name {
            get { return this.name; }
            set { this.name = value; }
        }

        public static string GetInspect(object on) {
            return ((Inspectable)(IokeObject.dataOf(on))).Inspect(on);
        }

        public static string GetNotice(object on) {
            return ((Inspectable)(IokeObject.dataOf(on))).Notice(on);
        }

        public string Inspect(object self) {
            if(name == null) {
                return "macro(" + Message.Code(code) + ")";
            } else {
                return name + ":macro(" + Message.Code(code) + ")";
            }
        }

        public string Notice(object self) {
            if(name == null) {
                return "macro(...)";
            } else {
                return name + ":macro(...)";
            }
        }

        public IokeObject Code {
            get { return code; }
        }

        public string CodeString {
            get { return "macro(" + Message.Code(code) + ")"; }
        }

        public string FormattedCode(object self) {
            return "macro(\n  " + Message.FormattedCode(code, 2, (IokeObject)self) + ")";
        }

        public string ArgumentsCode {
            get { return "..."; }
        }

        public override object ActivateWithCallAndData(IokeObject self, IokeObject context, IokeObject message, object on, object call, IDictionary<string, object> data) {
            if(code == null) {
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
                condition.SetCell("report", context.runtime.NewText("You tried to activate a method without any code - did you by any chance activate the DefaultMacro kind by referring to it without wrapping it inside a call to cell?"));
                context.runtime.ErrorCondition(condition);
                return null;
            }

            IokeObject c = context.runtime.Locals.Mimic(message, context);
            c.SetCell("self", on);
            c.SetCell("@", on);
            c.RegisterMethod(c.runtime.NewNativeMethod("will return the currently executing macro receiver", new NativeMethod.WithNoArguments("@@",
                                                                            (method, _context, _message, _on, outer) => {
                                                                                outer.ArgumentsDefinition.GetEvaluatedArguments(_context, _message, _on, new SaneArrayList(), new SaneDictionary<string, object>());
                                                                                return self;
                                                                            })));
            c.SetCell("currentMessage", message);
            c.SetCell("surroundingContext", context);
            c.SetCell("call", call);

            foreach(var d in data) {
                string s = d.Key;
                c.SetCell(s.Substring(0, s.Length-1), d.Value);
            }

            try {
                return ((Message)IokeObject.dataOf(code)).EvaluateCompleteWith(code, c, on);
            } catch(ControlFlow.Return e) {
                if(e.context == c) {
                    return e.Value;
                } else {
                    throw e;
                }
            }
        }

        public override object ActivateWithCall(IokeObject self, IokeObject context, IokeObject message, object on, object call) {
            if(code == null) {
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
                condition.SetCell("report", context.runtime.NewText("You tried to activate a method without any code - did you by any chance activate the DefaultMacro kind by referring to it without wrapping it inside a call to cell?"));
                context.runtime.ErrorCondition(condition);
                return null;
            }

            IokeObject c = context.runtime.Locals.Mimic(message, context);
            c.SetCell("self", on);
            c.SetCell("@", on);
            c.RegisterMethod(c.runtime.NewNativeMethod("will return the currently executing macro receiver", new NativeMethod.WithNoArguments("@@",
                                                                            (method, _context, _message, _on, outer) => {
                                                                                outer.ArgumentsDefinition.GetEvaluatedArguments(_context, _message, _on, new SaneArrayList(), new SaneDictionary<string, object>());
                                                                                return self;
                                                                            })));
            c.SetCell("currentMessage", message);
            c.SetCell("surroundingContext", context);
            c.SetCell("call", call);

            try {
                return ((Message)IokeObject.dataOf(code)).EvaluateCompleteWith(code, c, on);
            } catch(ControlFlow.Return e) {
                if(e.context == c) {
                    return e.Value;
                } else {
                    throw e;
                }
            }
        }

        public override object Activate(IokeObject self, IokeObject context, IokeObject message, object on) {
            if(code == null) {
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
                condition.SetCell("report", context.runtime.NewText("You tried to activate a method without any code - did you by any chance activate the DefaultMacro kind by referring to it without wrapping it inside a call to cell?"));
                context.runtime.ErrorCondition(condition);
                return null;
            }

            IokeObject c = context.runtime.Locals.Mimic(message, context);
            c.SetCell("self", on);
            c.SetCell("@", on);
            c.RegisterMethod(c.runtime.NewNativeMethod("will return the currently executing macro receiver", new NativeMethod.WithNoArguments("@@",
                                                                            (method, _context, _message, _on, outer) => {
                                                                                outer.ArgumentsDefinition.GetEvaluatedArguments(_context, _message, _on, new SaneArrayList(), new SaneDictionary<string, object>());
                                                                                return self;
                                                                            })));
            c.SetCell("currentMessage", message);
            c.SetCell("surroundingContext", context);
            c.SetCell("call", context.runtime.NewCallFrom(c, message, context, IokeObject.As(on, context)));

            try {
                return ((Message)IokeObject.dataOf(code)).EvaluateCompleteWith(code, c, on);
            } catch(ControlFlow.Return e) {
                if(e.context == c) {
                    return e.Value;
                } else {
                    throw e;
                }
            }
        }

        public override object ActivateWithData(IokeObject self, IokeObject context, IokeObject message, object on, IDictionary<string, object> data) {
            if(code == null) {
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
                condition.SetCell("report", context.runtime.NewText("You tried to activate a method without any code - did you by any chance activate the DefaultMacro kind by referring to it without wrapping it inside a call to cell?"));
                context.runtime.ErrorCondition(condition);
                return null;
            }

            IokeObject c = context.runtime.Locals.Mimic(message, context);
            c.SetCell("self", on);
            c.SetCell("@", on);
            c.RegisterMethod(c.runtime.NewNativeMethod("will return the currently executing macro receiver", new NativeMethod.WithNoArguments("@@",
                                                                            (method, _context, _message, _on, outer) => {
                                                                                outer.ArgumentsDefinition.GetEvaluatedArguments(_context, _message, _on, new SaneArrayList(), new SaneDictionary<string, object>());
                                                                                return self;
                                                                            })));
            c.SetCell("currentMessage", message);
            c.SetCell("surroundingContext", context);
            c.SetCell("call", context.runtime.NewCallFrom(c, message, context, IokeObject.As(on, context)));
            
            foreach(var d in data) {
                string s = d.Key;
                c.SetCell(s.Substring(0, s.Length-1), d.Value);
            }

            try {
                return ((Message)IokeObject.dataOf(code)).EvaluateCompleteWith(code, c, on);
            } catch(ControlFlow.Return e) {
                if(e.context == c) {
                    return e.Value;
                } else {
                    throw e;
                }
            }
        }
    }
}
