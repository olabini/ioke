namespace Ioke.Lang {
    using System.Collections;
    using System.Collections.Generic;

    using Ioke.Lang.Util;

    public class DefaultSyntax : IokeData, Named, Inspectable, AssociatedCode {
        string name;
        IokeObject context;
        IokeObject code;

        public DefaultSyntax(string name) {
            this.name = name;
        }

        public DefaultSyntax(IokeObject context, IokeObject code) : this((string)null) {
            this.context = context;
            this.code = code;
        }

        public override void Init(IokeObject obj) {
            obj.Kind = "DefaultSyntax";
            obj.RegisterCell("activatable", obj.runtime.True);

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the name of the syntax", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("name", obj,
                                                                                                        (method, on, args, keywords, _context, message) => {
                                                                                                            return _context.runtime.NewText(((DefaultSyntax)IokeObject.dataOf(on)).name);
                                                                                                        })));


            obj.RegisterMethod(obj.runtime.NewNativeMethod("activates this syntax with the arguments given to call", 
                                                           new NativeMethod("call", DefaultArgumentsDefinition.builder()
                                                                            .WithRestUnevaluated("arguments")
                                                                            .Arguments,
                                                                            (method, _context, message, on, outer) => {
                                                                                return IokeObject.As(on, _context).Activate(_context, message, _context.RealContext);
                                                                            })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the result of activating this syntax without actually doing the replacement or execution part.", 
                                                           new NativeMethod("expand", DefaultArgumentsDefinition.builder()
                                                                            .WithRestUnevaluated("arguments")
                                                                            .Arguments,
                                                                            (method, _context, message, on, outer) => {
                                                                                object onAsSyntax = _context.runtime.DefaultSyntax.ConvertToThis(on, message, _context);
                                                                                return ((DefaultSyntax)IokeObject.dataOf(onAsSyntax)).Expand(IokeObject.As(onAsSyntax, context), context, message, context.RealContext, null);
                                                                            })));
        

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the message chain for this syntax", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("message", obj,
                                                                                                        (method, on, args, keywords, _context, message) => {
                                                                                                            return ((AssociatedCode)IokeObject.dataOf(on)).Code;
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the code for the argument definition", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("argumentsCode", obj,
                                                                                                        (method, on, args, keywords, _context, message) => {
                                                                                                            return _context.runtime.NewText(((AssociatedCode)IokeObject.dataOf(on)).ArgumentsCode);
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("Returns a text inspection of the object", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("inspect", obj,
                                                                                                        (method, on, args, keywords, _context, message) => {
                                                                                                            return _context.runtime.NewText(DefaultSyntax.GetInspect(on));
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("Returns a brief text inspection of the object", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("notice", obj,
                                                                                                        (method, on, args, keywords, _context, message) => {
                                                                                                            return _context.runtime.NewText(DefaultSyntax.GetNotice(on));
                                                                                                        })));


            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the full code of this syntax, as a Text", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("code", obj,
                                                                                                        (method, on, args, keywords, _context, message) => {
                                                                                                            IokeData data = IokeObject.dataOf(on);
                                                                                                            if(data is DefaultSyntax) {
                                                                                                                return _context.runtime.NewText(((DefaultSyntax)data).CodeString);
                                                                                                            } else {
                                                                                                                return _context.runtime.NewText(((AliasMethod)data).CodeString);
                                                                                                            }
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns idiomatically formatted code for this syntax", 
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
                return "syntax(" + Message.Code(code) + ")";
            } else {
                return name + ":syntax(" + Message.Code(code) + ")";
            }
        }

        public string Notice(object self) {
            if(name == null) {
                return "syntax(...)";
            } else {
                return name + ":syntax(...)";
            }
        }

        public string ArgumentsCode {
            get { return "..."; }
        }

        public IokeObject Code {
            get { return code; }
        }

        public string CodeString {
            get { return "syntax(" + Message.Code(code) + ")"; } 

        }

        public string FormattedCode(object self) {
            return "syntax(\n  " + Message.FormattedCode(code, 2, (IokeObject)self) + ")";
        }

        private object Expand(IokeObject self, IokeObject context, IokeObject message, object on, IDictionary<string, object> data) {
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
                condition.SetCell("report", context.runtime.NewText("You tried to activate a method without any code - did you by any chance activate the DefaultSyntax kind by referring to it without wrapping it inside a call to cell?"));
                context.runtime.ErrorCondition(condition);
                return null;
            }

            IokeObject c = context.runtime.Locals.Mimic(message, context);
            c.SetCell("self", on);
            c.SetCell("@", on);
            c.RegisterMethod(c.runtime.NewNativeMethod("will return the currently executing syntax receiver", new NativeMethod.WithNoArguments("@@",
                                                                                                                                               (method, _context, _message, _on, outer) => {
                                                                                                                                                   outer.ArgumentsDefinition.GetEvaluatedArguments(_context, _message, _on, new SaneArrayList(), new SaneDictionary<string, object>());
                                                                                                                                                   return self;
                                                                                                                                               })));
            c.SetCell("currentMessage", message);
            c.SetCell("surroundingContext", context);
            c.SetCell("call", context.runtime.NewCallFrom(c, message, context, IokeObject.As(on, context)));
            if(data != null) {
                foreach(var d in data) {
                    string s = d.Key;
                    c.SetCell(s.Substring(0, s.Length-1), d.Value);
                }
            }

            object result = null;

            try {
                result = ((Message)IokeObject.dataOf(code)).EvaluateCompleteWith(code, c, on);
            } catch(ControlFlow.Return e) {
                if(e.context == c) {
                    result = e.Value;
                } else {
                    throw e;
                }
            }

            return result;
        }

        private object ExpandWithCall(IokeObject self, IokeObject context, IokeObject message, object on, object call, IDictionary<string, object> data) {
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
                condition.SetCell("report", context.runtime.NewText("You tried to activate a method without any code - did you by any chance activate the DefaultSyntax kind by referring to it without wrapping it inside a call to cell?"));
                context.runtime.ErrorCondition(condition);
                return null;
            }

            IokeObject c = context.runtime.Locals.Mimic(message, context);
            c.SetCell("self", on);
            c.SetCell("@", on);
            c.RegisterMethod(c.runtime.NewNativeMethod("will return the currently executing syntax receiver", new NativeMethod.WithNoArguments("@@",
                                                                                                                                               (method, _context, _message, _on, outer) => {
                                                                                                                                                   outer.ArgumentsDefinition.GetEvaluatedArguments(_context, _message, _on, new SaneArrayList(), new SaneDictionary<string, object>());
                                                                                                                                                   return self;
                                                                                                                                               })));
            c.SetCell("currentMessage", message);
            c.SetCell("surroundingContext", context);
            c.SetCell("call", call);
            if(data != null) {
                foreach(var d in data) {
                    string s = d.Key;
                    c.SetCell(s.Substring(0, s.Length-1), d.Value);
                }
            }

            object result = null;

            try {
                result = ((Message)IokeObject.dataOf(code)).EvaluateCompleteWith(code, c, on);
            } catch(ControlFlow.Return e) {
                if(e.context == c) {
                    result = e.Value;
                } else {
                    throw e;
                }
            }

            return result;
        }

        public override object ActivateWithCallAndData(IokeObject self, IokeObject context, IokeObject message, object on, object call, IDictionary<string, object> data) {
            object result = ExpandWithCall(self, context, message, on, call, data);

            if(result == context.runtime.nil) {
                // Remove chain completely
                IokeObject prev = Message.GetPrev(message);
                IokeObject next = Message.GetNext(message);
                if(prev != null) {
                    Message.SetNext(prev, next);
                    if(next != null) {
                        Message.SetPrev(next, prev);
                    }
                } else {
                    message.Become(next, message, context);
                    Message.SetPrev(next, null);
                }
                return null;
            } else {
                // Insert resulting value into chain, wrapping it if it's not a message

                IokeObject newObj = null;
                if(IokeObject.dataOf(result) is Message) {
                    newObj = IokeObject.As(result, context);
                } else {
                    newObj = context.runtime.CreateMessage(Message.Wrap(IokeObject.As(result, context)));
                }

                IokeObject prev = Message.GetPrev(message);
                IokeObject next = Message.GetNext(message);

                message.Become(newObj, message, context);

                IokeObject last = newObj;
                while(Message.GetNext(last) != null) {
                    last = Message.GetNext(last);
                }
                Message.SetNext(last, next);
                if(next != null) {
                    Message.SetPrev(next, last);
                }
                Message.SetPrev(newObj, prev);

                return ((Message)IokeObject.dataOf(message)).SendTo(message, context, context);
            }
        }

        public override object ActivateWithCall(IokeObject self, IokeObject context, IokeObject message, object on, object call) {
            return ActivateWithCallAndData(self, context, message, on, call, null);
        }

        public override object Activate(IokeObject self, IokeObject context, IokeObject message, object on) {
            return ActivateWithData(self, context, message, on, null);
        }

        public override object ActivateWithData(IokeObject self, IokeObject context, IokeObject message, object on, IDictionary<string, object> data) {
            object result = Expand(self, context, message, on, data);

            if(result == context.runtime.nil) {
                // Remove chain completely
                IokeObject prev = Message.GetPrev(message);
                IokeObject next = Message.GetNext(message);
                if(prev != null) {
                    Message.SetNext(prev, next);
                    if(next != null) {
                        Message.SetPrev(next, prev);
                    }
                } else {
                    message.Become(next, message, context);
                    Message.SetPrev(next, null);
                }
                return null;
            } else {
                // Insert resulting value into chain, wrapping it if it's not a message

                IokeObject newObj = null;
                if(IokeObject.dataOf(result) is Message) {
                    newObj = IokeObject.As(result, context);
                } else {
                    newObj = context.runtime.CreateMessage(Message.Wrap(IokeObject.As(result, context)));
                }

                IokeObject prev = Message.GetPrev(message);
                IokeObject next = Message.GetNext(message);

                message.Become(newObj, message, context);

                IokeObject last = newObj;
                while(Message.GetNext(last) != null) {
                    last = Message.GetNext(last);
                }
                Message.SetNext(last, next);
                if(next != null) {
                    Message.SetPrev(next, last);
                }
                Message.SetPrev(newObj, prev);

                return ((Message)IokeObject.dataOf(message)).SendTo(message, context, context);
            }
        }
    }
}
