namespace Ioke.Lang {
    using System.Collections;
    using System.Collections.Generic;

    using Ioke.Lang.Util;

    public class LexicalBlock : IokeData, AssociatedCode, Inspectable {
        DefaultArgumentsDefinition arguments;
        IokeObject context;
        IokeObject message;

        public LexicalBlock(IokeObject context, DefaultArgumentsDefinition arguments, IokeObject message) {
            this.context = context;
            this.arguments = arguments;
            this.message = message;
        }

        public LexicalBlock(IokeObject context) : this(context, DefaultArgumentsDefinition.Empty(), context.runtime.nilMessage) {}

        public override void Init(IokeObject obj) {
            obj.Kind = "LexicalBlock";

            obj.RegisterMethod(obj.runtime.NewNativeMethod("takes two evaluated arguments, where this first one is a list of messages which will be used as the arguments and the code, and the second is the context where this lexical scope should be created in", 
                                                           new NativeMethod("createFrom", DefaultArgumentsDefinition.builder()
                                                                            .WithRequiredPositional("messageList")
                                                                            .WithRequiredPositional("lexicalContext")
                                                                            .Arguments,
                                                                            (method, _context, _message, on, outer) => {
                                                                                Runtime runtime = _context.runtime;
                                                                                var positionalArgs = new SaneArrayList();
                                                                                outer.ArgumentsDefinition.GetEvaluatedArguments(_context, _message, on, positionalArgs, new SaneDictionary<string, object>());
                                                                                var args = IokeList.GetList(positionalArgs[0]);
                                                                                IokeObject ground = IokeObject.As(positionalArgs[1], _context);
                                                                            
                                                                                IokeObject code = IokeObject.As(args[args.Count-1], _context);

                                                                                DefaultArgumentsDefinition def = DefaultArgumentsDefinition.CreateFrom(args, 0, args.Count-1, _message, on, _context);
                                                                                return runtime.NewLexicalBlock(null, runtime.LexicalBlock, new LexicalBlock(ground, def, code));
                                                                            })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("invokes the block with the arguments provided, returning the result of the last expression in the block", 
                                                           new NativeMethod("call", DefaultArgumentsDefinition.builder()
                                                                            .WithRestUnevaluated("arguments")
                                                                            .Arguments,
                                                                            (method, _context, _message, on, outer) => {
                                                                                outer.ArgumentsDefinition.GetEvaluatedArguments(_context, _message, on, new SaneArrayList(), new SaneDictionary<string, object>());
                                                                                return IokeObject.As(on, _context).Activate(_context, _message, on);
                                                                            })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the full code of this lexical block, as a Text", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("code", obj,
                                                                                                        (method, on, args, keywords, _context, _message) => {
                                                                                                            IokeObject objx = IokeObject.As(on, _context);
                                                                                                            string x = objx.IsActivatable ? "x" : "";
                    
                                                                                                            string argstr = ((LexicalBlock)IokeObject.dataOf(on)).arguments.GetCode();
                                                                                                            return _context.runtime.NewText("fn" + x + "(" + argstr + Message.Code(((LexicalBlock)IokeObject.dataOf(on)).message) + ")");
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the code for the argument definition", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("argumentsCode", obj,
                                                                                                        (method, on, args, keywords, _context, _message) => {
                                                                                                            return _context.runtime.NewText(((AssociatedCode)IokeObject.dataOf(on)).ArgumentsCode);
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns a list of the keywords this block takes", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("keywords", obj,
                                                                                                        (method, on, args, keywords, _context, _message) => {
                                                                                                            var keywordList = new SaneArrayList();
                    
                                                                                                            foreach(string keyword in ((LexicalBlock)IokeObject.dataOf(on)).arguments.Keywords) {
                                                                                                                keywordList.Add(_context.runtime.GetSymbol(keyword.Substring(0, keyword.Length-1)));
                                                                                                            }

                                                                                                            return _context.runtime.NewList(keywordList);
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns a list of the argument names the positional arguments this block takes", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("argumentNames", obj,
                                                                                                        (method, on, args, keywords, _context, _message) => {
                                                                                                            var names = new SaneArrayList();
                    
                                                                                                            foreach(var arg in ((LexicalBlock)IokeObject.dataOf(on)).arguments.Arguments) {
                                                                                                                if(!(arg is DefaultArgumentsDefinition.KeywordArgument)) {
                                                                                                                    names.Add(_context.runtime.GetSymbol(arg.Name));
                                                                                                                }
                                                                                                            }

                                                                                                            return _context.runtime.NewList(names);
                                                                                                        })));
            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the message chain for this block", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("message", obj,
                                                                                                        (method, on, args, keywords, _context, _message) => {
                                                                                                            return ((AssociatedCode)IokeObject.dataOf(on)).Code;
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("Returns a text inspection of the object", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("inspect", obj,
                                                                                                        (method, on, args, keywords, _context, message) => {
                                                                                                            return _context.runtime.NewText(LexicalBlock.GetInspect(on));
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("Returns a brief text inspection of the object", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("notice", obj,
                                                                                                        (method, on, args, keywords, _context, message) => {
                                                                                                            return _context.runtime.NewText(LexicalBlock.GetNotice(on));
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns idiomatically formatted code for this lexical block", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("formattedCode", obj,
                                                                                                        (method, on, args, keywords, _context, message) => {
                                                                                                            return _context.runtime.NewText(((AssociatedCode)IokeObject.dataOf(on)).FormattedCode(method));
                                                                                                        })));
        }

        public IokeObject Code {
            get { return message;}
        }

        public string ArgumentsCode {
            get { return arguments.GetCode(false); }
        }

        public string FormattedCode(object self) {
            string args = arguments == null ? "" : arguments.GetCode();
            if(IokeObject.As(self, (IokeObject)self).IsActivatable) {
                return "fnx(" + args + "\n  " + Message.FormattedCode(message, 2, (IokeObject)self) + ")";
            } else {
                return "fn(" + args + "\n  " + Message.FormattedCode(message, 2, (IokeObject)self) + ")";
            }
        }

        public override object ActivateWithCallAndData(IokeObject self, IokeObject dynamicContext, IokeObject message, object on, object call, IDictionary<string, object> data) {
            LexicalContext c = new LexicalContext(self.runtime, on, "Lexical activation context", message, this.context);

            foreach(var d in data) {
                string s = d.Key;
                c.SetCell(s.Substring(0, s.Length-1), d.Value);
            }
            arguments.AssignArgumentValues(c, dynamicContext, message, on, ((Call)IokeObject.dataOf(call)));

            return ((Message)IokeObject.dataOf(this.message)).EvaluateCompleteWith(this.message, c, on);
        }

        public override object ActivateWithCall(IokeObject self, IokeObject dynamicContext, IokeObject message, object on, object call) {
            LexicalContext c = new LexicalContext(self.runtime, on, "Lexical activation context", message, this.context);

            arguments.AssignArgumentValues(c, dynamicContext, message, on, ((Call)IokeObject.dataOf(call)));

            return ((Message)IokeObject.dataOf(this.message)).EvaluateCompleteWith(this.message, c, on);
        }

        public override object Activate(IokeObject self, IokeObject dynamicContext, IokeObject message, object on) {
            LexicalContext c = new LexicalContext(self.runtime, on, "Lexical activation context", message, this.context);

            arguments.AssignArgumentValues(c, dynamicContext, message, on);

            return ((Message)IokeObject.dataOf(this.message)).EvaluateCompleteWith(this.message, c, on);
        }

        public override object ActivateWithData(IokeObject self, IokeObject dynamicContext, IokeObject message, object on, IDictionary<string, object> data) {
            LexicalContext c = new LexicalContext(self.runtime, on, "Lexical activation context", message, this.context);

            foreach(var d in data) {
                string s = d.Key;
                c.SetCell(s.Substring(0, s.Length-1), d.Value);
            }

            arguments.AssignArgumentValues(c, dynamicContext, message, on);

            return ((Message)IokeObject.dataOf(this.message)).EvaluateCompleteWith(this.message, c, on);
        }
        
        public static string GetInspect(object on) {
            return ((Inspectable)(IokeObject.dataOf(on))).Inspect(on);
        }

        public static string GetNotice(object on) {
            return ((Inspectable)(IokeObject.dataOf(on))).Notice(on);
        }

        public string Inspect(object self) {
            string args = arguments.GetCode();
            if(IokeObject.As(self, (IokeObject)self).IsActivatable) {
                return "fnx(" + args + Message.Code(message) + ")";
            } else {
                return "fn(" + args + Message.Code(message) + ")";
            }
        }

        public string Notice(object self) {
            if(IokeObject.As(self, (IokeObject)self).IsActivatable) {
                return "fnx(...)";
            } else {
                return "fn(...)";
            }
        }
    }
}
