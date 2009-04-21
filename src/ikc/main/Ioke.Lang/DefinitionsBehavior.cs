namespace Ioke.Lang {
    using System.Collections;
    using System.Collections.Generic;

    using Ioke.Lang.Util;

    public class DefinitionsBehavior {
        public static void Init(IokeObject obj) {
            Runtime runtime = obj.runtime;
            obj.Kind = "DefaultBehavior Definitions";

            obj.RegisterMethod(runtime.NewNativeMethod("expects any number of unevaluated arguments. if no arguments at all are given, will just return nil. creates a new method based on the arguments. this method will be evaluated using the context of the object it's called on, and thus the definition can not refer to the outside scope where the method is defined. (there are other ways of achieving this). all arguments except the last one is expected to be names of arguments that will be used in the method. there will possible be additions to the format of arguments later on - including named parameters and optional arguments. the actual code is the last argument given.", 
                                                       new NativeMethod("method", DefaultArgumentsDefinition.builder()
                                                                        .WithOptionalPositionalUnevaluated("documentation")
                                                                        .WithRestUnevaluated("argumentsAndBody")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);

                                                                            var args = message.Arguments;

                                                                            if(args.Count == 0) {
                                                                                Message mx = new Message(context.runtime, "nil", null, Message.Type.MESSAGE);
                                                                                mx.File = Message.GetFile(message);
                                                                                mx.Line = Message.GetLine(message);
                                                                                mx.Position = Message.GetPosition(message);
                                                                                IokeObject mmx = context.runtime.CreateMessage(mx);
                                                                                return runtime.NewMethod(null, runtime.DefaultMethod, new DefaultMethod(context, DefaultArgumentsDefinition.Empty(), mmx));
                                                                            }

                                                                            string doc = null;

                                                                            int start = 0;
                                                                            if(args.Count > 1 && ((IokeObject)Message.GetArguments(message)[0]).Name.Equals("internal:createText")) {
                                                                                start++;
                                                                                string s = (string)((IokeObject)args[0]).Arguments[0];
                                                                                doc = s;
                                                                            }

                                                                            DefaultArgumentsDefinition def = DefaultArgumentsDefinition.CreateFrom(args, start, args.Count-1, message, on, context);

                                                                            return runtime.NewMethod(doc, runtime.DefaultMethod, new DefaultMethod(context, def, (IokeObject)args[args.Count-1]));
                                                                        })));



        
            obj.RegisterMethod(runtime.NewNativeMethod("expects one code argument, optionally preceeded by a documentation string. will create a new DefaultMacro based on the code and return it.", 
                                                       new NativeMethod("macro", DefaultArgumentsDefinition.builder()
                                                                        .WithOptionalPositionalUnevaluated("documentation")
                                                                        .WithOptionalPositionalUnevaluated("body")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                            var args = message.Arguments;

                                                                            if(args.Count == 0) {
                                                                                Message mx = new Message(context.runtime, "nil", null, Message.Type.MESSAGE);
                                                                                mx.File = Message.GetFile(message);
                                                                                mx.Line = Message.GetLine(message);
                                                                                mx.Position = Message.GetPosition(message);
                                                                                IokeObject mmx = context.runtime.CreateMessage(mx);

                                                                                return runtime.NewMacro(null, runtime.DefaultMacro, new DefaultMacro(context, mmx));
                                                                            }
                                                                            
                                                                            string doc = null;

                                                                            int start = 0;
                                                                            if(args.Count > 1 && ((IokeObject)Message.GetArguments(message)[0]).Name.Equals("internal:createText")) {
                                                                                start++;
                                                                                string s = (string)(((IokeObject)args[0]).Arguments[0]);
                                                                                doc = s;
                                                                            }

                                                                            return runtime.NewMacro(doc, runtime.DefaultMacro, new DefaultMacro(context, (IokeObject)args[start]));
                                                                        })));



            obj.RegisterMethod(runtime.NewNativeMethod("creates a new lexical block that can be executed at will, while retaining a reference to the lexical closure it was created in. it will always update variables if they exist. there is currently no way of introducing shadowing variables in the local context. new variables can be created though, just like in a method. a lexical block mimics LexicalBlock, and can take arguments. at the moment these are restricted to required arguments, but support for the same argument types as DefaultMethod will come.", 
                                                       new NativeMethod("fn", DefaultArgumentsDefinition.builder()
                                                                        .WithOptionalPositionalUnevaluated("documentation")
                                                                        .WithRestUnevaluated("argumentsAndBody")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                            var args = message.Arguments;

                                                                            if(args.Count == 0) {
                                                                                return runtime.NewLexicalBlock(null, runtime.LexicalBlock, new LexicalBlock(context, DefaultArgumentsDefinition.Empty(), method.runtime.nilMessage));
                                                                            }

                                                                            string doc = null;

                                                                            int start = 0;
                                                                            if(args.Count > 1 && ((IokeObject)Message.GetArguments(message)[0]).Name.Equals("internal:createText")) {
                                                                                start++;
                                                                                string s = ((string)((IokeObject)args[0]).Arguments[0]);
                                                                                doc = s;
                                                                            }

                                                                            IokeObject code = IokeObject.As(args[args.Count-1], context);

                                                                            DefaultArgumentsDefinition def = DefaultArgumentsDefinition.CreateFrom(args, start, args.Count-1, message, on, context);
                                                                            return runtime.NewLexicalBlock(doc, runtime.LexicalBlock, new LexicalBlock(context, def, code));
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("creates a new lexical block that can be executed at will, while retaining a reference to the lexical closure it was created in. it will always update variables if they exist. there is currently no way of introducing shadowing variables in the local context. new variables can be created though, just like in a method. a lexical block mimics LexicalBlock, and can take arguments. at the moment these are restricted to required arguments, but support for the same argument types as DefaultMethod will come. same as fn()", 
                                                       new NativeMethod("\u028E", DefaultArgumentsDefinition.builder()
                                                                        .WithOptionalPositionalUnevaluated("documentation")
                                                                        .WithRestUnevaluated("argumentsAndBody")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                            var args = message.Arguments;

                                                                            if(args.Count == 0) {
                                                                                return runtime.NewLexicalBlock(null, runtime.LexicalBlock, new LexicalBlock(context, DefaultArgumentsDefinition.Empty(), method.runtime.nilMessage));
                                                                            }

                                                                            string doc = null;

                                                                            int start = 0;
                                                                            if(args.Count > 1 && ((IokeObject)Message.GetArguments(message)[0]).Name.Equals("internal:createText")) {
                                                                                start++;
                                                                                string s = ((string)((IokeObject)args[0]).Arguments[0]);
                                                                                doc = s;
                                                                            }

                                                                            IokeObject code = IokeObject.As(args[args.Count-1], context);

                                                                            DefaultArgumentsDefinition def = DefaultArgumentsDefinition.CreateFrom(args, start, args.Count-1, message, on, context);
                                                                            return runtime.NewLexicalBlock(doc, runtime.LexicalBlock, new LexicalBlock(context, def, code));
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("expects one code argument, optionally preceeded by a documentation string. will create a new LexicalMacro based on the code and return it.", 
                                                       new NativeMethod("lecro", DefaultArgumentsDefinition.builder()
                                                                        .WithOptionalPositionalUnevaluated("documentation")
                                                                        .WithOptionalPositionalUnevaluated("body")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                            var args = message.Arguments;

                                                                            if(args.Count == 0) {
                                                                                Message mx = new Message(context.runtime, "nil", null, Message.Type.MESSAGE);
                                                                                mx.File = Message.GetFile(message);
                                                                                mx.Line = Message.GetLine(message);
                                                                                mx.Position = Message.GetPosition(message);
                                                                                IokeObject mmx = context.runtime.CreateMessage(mx);

                                                                                return runtime.NewMacro(null, runtime.LexicalMacro, new LexicalMacro(context, mmx));
                                                                            }

                                                                            string doc = null;

                                                                            int start = 0;
                                                                            if(args.Count > 1 && ((IokeObject)Message.GetArguments(message)[0]).Name.Equals("internal:createText")) {
                                                                                start++;
                                                                                string s = ((string)((IokeObject)args[0]).Arguments[0]);
                                                                                doc = s;
                                                                            }

                                                                            return runtime.NewMacro(doc, runtime.LexicalMacro, new LexicalMacro(context, (IokeObject)args[start]));
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("expects one code argument, optionally preceeded by a documentation string. will create a new DefaultSyntax based on the code and return it.", 
                                                       new NativeMethod("syntax", DefaultArgumentsDefinition.builder()
                                                                        .WithOptionalPositionalUnevaluated("documentation")
                                                                        .WithOptionalPositionalUnevaluated("body")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                            var args = message.Arguments;
                                                                            
                                                                            if(args.Count == 0) {
                                                                                Message mx = new Message(context.runtime, "nil", null, Message.Type.MESSAGE);
                                                                                mx.File = Message.GetFile(message);
                                                                                mx.Line = Message.GetLine(message);
                                                                                mx.Position = Message.GetPosition(message);
                                                                                IokeObject mmx = context.runtime.CreateMessage(mx);
                                                                                
                                                                                return runtime.NewMacro(null, runtime.DefaultSyntax, new DefaultSyntax(context, mmx));
                                                                            }
                                                                            
                                                                            string doc = null;

                                                                            int start = 0;
                                                                            if(args.Count > 1 && ((IokeObject)Message.GetArguments(message)[0]).Name.Equals("internal:createText")) {
                                                                                start++;
                                                                                string s = (string)((IokeObject)args[0]).Arguments[0];
                                                                                doc = s;
                                                                            }

                                                                            return runtime.NewMacro(doc, runtime.DefaultSyntax, new DefaultSyntax(context, (IokeObject)args[start]));
                                                                        })));
            obj.RegisterMethod(runtime.NewNativeMethod("Takes two evaluated text or symbol arguments that name the method to alias, and the new name to give it. returns the receiver.", 
                                                       new NativeMethod("aliasMethod", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("oldName")
                                                                        .WithRequiredPositional("newName")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                            string fromName = Text.GetText(((Message)IokeObject.dataOf(runtime.asText)).SendTo(runtime.asText, context, args[0]));
                                                                            string toName = Text.GetText(((Message)IokeObject.dataOf(runtime.asText)).SendTo(runtime.asText, context, args[1]));
                                                                            IokeObject.As(on, context).AliasMethod(fromName, toName, message, context);
                                                                            return on;
                                                                        })));
        }
    }
}
