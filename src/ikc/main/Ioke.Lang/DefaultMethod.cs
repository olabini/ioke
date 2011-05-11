namespace Ioke.Lang {
    using System.Collections;
    using System.Collections.Generic;

    using Ioke.Lang.Util;

    public class DefaultMethod : Method, AssociatedCode {
        DefaultArgumentsDefinition arguments;
        IokeObject code;

        public DefaultMethod(string name) : base(name, IokeData.TYPE_DEFAULT_METHOD) {}
        public DefaultMethod(IokeObject context, DefaultArgumentsDefinition arguments, IokeObject code) : base(context, IokeData.TYPE_DEFAULT_METHOD) {
            this.arguments = arguments;
            this.code = code;
        }

        public IokeObject Code {
            get { return code; }
        }

        public string ArgumentsCode {
            get { return arguments.GetCode(false); }
        }

        public string FormattedCode(object self) {
            string args = arguments == null ? "" : arguments.GetCode();
            return "method(" + args + "\n  " + Message.FormattedCode(code, 2, (IokeObject)self) + ")";
        }

        public override string CodeString {
            get {
                string args = arguments == null ? "" : arguments.GetCode();
                return "method(" + args + Message.Code(code) + ")";
            }
        }

        public override string Inspect(object self) {
            string args = arguments == null ? "" : arguments.GetCode();
            if(name == null) {
                return "method(" + args + Message.Code(code) + ")";
            } else {
                return name + ":method(" + args + Message.Code(code) + ")";
            }
        }

        public override void Init(IokeObject obj) {
            obj.Kind = "DefaultMethod";

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns a list of the keywords this method takes",
                                                           new TypeCheckingNativeMethod.WithNoArguments("keywords", obj,
                                                                                                        (method, on, args, keywords, _context, message) => {
                                                                                                            var keywordList = new SaneArrayList();

                                                                                                            foreach(string keyword in ((DefaultMethod)IokeObject.dataOf(on)).arguments.Keywords) {
                                                                                                                keywordList.Add(_context.runtime.GetSymbol(keyword.Substring(0, keyword.Length-1)));
                                                                                                            }

                                                                                                            return _context.runtime.NewList(keywordList);
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the message chain for this method",
                                                           new TypeCheckingNativeMethod.WithNoArguments("message", obj,
                                                                                                        (method, on, args, keywords, _context, message) => {
                                                                                                            return ((AssociatedCode)IokeObject.dataOf(on)).Code;
                                                                                                        })));

             obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the code for the argument definition",
                                                           new TypeCheckingNativeMethod.WithNoArguments("argumentsCode", obj,
                                                                                                        (method, on, args, keywords, _context, message) => {
                                                                                                            return _context.runtime.NewText(((AssociatedCode)IokeObject.dataOf(on)).ArgumentsCode);
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns idiomatically formatted code for this method",
                                                           new TypeCheckingNativeMethod.WithNoArguments("formattedCode", obj,
                                                                                                        (method, on, args, keywords, _context, message) => {
                                                                                                            return _context.runtime.NewText(((AssociatedCode)IokeObject.dataOf(on)).FormattedCode(method));
                                                                                                        })));
        }

        private static IokeObject CreateSuperCallFor(IokeObject out_self, IokeObject out_context, IokeObject out_message, object out_on, string out_name) {
            return out_context.runtime.NewNativeMethod("will call the super method of the current message on the same receiver", 
                                                       new NativeMethod("super", DefaultArgumentsDefinition.builder()
                                                                        .WithRestUnevaluated("arguments")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            object superCell = context.runtime.nul;
                                                                            string realname = out_name;
                                                                            if(realname != null) {
                                                                                superCell = IokeObject.FindSuperCellOn(out_on, out_self, out_context, realname);
                                                                            }
                                                                            if(superCell == context.runtime.nul) {
                                                                                realname = Message.GetName(out_message);
                                                                                superCell = IokeObject.FindSuperCellOn(out_on, out_self, out_context, realname);
                                                                            }
                                                                            
                                                                            if(superCell != context.runtime.nul) {
                                                                                if(IokeObject.dataOf(superCell) is Method) {
                                                                                    return Interpreter.Activate(((IokeObject)superCell), context, message, out_on);
                                                                                } else {
                                                                                    return superCell;
                                                                                }
                                                                            } else {
                                                                                return Interpreter.SignalNoSuchCell(message, context, out_on, realname, superCell, out_self);
                                                                                
                                                                            }
                                                                        }));
        }

        public static object ActivateWithCallAndDataFixed(IokeObject self, IokeObject context, IokeObject message, object on, object call, IDictionary<string, object> data) {
            DefaultMethod dm = (DefaultMethod)self.data;
            if(dm.code == null) {
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
                condition.SetCell("report", context.runtime.NewText("You tried to activate a method without any code - did you by any chance activate the DefaultMethod kind by referring to it without wrapping it inside a call to cell?"));
                context.runtime.ErrorCondition(condition);
                return null;
            }


            IokeObject c = context.runtime.Locals.Mimic(message, context);
            c.SetCell("self", on);
            c.SetCell("@", on);
            c.RegisterMethod(c.runtime.NewNativeMethod("will return the currently executing method receiver",
                                                       new NativeMethod.WithNoArguments("@@",
                                                                                        (method, _context, _message, _on, outer) => {
                                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(_context, _message, _on, new SaneArrayList(), new SaneDictionary<string, object>());
                                                                                            return self;
                                                                                        })));
            c.SetCell("currentMessage", message);
            c.SetCell("surroundingContext", context);
            foreach(var d in data) {
                string s = d.Key;
                c.SetCell(s.Substring(0, s.Length-1), d.Value);
            }

            c.SetCell("super", CreateSuperCallFor(self, context, message, on, dm.name));

            dm.arguments.AssignArgumentValues(c, context, message, on, ((Call)IokeObject.dataOf(call)));

            try {
                return context.runtime.interpreter.Evaluate(dm.code, c, on, c);
            } catch(ControlFlow.Return e) {
                if(e.context == c) {
                    return e.Value;
                } else {
                    throw e;
                }
            }
        }

        public new static object ActivateFixed(IokeObject self, IokeObject context, IokeObject message, object on) {
            DefaultMethod dm = (DefaultMethod)self.data;
            if(dm.code == null) {
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
                condition.SetCell("report", context.runtime.NewText("You tried to activate a method without any code - did you by any chance activate the DefaultMethod kind by referring to it without wrapping it inside a call to cell?"));
                context.runtime.ErrorCondition(condition);
                return null;
            }

            IokeObject c = context.runtime.Locals.Mimic(message, context);
            c.SetCell("self", on);
            c.SetCell("@", on);
            c.RegisterMethod(c.runtime.NewNativeMethod("will return the currently executing method receiver",
                                                       new NativeMethod.WithNoArguments("@@",
                                                                                        (method, _context, _message, _on, outer) => {
                                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(_context, _message, _on, new SaneArrayList(), new SaneDictionary<string, object>());
                                                                                            return self;
                                                                                        })));
            c.SetCell("currentMessage", message);
            c.SetCell("surroundingContext", context);
            c.SetCell("super", CreateSuperCallFor(self, context, message, on, dm.name));

            dm.arguments.AssignArgumentValues(c, context, message, on);

            try {
                return context.runtime.interpreter.Evaluate(dm.code, c, on, c);
            } catch(ControlFlow.Return e) {
                if(e.context == c) {
                    return e.Value;
                } else {
                    throw e;
                }
            }
        }

        public static object ActivateWithDataFixed(IokeObject self, IokeObject context, IokeObject message, object on, IDictionary<string, object> data) {
            DefaultMethod dm = (DefaultMethod)self.data;
            if(dm.code == null) {
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
                condition.SetCell("report", context.runtime.NewText("You tried to activate a method without any code - did you by any chance activate the DefaultMethod kind by referring to it without wrapping it inside a call to cell?"));
                context.runtime.ErrorCondition(condition);
                return null;
            }


            IokeObject c = context.runtime.Locals.Mimic(message, context);
            c.SetCell("self", on);
            c.SetCell("@", on);
            c.RegisterMethod(c.runtime.NewNativeMethod("will return the currently executing method receiver",
                                                       new NativeMethod.WithNoArguments("@@",
                                                                                        (method, _context, _message, _on, outer) => {
                                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(_context, _message, _on, new SaneArrayList(), new SaneDictionary<string, object>());
                                                                                            return self;
                                                                                        })));
            c.SetCell("currentMessage", message);
            c.SetCell("surroundingContext", context);
            foreach(var d in data) {
                string s = d.Key;
                c.SetCell(s.Substring(0, s.Length-1), d.Value);
            }

            c.SetCell("super", CreateSuperCallFor(self, context, message, on, dm.name));

            dm.arguments.AssignArgumentValues(c, context, message, on);

            try {
                return context.runtime.interpreter.Evaluate(dm.code, c, on, c);
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
