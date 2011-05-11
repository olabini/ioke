
namespace Ioke.Lang {
    using System.Collections;
    using System.Collections.Generic;

    using Ioke.Lang.Util;

    public class LexicalMacro : IokeData, AssociatedCode, Named, Inspectable {
        internal string name;
        IokeObject context;
        IokeObject code;

        public LexicalMacro(IokeObject context, IokeObject code) : base(IokeData.TYPE_LEXICAL_MACRO) {
            this.context = context;
            this.code = code;
        }

        public LexicalMacro(string name) : base(IokeData.TYPE_LEXICAL_MACRO) {
            this.name = name;
        }


        public override void Init(IokeObject obj) {
            obj.Kind = "LexicalMacro";
            obj.SetActivatable(true);

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the name of the lecro",
                                                           new NativeMethod.WithNoArguments("name",
                                                                                            (method, _context, message, on, outer) => {
                                                                                                outer.ArgumentsDefinition.GetEvaluatedArguments(_context, message, on, new SaneArrayList(), new SaneDictionary<string, object>());
                                                                                                return _context.runtime.NewText(((LexicalMacro)IokeObject.dataOf(on)).name);
                                                                                            })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("activates this lecro with the arguments given to call",
                                                           new NativeMethod("call", DefaultArgumentsDefinition.builder()
                                                                            .WithRestUnevaluated("arguments")
                                                                            .Arguments,
                                                                            (method, _context, message, on, outer) => {
                                                                                return Interpreter.Activate(IokeObject.As(on, _context), _context, message, _context.RealContext);
                                                                            })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the message chain for this lecro",
                                                           new NativeMethod.WithNoArguments("message",
                                                                                            (method, _context, message, on, outer) => {
                                                                                                outer.ArgumentsDefinition.GetEvaluatedArguments(_context, message, on, new SaneArrayList(), new SaneDictionary<string, object>());
                                                                                                return ((AssociatedCode)IokeObject.dataOf(on)).Code;
                                                                                            })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the code for the argument definition",
                                                           new NativeMethod.WithNoArguments("argumentsCode",
                                                                                            (method, _context, message, on, outer) => {
                                                                                                outer.ArgumentsDefinition.GetEvaluatedArguments(_context, message, on, new SaneArrayList(), new SaneDictionary<string, object>());
                                                                                                return _context.runtime.NewText(((AssociatedCode)IokeObject.dataOf(on)).ArgumentsCode);
                                                                                            })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("Returns a text inspection of the object",
                                                           new NativeMethod.WithNoArguments("inspect",
                                                                                            (method, _context, message, on, outer) => {
                                                                                                outer.ArgumentsDefinition.GetEvaluatedArguments(_context, message, on, new SaneArrayList(), new SaneDictionary<string, object>());
                                                                                                return _context.runtime.NewText(LexicalMacro.GetInspect(on));
                                                                                            })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("Returns a brief text inspection of the object",
                                                           new NativeMethod.WithNoArguments("notice",
                                                                                            (method, _context, message, on, outer) => {
                                                                                                outer.ArgumentsDefinition.GetEvaluatedArguments(_context, message, on, new SaneArrayList(), new SaneDictionary<string, object>());
                                                                                                return _context.runtime.NewText(LexicalMacro.GetNotice(on));
                                                                                            })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the full code of this lecro, as a Text",
                                                           new NativeMethod.WithNoArguments("code",
                                                                                            (method, _context, message, on, outer) => {
                                                                                                outer.ArgumentsDefinition.GetEvaluatedArguments(_context, message, on, new SaneArrayList(), new SaneDictionary<string, object>());
                                                                                                IokeData data = IokeObject.dataOf(on);
                                                                                                if(data is LexicalMacro) {
                                                                                                    return _context.runtime.NewText(((LexicalMacro)data).CodeString(on));
                                                                                                } else {
                                                                                                    return _context.runtime.NewText(((AliasMethod)data).CodeString);
                                                                                                }
                                                                                            })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns idiomatically formatted code for this lecro",
                                                           new NativeMethod.WithNoArguments("formattedCode",
                                                                                            (method, _context, message, on, outer) => {
                                                                                                outer.ArgumentsDefinition.GetEvaluatedArguments(_context, message, on, new SaneArrayList(), new SaneDictionary<string, object>());
                                                                                                return _context.runtime.NewText(((AssociatedCode)IokeObject.dataOf(on)).FormattedCode(method));
                                                                                            })));
        }

        public IokeObject Code {
            get { return code; }
        }

        public string CodeString(object self) {
            if(IokeObject.As(self, null).IsActivatable) {
                return "lecro(" + Message.Code(code) + ")";
            } else {
                return "lecrox(" + Message.Code(code) + ")";
            }
        }

        public string FormattedCode(object self) {
            if(IokeObject.As(self, (IokeObject)self).IsActivatable) {
                return "lecro(\n  " + Message.FormattedCode(code, 2, (IokeObject)self) + ")";
            } else {
                return "lecrox(\n  " + Message.FormattedCode(code, 2, (IokeObject)self) + ")";
            }
        }

        public string ArgumentsCode {
            get { return "..."; }
        }

        public string Name {
            get { return name; }
            set { this.name = value; }
        }

        public static string GetInspect(object on) {
            return ((Inspectable)(IokeObject.dataOf(on))).Inspect(on);
        }

        public static string GetNotice(object on) {
            return ((Inspectable)(IokeObject.dataOf(on))).Notice(on);
        }

        public string Inspect(object self) {
            string type = "lecro";
            if(!IokeObject.As(self, null).IsActivatable) {
                type = "lecrox";
            }

            if(name == null) {
                return type + "(" + Message.Code(code) + ")";
            } else {
                return name + ":" + type + "(" + Message.Code(code) + ")";
            }
        }

        public string Notice(object self) {
            string type = "lecro";
            if(!IokeObject.As(self, null).IsActivatable) {
                type = "lecrox";
            }

            if(name == null) {
                return type + "(...)";
            } else {
                return name + ":" + type + "(...)";
            }
        }

        public static object ActivateWithCallAndDataFixed(IokeObject self, IokeObject dynamicContext, IokeObject message, object on, object call, IDictionary<string, object> data) {
            LexicalMacro lm = (LexicalMacro)self.data;
            if(lm.code == null) {
                IokeObject condition = IokeObject.As(IokeObject.GetCellChain(dynamicContext.runtime.Condition,
                                                                             message,
                                                                             dynamicContext,
                                                                             "Error",
                                                                             "Invocation",
                                                                             "NotActivatable"), dynamicContext).Mimic(message, dynamicContext);
                condition.SetCell("message", message);
                condition.SetCell("context", dynamicContext);
                condition.SetCell("receiver", on);
                condition.SetCell("method", self);
                condition.SetCell("report", dynamicContext.runtime.NewText("You tried to activate a method without any code - did you by any chance activate the LexicalMacro kind by referring to it without wrapping it inside a call to cell?"));
                dynamicContext.runtime.ErrorCondition(condition);
                return null;
            }

            IokeObject c = self.runtime.NewLexicalContext(on, "Lexical macro activation context", lm.context);

            c.SetCell("outerScope", lm.context);
            c.SetCell("call", call);
            foreach(var d in data) {
                string s = d.Key;
                c.SetCell(s.Substring(0, s.Length-1), d.Value);
            }

            return self.runtime.interpreter.Evaluate(lm.code, c, on, c);
        }

        public new static object ActivateFixed(IokeObject self, IokeObject dynamicContext, IokeObject message, object on) {
            LexicalMacro lm = (LexicalMacro)self.data;
            if(lm.code == null) {
                IokeObject condition = IokeObject.As(IokeObject.GetCellChain(dynamicContext.runtime.Condition,
                                                                             message,
                                                                             dynamicContext,
                                                                             "Error",
                                                                             "Invocation",
                                                                             "NotActivatable"), dynamicContext).Mimic(message, dynamicContext);
                condition.SetCell("message", message);
                condition.SetCell("context", dynamicContext);
                condition.SetCell("receiver", on);
                condition.SetCell("method", self);
                condition.SetCell("report", dynamicContext.runtime.NewText("You tried to activate a method without any code - did you by any chance activate the LexicalMacro kind by referring to it without wrapping it inside a call to cell?"));
                dynamicContext.runtime.ErrorCondition(condition);
                return null;
            }

            IokeObject c = self.runtime.NewLexicalContext(on, "Lexical macro activation context", lm.context);

            c.SetCell("outerScope", lm.context);
            c.SetCell("call", dynamicContext.runtime.NewCallFrom(c, message, dynamicContext, IokeObject.As(on, dynamicContext)));

            return self.runtime.interpreter.Evaluate(lm.code, c, on, c);
        }

        public static object ActivateWithDataFixed(IokeObject self, IokeObject dynamicContext, IokeObject message, object on, IDictionary<string, object> data) {
            LexicalMacro lm = (LexicalMacro)self.data;
            if(lm.code == null) {
                IokeObject condition = IokeObject.As(IokeObject.GetCellChain(dynamicContext.runtime.Condition,
                                                                             message,
                                                                             dynamicContext,
                                                                             "Error",
                                                                             "Invocation",
                                                                             "NotActivatable"), dynamicContext).Mimic(message, dynamicContext);
                condition.SetCell("message", message);
                condition.SetCell("context", dynamicContext);
                condition.SetCell("receiver", on);
                condition.SetCell("method", self);
                condition.SetCell("report", dynamicContext.runtime.NewText("You tried to activate a method without any code - did you by any chance activate the LexicalMacro kind by referring to it without wrapping it inside a call to cell?"));
                dynamicContext.runtime.ErrorCondition(condition);
                return null;
            }

            IokeObject c = self.runtime.NewLexicalContext(on, "Lexical macro activation context", lm.context);

            c.SetCell("outerScope", lm.context);
            c.SetCell("call", dynamicContext.runtime.NewCallFrom(c, message, dynamicContext, IokeObject.As(on, dynamicContext)));
            foreach(var d in data) {
                string s = d.Key;
                c.SetCell(s.Substring(0, s.Length-1), d.Value);
            }

            return self.runtime.interpreter.Evaluate(lm.code, c, on, c);
        }
    }
}
