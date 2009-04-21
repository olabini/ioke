
namespace Ioke.Lang {
    public class AssignmentBehavior {
        public static void Init(IokeObject obj) {
            Runtime runtime = obj.runtime;
            obj.Kind = "DefaultBehavior Assignment";

            obj.RegisterMethod(runtime.NewNativeMethod("expects one argument, which is the unevaluated name of the cell to work on. will retrieve the current value of this cell, call 'succ' to that value and then send = to the current receiver with the name and the resulting value.", 
                                                       new NativeMethod("++", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositionalUnevaluated("place")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                            IokeObject nameMessage = (IokeObject)(Message.GetArguments(message)[0]);
                                                                            string name = nameMessage.Name;
                                                                            object current = IokeObject.As(on, context).Perform(context, message, name);
                                                                            object value = ((Message)IokeObject.dataOf(runtime.succMessage)).SendTo(runtime.succMessage, context, current);
                                                                            return ((Message)IokeObject.dataOf(runtime.setValueMessage)).SendTo(runtime.setValueMessage, context, on, nameMessage, value);
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("expects one argument, which is the unevaluated name of the cell to work on. will retrieve the current value of this cell, call 'pred' to that value and then send = to the current receiver with the name and the resulting value.", 
                                                       new NativeMethod("--", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositionalUnevaluated("place")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                            IokeObject nameMessage = (IokeObject)(Message.GetArguments(message)[0]);
                                                                            string name = nameMessage.Name;
                                                                            object current = IokeObject.As(on, context).Perform(context, message, name);
                                                                            object value = ((Message)IokeObject.dataOf(runtime.predMessage)).SendTo(runtime.predMessage, context, current);
                                                                            return ((Message)IokeObject.dataOf(runtime.setValueMessage)).SendTo(runtime.setValueMessage, context, on, nameMessage, value);
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. if that cell doesn't exist or the value it contains is not true, that cell will be set to the second argument, otherwise nothing will happen. the second argument will NOT be evaluated if the place is not assigned. the result of the expression is the value of the cell. it will use = for this assignment. this method also work together with forms such as []=.", 
                                                       new NativeMethod("||=", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositionalUnevaluated("place")
                                                                        .WithRequiredPositional("else")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);

                                                                            IokeObject m1 = IokeObject.As(Message.GetArguments(message)[0], context);
                                                                            string name = m1.Name;

                                                                            if(m1.Arguments.Count == 0) {
                                                                                object val = IokeObject.FindCell(on, message, context, name);
                                                                                if(val == context.runtime.nul || !IokeObject.IsObjectTrue(val)) {
                                                                                    return ((Message)IokeObject.dataOf(context.runtime.setValueMessage)).SendTo(context.runtime.setValueMessage, context, on, m1, Message.GetArguments(message)[1]);
                                                                                } else {
                                                                                    return val;
                                                                                }
                                                                            } else {
                                                                                object val = ((Message)IokeObject.dataOf(m1)).SendTo(m1, context, on);
                                                                                if(val == context.runtime.nul || !IokeObject.IsObjectTrue(val)) {
                                                                                    return ((Message)IokeObject.dataOf(context.runtime.setValueMessage)).SendTo(context.runtime.setValueMessage, context, on, m1, Message.GetArguments(message)[1]);
                                                                                } else {
                                                                                    return val;
                                                                                }
                                                                            }
                                                                        })));
            
            obj.RegisterMethod(runtime.NewNativeMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. if that cell exist and the value it contains is a true one, that cell will be set to the second argument, otherwise nothing will happen. the second argument will NOT be evaluated if the place is not assigned. the result of the expression is the value of the cell. it will use = for this assignment. this method also work together with forms such as []=.", 
                                                       new NativeMethod("&&=", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositionalUnevaluated("place")
                                                                        .WithRequiredPositional("then")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);

                                                                            IokeObject m1 = IokeObject.As(Message.GetArguments(message)[0], context);
                                                                            string name = m1.Name;

                                                                            if(m1.Arguments.Count == 0) {
                                                                                object val = IokeObject.FindCell(on, message, context, name);
                                                                                if(val == context.runtime.nul || !IokeObject.IsObjectTrue(val)) {
                                                                                    return val;
                                                                                } else {
                                                                                    return ((Message)IokeObject.dataOf(context.runtime.setValueMessage)).SendTo(context.runtime.setValueMessage, context, on, m1, Message.GetArguments(message)[1]);
                                                                                }
                                                                            } else {
                                                                                object val = ((Message)IokeObject.dataOf(m1)).SendTo(m1, context, on);
                                                                                if(val == context.runtime.nul || !IokeObject.IsObjectTrue(val)) {
                                                                                    return val;
                                                                                } else {
                                                                                    return ((Message)IokeObject.dataOf(context.runtime.setValueMessage)).SendTo(context.runtime.setValueMessage, context, on, m1, Message.GetArguments(message)[1]);
                                                                                }
                                                                            }
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the + method will be called on it. finally, the result of the call to + will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.", 
                                                       new NativeMethod("+=", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositionalUnevaluated("place")
                                                                        .WithRequiredPositional("addend")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                            
                                                                            IokeObject m1 = IokeObject.As(Message.GetArguments(message)[0], context);
                                                                            string name = m1.Name;

                                                                            if(m1.Arguments.Count == 0) {
                                                                                object val = IokeObject.GetCell(on, message, context, name);
                                                                                object result = ((Message)IokeObject.dataOf(context.runtime.plusMessage)).SendTo(context.runtime.plusMessage, context, val, Message.GetArguments(message)[1]);
                                                                                return ((Message)IokeObject.dataOf(context.runtime.setValueMessage)).SendTo(context.runtime.setValueMessage, context, on, m1, context.runtime.CreateMessage(Message.Wrap(IokeObject.As(result, context))));
                                                                            } else {
                                                                                object val = ((Message)IokeObject.dataOf(m1)).SendTo(m1, context, on);
                                                                                object result = ((Message)IokeObject.dataOf(context.runtime.plusMessage)).SendTo(context.runtime.plusMessage, context, val, Message.GetArguments(message)[1]);
                                                                                return ((Message)IokeObject.dataOf(context.runtime.setValueMessage)).SendTo(context.runtime.setValueMessage, context, on, m1, context.runtime.CreateMessage(Message.Wrap(IokeObject.As(result, context))));
                                                                            }
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the - method will be called on it. finally, the result of the call to - will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.", 
                                                       new NativeMethod("-=", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositionalUnevaluated("place")
                                                                        .WithRequiredPositional("subtrahend")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                            
                                                                            IokeObject m1 = IokeObject.As(Message.GetArguments(message)[0], context);
                                                                            string name = m1.Name;

                                                                            if(m1.Arguments.Count == 0) {
                                                                                object val = IokeObject.GetCell(on, message, context, name);
                                                                                object result = ((Message)IokeObject.dataOf(context.runtime.minusMessage)).SendTo(context.runtime.minusMessage, context, val, Message.GetArguments(message)[1]);
                                                                                return ((Message)IokeObject.dataOf(context.runtime.setValueMessage)).SendTo(context.runtime.setValueMessage, context, on, m1, context.runtime.CreateMessage(Message.Wrap(IokeObject.As(result, context))));
                                                                            } else {
                                                                                object val = ((Message)IokeObject.dataOf(m1)).SendTo(m1, context, on);
                                                                                object result = ((Message)IokeObject.dataOf(context.runtime.minusMessage)).SendTo(context.runtime.minusMessage, context, val, Message.GetArguments(message)[1]);
                                                                                return ((Message)IokeObject.dataOf(context.runtime.setValueMessage)).SendTo(context.runtime.setValueMessage, context, on, m1, context.runtime.CreateMessage(Message.Wrap(IokeObject.As(result, context))));
                                                                            }
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the * method will be called on it. finally, the result of the call to * will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.", 
                                                       new NativeMethod("*=", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositionalUnevaluated("place")
                                                                        .WithRequiredPositional("multiplier")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                            
                                                                            IokeObject m1 = IokeObject.As(Message.GetArguments(message)[0], context);
                                                                            string name = m1.Name;

                                                                            if(m1.Arguments.Count == 0) {
                                                                                object val = IokeObject.GetCell(on, message, context, name);
                                                                                object result = ((Message)IokeObject.dataOf(context.runtime.multMessage)).SendTo(context.runtime.multMessage, context, val, Message.GetArguments(message)[1]);
                                                                                return ((Message)IokeObject.dataOf(context.runtime.setValueMessage)).SendTo(context.runtime.setValueMessage, context, on, m1, context.runtime.CreateMessage(Message.Wrap(IokeObject.As(result, context))));
                                                                            } else {
                                                                                object val = ((Message)IokeObject.dataOf(m1)).SendTo(m1, context, on);
                                                                                object result = ((Message)IokeObject.dataOf(context.runtime.multMessage)).SendTo(context.runtime.multMessage, context, val, Message.GetArguments(message)[1]);
                                                                                return ((Message)IokeObject.dataOf(context.runtime.setValueMessage)).SendTo(context.runtime.setValueMessage, context, on, m1, context.runtime.CreateMessage(Message.Wrap(IokeObject.As(result, context))));
                                                                            }
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the / method will be called on it. finally, the result of the call to / will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.", 
                                                       new NativeMethod("/=", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositionalUnevaluated("place")
                                                                        .WithRequiredPositional("divisor")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                            
                                                                            IokeObject m1 = IokeObject.As(Message.GetArguments(message)[0], context);
                                                                            string name = m1.Name;

                                                                            if(m1.Arguments.Count == 0) {
                                                                                object val = IokeObject.GetCell(on, message, context, name);
                                                                                object result = ((Message)IokeObject.dataOf(context.runtime.divMessage)).SendTo(context.runtime.divMessage, context, val, Message.GetArguments(message)[1]);
                                                                                return ((Message)IokeObject.dataOf(context.runtime.setValueMessage)).SendTo(context.runtime.setValueMessage, context, on, m1, context.runtime.CreateMessage(Message.Wrap(IokeObject.As(result, context))));
                                                                            } else {
                                                                                object val = ((Message)IokeObject.dataOf(m1)).SendTo(m1, context, on);
                                                                                object result = ((Message)IokeObject.dataOf(context.runtime.divMessage)).SendTo(context.runtime.divMessage, context, val, Message.GetArguments(message)[1]);
                                                                                return ((Message)IokeObject.dataOf(context.runtime.setValueMessage)).SendTo(context.runtime.setValueMessage, context, on, m1, context.runtime.CreateMessage(Message.Wrap(IokeObject.As(result, context))));
                                                                            }
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the % method will be called on it. finally, the result of the call to % will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.", 
                                                       new NativeMethod("%=", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositionalUnevaluated("place")
                                                                        .WithRequiredPositional("divisor")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                            
                                                                            IokeObject m1 = IokeObject.As(Message.GetArguments(message)[0], context);
                                                                            string name = m1.Name;

                                                                            if(m1.Arguments.Count == 0) {
                                                                                object val = IokeObject.GetCell(on, message, context, name);
                                                                                object result = ((Message)IokeObject.dataOf(context.runtime.modMessage)).SendTo(context.runtime.modMessage, context, val, Message.GetArguments(message)[1]);
                                                                                return ((Message)IokeObject.dataOf(context.runtime.setValueMessage)).SendTo(context.runtime.setValueMessage, context, on, m1, context.runtime.CreateMessage(Message.Wrap(IokeObject.As(result, context))));
                                                                            } else {
                                                                                object val = ((Message)IokeObject.dataOf(m1)).SendTo(m1, context, on);
                                                                                object result = ((Message)IokeObject.dataOf(context.runtime.modMessage)).SendTo(context.runtime.modMessage, context, val, Message.GetArguments(message)[1]);
                                                                                return ((Message)IokeObject.dataOf(context.runtime.setValueMessage)).SendTo(context.runtime.setValueMessage, context, on, m1, context.runtime.CreateMessage(Message.Wrap(IokeObject.As(result, context))));
                                                                            }
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the ** method will be called on it. finally, the result of the call to ** will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.", 
                                                       new NativeMethod("**=", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositionalUnevaluated("place")
                                                                        .WithRequiredPositional("exponent")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                            
                                                                            IokeObject m1 = IokeObject.As(Message.GetArguments(message)[0], context);
                                                                            string name = m1.Name;

                                                                            if(m1.Arguments.Count == 0) {
                                                                                object val = IokeObject.GetCell(on, message, context, name);
                                                                                object result = ((Message)IokeObject.dataOf(context.runtime.expMessage)).SendTo(context.runtime.expMessage, context, val, Message.GetArguments(message)[1]);
                                                                                return ((Message)IokeObject.dataOf(context.runtime.setValueMessage)).SendTo(context.runtime.setValueMessage, context, on, m1, context.runtime.CreateMessage(Message.Wrap(IokeObject.As(result, context))));
                                                                            } else {
                                                                                object val = ((Message)IokeObject.dataOf(m1)).SendTo(m1, context, on);
                                                                                object result = ((Message)IokeObject.dataOf(context.runtime.expMessage)).SendTo(context.runtime.expMessage, context, val, Message.GetArguments(message)[1]);
                                                                                return ((Message)IokeObject.dataOf(context.runtime.setValueMessage)).SendTo(context.runtime.setValueMessage, context, on, m1, context.runtime.CreateMessage(Message.Wrap(IokeObject.As(result, context))));
                                                                            }
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the & method will be called on it. finally, the result of the call to & will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.", 
                                                       new NativeMethod("&=", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositionalUnevaluated("place")
                                                                        .WithRequiredPositional("other")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                            
                                                                            IokeObject m1 = IokeObject.As(Message.GetArguments(message)[0], context);
                                                                            string name = m1.Name;

                                                                            if(m1.Arguments.Count == 0) {
                                                                                object val = IokeObject.GetCell(on, message, context, name);
                                                                                object result = ((Message)IokeObject.dataOf(context.runtime.binAndMessage)).SendTo(context.runtime.binAndMessage, context, val, Message.GetArguments(message)[1]);
                                                                                return ((Message)IokeObject.dataOf(context.runtime.setValueMessage)).SendTo(context.runtime.setValueMessage, context, on, m1, context.runtime.CreateMessage(Message.Wrap(IokeObject.As(result, context))));
                                                                            } else {
                                                                                object val = ((Message)IokeObject.dataOf(m1)).SendTo(m1, context, on);
                                                                                object result = ((Message)IokeObject.dataOf(context.runtime.binAndMessage)).SendTo(context.runtime.binAndMessage, context, val, Message.GetArguments(message)[1]);
                                                                                return ((Message)IokeObject.dataOf(context.runtime.setValueMessage)).SendTo(context.runtime.setValueMessage, context, on, m1, context.runtime.CreateMessage(Message.Wrap(IokeObject.As(result, context))));
                                                                            }
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the | method will be called on it. finally, the result of the call to | will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.", 
                                                       new NativeMethod("|=", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositionalUnevaluated("place")
                                                                        .WithRequiredPositional("other")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                            
                                                                            IokeObject m1 = IokeObject.As(Message.GetArguments(message)[0], context);
                                                                            string name = m1.Name;

                                                                            if(m1.Arguments.Count == 0) {
                                                                                object val = IokeObject.GetCell(on, message, context, name);
                                                                                object result = ((Message)IokeObject.dataOf(context.runtime.binOrMessage)).SendTo(context.runtime.binOrMessage, context, val, Message.GetArguments(message)[1]);
                                                                                return ((Message)IokeObject.dataOf(context.runtime.setValueMessage)).SendTo(context.runtime.setValueMessage, context, on, m1, context.runtime.CreateMessage(Message.Wrap(IokeObject.As(result, context))));
                                                                            } else {
                                                                                object val = ((Message)IokeObject.dataOf(m1)).SendTo(m1, context, on);
                                                                                object result = ((Message)IokeObject.dataOf(context.runtime.binOrMessage)).SendTo(context.runtime.binOrMessage, context, val, Message.GetArguments(message)[1]);
                                                                                return ((Message)IokeObject.dataOf(context.runtime.setValueMessage)).SendTo(context.runtime.setValueMessage, context, on, m1, context.runtime.CreateMessage(Message.Wrap(IokeObject.As(result, context))));
                                                                            }
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the ^ method will be called on it. finally, the result of the call to ^ will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.", 
                                                       new NativeMethod("^=", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositionalUnevaluated("place")
                                                                        .WithRequiredPositional("other")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                            
                                                                            IokeObject m1 = IokeObject.As(Message.GetArguments(message)[0], context);
                                                                            string name = m1.Name;

                                                                            if(m1.Arguments.Count == 0) {
                                                                                object val = IokeObject.GetCell(on, message, context, name);
                                                                                object result = ((Message)IokeObject.dataOf(context.runtime.binXorMessage)).SendTo(context.runtime.binXorMessage, context, val, Message.GetArguments(message)[1]);
                                                                                return ((Message)IokeObject.dataOf(context.runtime.setValueMessage)).SendTo(context.runtime.setValueMessage, context, on, m1, context.runtime.CreateMessage(Message.Wrap(IokeObject.As(result, context))));
                                                                            } else {
                                                                                object val = ((Message)IokeObject.dataOf(m1)).SendTo(m1, context, on);
                                                                                object result = ((Message)IokeObject.dataOf(context.runtime.binXorMessage)).SendTo(context.runtime.binXorMessage, context, val, Message.GetArguments(message)[1]);
                                                                                return ((Message)IokeObject.dataOf(context.runtime.setValueMessage)).SendTo(context.runtime.setValueMessage, context, on, m1, context.runtime.CreateMessage(Message.Wrap(IokeObject.As(result, context))));
                                                                            }
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the << method will be called on it. finally, the result of the call to << will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.", 
                                                       new NativeMethod("<<=", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositionalUnevaluated("place")
                                                                        .WithRequiredPositional("other")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                            
                                                                            IokeObject m1 = IokeObject.As(Message.GetArguments(message)[0], context);
                                                                            string name = m1.Name;

                                                                            if(m1.Arguments.Count == 0) {
                                                                                object val = IokeObject.GetCell(on, message, context, name);
                                                                                object result = ((Message)IokeObject.dataOf(context.runtime.lshMessage)).SendTo(context.runtime.lshMessage, context, val, Message.GetArguments(message)[1]);
                                                                                return ((Message)IokeObject.dataOf(context.runtime.setValueMessage)).SendTo(context.runtime.setValueMessage, context, on, m1, context.runtime.CreateMessage(Message.Wrap(IokeObject.As(result, context))));
                                                                            } else {
                                                                                object val = ((Message)IokeObject.dataOf(m1)).SendTo(m1, context, on);
                                                                                object result = ((Message)IokeObject.dataOf(context.runtime.lshMessage)).SendTo(context.runtime.lshMessage, context, val, Message.GetArguments(message)[1]);
                                                                                return ((Message)IokeObject.dataOf(context.runtime.setValueMessage)).SendTo(context.runtime.setValueMessage, context, on, m1, context.runtime.CreateMessage(Message.Wrap(IokeObject.As(result, context))));
                                                                            }
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the >> method will be called on it. finally, the result of the call to >> will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.", 
                                                       new NativeMethod(">>=", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositionalUnevaluated("place")
                                                                        .WithRequiredPositional("other")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                            
                                                                            IokeObject m1 = IokeObject.As(Message.GetArguments(message)[0], context);
                                                                            string name = m1.Name;

                                                                            if(m1.Arguments.Count == 0) {
                                                                                object val = IokeObject.GetCell(on, message, context, name);
                                                                                object result = ((Message)IokeObject.dataOf(context.runtime.rshMessage)).SendTo(context.runtime.rshMessage, context, val, Message.GetArguments(message)[1]);
                                                                                return ((Message)IokeObject.dataOf(context.runtime.setValueMessage)).SendTo(context.runtime.setValueMessage, context, on, m1, context.runtime.CreateMessage(Message.Wrap(IokeObject.As(result, context))));
                                                                            } else {
                                                                                object val = ((Message)IokeObject.dataOf(m1)).SendTo(m1, context, on);
                                                                                object result = ((Message)IokeObject.dataOf(context.runtime.rshMessage)).SendTo(context.runtime.rshMessage, context, val, Message.GetArguments(message)[1]);
                                                                                return ((Message)IokeObject.dataOf(context.runtime.setValueMessage)).SendTo(context.runtime.setValueMessage, context, on, m1, context.runtime.CreateMessage(Message.Wrap(IokeObject.As(result, context))));
                                                                            }
                                                                        })));
        }
    }
}
