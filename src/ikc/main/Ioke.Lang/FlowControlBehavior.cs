
namespace Ioke.Lang {
    using System.Collections;
    using System.Collections.Generic;

    using Ioke.Lang.Util;

    public class FlowControlBehavior {
        public static void Init(IokeObject obj) {
            Runtime runtime = obj.runtime;
            obj.Kind = "DefaultBehavior FlowControl";

            obj.RegisterMethod(runtime.NewNativeMethod("evaluates the first arguments, and then evaluates the second argument if the result was true, otherwise the last argument. returns the result of the call, or the result if it's not true.", 
                                                       new NativeMethod("if", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("condition")
                                                                        .WithOptionalPositionalUnevaluated("then")
                                                                        .WithOptionalPositionalUnevaluated("else")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);

                                                                            object test = ((Message)IokeObject.dataOf(message)).GetEvaluatedArgument(message, 0, context);

                                                                            LexicalContext itContext = new LexicalContext(context.runtime, context.RealContext, "Lexical activation context", message, context);
                                                                            itContext.SetCell("it", test);

                                                                            if(IokeObject.IsObjectTrue(test)) {
                                                                                if(message.Arguments.Count > 1) {
                                                                                    return ((Message)IokeObject.dataOf(message)).GetEvaluatedArgument(message, 1, itContext);
                                                                                } else {
                                                                                    return test;
                                                                                }
                                                                            } else {
                                                                                if(message.Arguments.Count > 2) {
                                                                                    return ((Message)IokeObject.dataOf(message)).GetEvaluatedArgument(message, 2, itContext);
                                                                                } else {
                                                                                    return test;
                                                                                }
                                                                            }
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("evaluates the first arguments, and then evaluates the second argument if the result was false, otherwise the last argument. returns the result of the call, or the result if it's true.", 
                                                       new NativeMethod("unless", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("condition")
                                                                        .WithOptionalPositionalUnevaluated("then")
                                                                        .WithOptionalPositionalUnevaluated("else")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);

                                                                            object test = ((Message)IokeObject.dataOf(message)).GetEvaluatedArgument(message, 0, context);

                                                                            LexicalContext itContext = new LexicalContext(context.runtime, context.RealContext, "Lexical activation context", message, context);
                                                                            itContext.SetCell("it", test);

                                                                            if(IokeObject.IsObjectTrue(test)) {
                                                                                if(message.Arguments.Count > 2) {
                                                                                    return ((Message)IokeObject.dataOf(message)).GetEvaluatedArgument(message, 2, itContext);
                                                                                } else {
                                                                                    return test;
                                                                                }
                                                                            } else {
                                                                                if(message.Arguments.Count > 1) {
                                                                                    return ((Message)IokeObject.dataOf(message)).GetEvaluatedArgument(message, 1, itContext);
                                                                                } else {
                                                                                    return test;
                                                                                }
                                                                            }
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("takes zero or more place and value pairs and one code argument, establishes a new lexical scope and binds the places to the values given. if the place is a simple name, it will just be created as a new binding in the lexical scope. if it is a place specification, that place will be temporarily changed - but guaranteed to be changed back after the lexical scope is finished. the let-form returns the final result of the code argument.", 
                                                       new NativeMethod("let", DefaultArgumentsDefinition.builder()
                                                                        .WithRestUnevaluated("placesAndValues")
                                                                        .WithRequiredPositionalUnevaluated("code")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                            
                                                                            var args = message.Arguments;
                                                                            LexicalContext lc = new LexicalContext(context.runtime, context.RealContext, "Let lexical activation context", message, context);
                                                                            int ix = 0;
                                                                            int end = args.Count-1;
                                                                            var valuesToUnbind = new LinkedList<object[]>();
                                                                            try {
                                                                                while(ix < end) {
                                                                                    IokeObject place = IokeObject.As(args[ix++], context);

                                                                                    if(Message.GetNext(place) == null && place.Arguments.Count == 0) {
                                                                                        object value = ((Message)IokeObject.dataOf(message)).GetEvaluatedArgument(message, ix++, context);
                                                                                        lc.SetCell(Message.GetName(place), value);
                                                                                    } else {
                                                                                        place = Message.DeepCopy(place);
                                                                                        IokeObject realPlace = place;
                                                                                        while(Message.GetNext(realPlace) != null) {
                                                                                            if(Message.GetNext(Message.GetNext(realPlace)) == null) {
                                                                                                IokeObject temp = Message.GetNext(realPlace);
                                                                                                Message.SetNext(realPlace, null);
                                                                                                realPlace = temp;
                                                                                            } else {
                                                                                                realPlace = Message.GetNext(realPlace);
                                                                                            }
                                                                                        }

                                                                                        object wherePlace = context.RealContext;
                                                                                        if(place != realPlace) {
                                                                                            wherePlace = Message.GetEvaluatedArgument(place, context);
                                                                                        }
                                
                                                                                        object originalValue = runtime.WithReturningRescue(context, null, () => {return ((Message)IokeObject.dataOf(realPlace)).SendTo(realPlace, context, wherePlace);});
                                                                                        if(realPlace.Arguments.Count != 0) {
                                                                                            string newName = realPlace.Name + "=";
                                                                                            var arguments = new SaneArrayList(realPlace.Arguments);
                                                                                            arguments.Add(args[ix++]);
                                                                                            IokeObject msg = context.runtime.NewMessageFrom(realPlace, newName, arguments);
                                                                                            ((Message)IokeObject.dataOf(msg)).SendTo(msg, context, wherePlace);
                                                                                            valuesToUnbind.AddFirst(new object[]{wherePlace, originalValue, realPlace});
                                                                                        } else {
                                                                                            object value = ((Message)IokeObject.dataOf(message)).GetEvaluatedArgument(message, ix++, context);
                                                                                            IokeObject.Assign(wherePlace, realPlace.Name, value, context, message);
                                                                                            valuesToUnbind.AddFirst(new object[]{wherePlace, originalValue, realPlace});
                                                                                        }
                                                                                    }
                                                                                }

                                                                                return ((Message)IokeObject.dataOf(message)).GetEvaluatedArgument(message, end, lc);
                                                                            } finally {
                                                                                while(valuesToUnbind.Count > 0) {
                                                                                    try {
                                                                                        object[] vals = valuesToUnbind.First.Value;
                                                                                        valuesToUnbind.RemoveFirst();
                                                                                        IokeObject wherePlace = IokeObject.As(vals[0], context);
                                                                                        object value = vals[1];
                                                                                        IokeObject realPlace = IokeObject.As(vals[2], context);

                                                                                        if(realPlace.Arguments.Count != 0) {
                                                                                            string newName = realPlace.Name + "=";
                                                                                            var arguments = new SaneArrayList(realPlace.Arguments);

                                                                                            if(value == null) {
                                                                                                if(newName.Equals("cell=")) {
                                                                                                    ((Message)IokeObject.dataOf(context.runtime.removeCellMessage)).SendTo(context.runtime.removeCellMessage, context, wherePlace, new SaneArrayList(realPlace.Arguments));
                                                                                                } else {
                                                                                                    arguments.Add(context.runtime.CreateMessage(Message.Wrap(context.runtime.nil)));
                                                                                                    IokeObject msg = context.runtime.NewMessageFrom(realPlace, newName, arguments);
                                                                                                    ((Message)IokeObject.dataOf(msg)).SendTo(msg, context, wherePlace);
                                                                                                }
                                                                                            } else {
                                                                                                arguments.Add(context.runtime.CreateMessage(Message.Wrap(IokeObject.As(value, context))));
                                                                                                IokeObject msg = context.runtime.NewMessageFrom(realPlace, newName, arguments);
                                                                                                ((Message)IokeObject.dataOf(msg)).SendTo(msg, context, wherePlace);
                                                                                            }
                                                                                        } else {
                                                                                            if(value == null) {
                                                                                                IokeObject.RemoveCell(wherePlace, context, message, realPlace.Name);
                                                                                            } else {
                                                                                                IokeObject.Assign(wherePlace, realPlace.Name, value, context, message);
                                                                                            }
                                                                                        }
                                                                                    } catch(System.Exception) {}
                                                                                }
                                                                            }
                                                                        })));



            obj.RegisterMethod(runtime.NewNativeMethod("breaks out of the enclosing context. if an argument is supplied, this will be returned as the result of the object breaking out of", 
                                                       new NativeMethod("break", DefaultArgumentsDefinition.builder()
                                                                        .WithOptionalPositional("value", "nil")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            IList args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                            
                                                                            object value = runtime.nil;
                                                                            if(message.Arguments.Count > 0) {
                                                                                value = ((Message)IokeObject.dataOf(message)).GetEvaluatedArgument(message, 0, context);
                                                                            }
                                                                            throw new ControlFlow.Break(value);
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns from the enclosing method/macro. if an argument is supplied, this will be returned as the result of the method/macro breaking out of.", 
                                                       new NativeMethod("return", DefaultArgumentsDefinition.builder()
                                                                        .WithOptionalPositional("value", "nil")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            object value = runtime.nil;
                                                                            IList args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                            if(args.Count > 0) {
                                                                                value = args[0];
                                                                            }
                                                                            IokeObject ctx = context;
                                                                            while(ctx is LexicalContext) {
                                                                                ctx = ((LexicalContext)ctx).surroundingContext;
                                                                            }

                                                                            throw new ControlFlow.Return(value, ctx);
                                                                        })));
            
            obj.RegisterMethod(runtime.NewNativeMethod("breaks out of the enclosing context and continues from that point again.", 
                                                       new NativeMethod.WithNoArguments("continue",
                                                                                        (method, context, message, on, outer) => {
                                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, new SaneArrayList(), new SaneDictionary<string, object>());
                                                                                            throw new ControlFlow.Continue();
                                                                                        })));


            obj.RegisterMethod(runtime.NewNativeMethod("until the first argument evaluates to something true, loops and evaluates the next argument", 
                                                       new NativeMethod("until", DefaultArgumentsDefinition.builder()
                                                                        .WithOptionalPositionalUnevaluated("condition")
                                                                        .WithRestUnevaluated("body")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);

                                                                            if(message.Arguments.Count == 0) {
                                                                                return runtime.nil;
                                                                            }

                                                                            bool body = message.Arguments.Count > 1;
                                                                            object ret = runtime.nil;
                                                                            bool doAgain = false;
                                                                            do {
                                                                                doAgain = false;
                                                                                try {
                                                                                    while(!IokeObject.IsObjectTrue(((Message)IokeObject.dataOf(message)).GetEvaluatedArgument(message, 0, context))) {
                                                                                        if(body) {
                                                                                            ret = ((Message)IokeObject.dataOf(message)).GetEvaluatedArgument(message, 1, context);
                                                                                        }
                                                                                    }
                                                                                } catch(ControlFlow.Break e) {
                                                                                    ret = e.Value;
                                                                                } catch(ControlFlow.Continue) {
                                                                                    doAgain = true;
                                                                                }
                                                                            } while(doAgain);

                                                                            return ret;
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("while the first argument evaluates to something true, loops and evaluates the next argument", 
                                                       new NativeMethod("while", DefaultArgumentsDefinition.builder()
                                                                        .WithOptionalPositionalUnevaluated("condition")
                                                                        .WithRestUnevaluated("body")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);

                                                                            if(message.Arguments.Count == 0) {
                                                                                return runtime.nil;
                                                                            }

                                                                            bool body = message.Arguments.Count > 1;
                                                                            object ret = runtime.nil;
                                                                            bool doAgain = false;
                                                                            do {
                                                                                doAgain = false;
                                                                                try {
                                                                                    while(IokeObject.IsObjectTrue(((Message)IokeObject.dataOf(message)).GetEvaluatedArgument(message, 0, context))) {
                                                                                        if(body) {
                                                                                            ret = ((Message)IokeObject.dataOf(message)).GetEvaluatedArgument(message, 1, context);
                                                                                        }
                                                                                    }
                                                                                } catch(ControlFlow.Break e) {
                                                                                    ret = e.Value;
                                                                                } catch(ControlFlow.Continue) {
                                                                                    doAgain = true;
                                                                                }
                                                                            } while(doAgain);

                                                                            return ret;
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("loops forever - executing it's argument over and over until interrupted in some way.", 
                                                       new NativeMethod("loop", DefaultArgumentsDefinition.builder()
                                                                        .WithRestUnevaluated("body")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);

                                                                            if(message.Arguments.Count > 0) {
                                                                                while(true) {
                                                                                    try {
                                                                                        while(true) {
                                                                                            ((Message)IokeObject.dataOf(message)).GetEvaluatedArgument(message, 0, context);
                                                                                        }
                                                                                    } catch(ControlFlow.Break e) {
                                                                                        return e.Value;
                                                                                    } catch(ControlFlow.Continue) {
                                                                                    }
                                                                                }
                                                                            } else {
                                                                                while(true){}
                                                                            }
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("will execute and return the value of the first argument. after the code has run, all the remaining blocks of code are guaranteed to run in order even if a non-local flow control happens inside the main code. if any code in the ensure blocks generate a new non-local flow control, the rest of the ensure blocks in that specific ensure invocation are not guaranteed to run.", 
                                                       new NativeMethod("ensure", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositionalUnevaluated("code")
                                                                        .WithRestUnevaluated("ensureBlocks")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                            var args = message.Arguments;
                                                                            int argCount = args.Count;

                                                                            object result = runtime.nil;

                                                                            try {
                                                                                IokeObject msg = IokeObject.As(args[0], context);
                                                                                result = ((Message)IokeObject.dataOf(msg)).EvaluateCompleteWithoutExplicitReceiver(msg, context, context.RealContext);
                                                                            } finally {
                                                                                foreach(object o in ArrayList.Adapter(args).GetRange(1, argCount-1)) {
                                                                                    IokeObject msg = IokeObject.As(o, context);
                                                                                    ((Message)IokeObject.dataOf(msg)).EvaluateCompleteWithoutExplicitReceiver(msg, context, context.RealContext);
                                                                                }
                                                                            }

                                                                            return result;
                                                                        })));
        }
    }
}
