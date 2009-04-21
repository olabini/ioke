namespace Ioke.Lang {
    using System.Collections;
    using System.Collections.Generic;

    using Ioke.Lang.Util;

    public class LiteralsBehavior {
        public static void Init(IokeObject obj) {
            Runtime runtime = obj.runtime;
            obj.Kind = "DefaultBehavior Literals";

            obj.RegisterMethod(runtime.NewNativeMethod("Takes one evaluated argument that is expected to be a Text, and returns the symbol corresponding to that text", 
                                                       new NativeMethod(":", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("symbolText")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                            
                                                                            string sym = Text.GetText(((Message)IokeObject.dataOf(runtime.asText)).SendTo(runtime.asText, context, args[0]));
                                                                            return runtime.GetSymbol(sym);
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("Takes one evaluated argument and returns a new Pair of the receiver and the argument", 
                                                       new NativeMethod("=>", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("other")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                            return context.runtime.NewPair(on, args[0]);
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns a new message with the name given as argument to this method.", 
                                                       new NativeMethod("message", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("name")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());

                                                                            object o = args[0];
                    
                                                                            string name = null;
                                                                            if(IokeObject.dataOf(o) is Text) {
                                                                                name = Text.GetText(o);
                                                                            } else {
                                                                                name = Text.GetText(((Message)IokeObject.dataOf(context.runtime.asText)).SendTo(context.runtime.asText, context, o));
                                                                            }

                                                                            Message m = new Message(context.runtime, name);
                                                                            IokeObject ret = context.runtime.CreateMessage(m);
                                                                            if(".".Equals(name)) {
                                                                                Message.SetType(ret, Message.Type.TERMINATOR);
                                                                            }
                                                                            Message.CopySourceLocation(message, ret);
                                                                            return ret;
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("creates a new Set from the result of evaluating all arguments provided.", 
                                                       new NativeMethod("set", DefaultArgumentsDefinition.builder()
                                                                        .WithRest("elements")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                            return context.runtime.NewSet(args);
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("creates a new Dict from the arguments provided. these arguments can be two different things - either a keyword argument, or a pair. if it's a keyword argument, the entry added to the dict for it will be a symbol with the name from the keyword, without the ending colon. if it's not a keyword, it is expected to be an evaluated pair, where the first part of the pair is the key, and the second part is the value.", 
                                                       new NativeMethod("dict",  DefaultArgumentsDefinition.builder()
                                                                        .WithRest("pairs")
                                                                        .WithKeywordRest("keywordPairs")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                            var arguments = message.Arguments;
                                                                            var moo = new SaneHashtable(arguments.Count);

                                                                            foreach(object o in arguments) {
                                                                                object key, value;
                                                                                if(Message.IsKeyword(o)) {
                                                                                    string str = Message.GetName(o);
                                                                                    key = context.runtime.GetSymbol(str.Substring(0, str.Length-1));
                                                                                    if(Message.GetNext(o) != null) {
                                                                                        value = Message.GetEvaluatedArgument(Message.GetNext(o), context);
                                                                                    } else {
                                                                                        value = context.runtime.nil;
                                                                                    }
                                                                                } else {
                                                                                    object result = Message.GetEvaluatedArgument(o, context);
                                                                                    if((result is IokeObject) && (IokeObject.dataOf(result) is Pair)) {
                                                                                        key = Pair.GetFirst(result);
                                                                                        value = Pair.GetSecond(result);
                                                                                    } else {
                                                                                        key = result;
                                                                                        value = context.runtime.nil;
                                                                                    }
                                                                                }

                                                                                moo[key] = value;
                                                                            }

                                                                            return context.runtime.NewDict(moo);
                                                                        })));
        }
    }
}
