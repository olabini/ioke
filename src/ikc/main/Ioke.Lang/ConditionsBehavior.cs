namespace Ioke.Lang {
    using Ioke.Lang.Util;
    using System.Collections;
    using System.Collections.Generic;

    public class ConditionsBehavior {
        public static IokeObject Signal(object datum, IList positionalArgs, IDictionary<string, object> keywordArgs, IokeObject message, IokeObject context) {
            IokeObject newCondition = null;
            if(Text.IsText(datum)) {
                newCondition = IokeObject.As(context.runtime.Condition.GetCell(message, context, "Default"), context).Mimic(message, context);
                newCondition.SetCell("context", context);
                newCondition.SetCell("text", datum);
            } else {
                if(keywordArgs.Count == 0) {
                    newCondition = IokeObject.As(datum, context);
                } else {
                    newCondition = IokeObject.As(datum, context).Mimic(message, context);
                    newCondition.SetCell("context", context);
                    foreach(var val in keywordArgs) {
                        string s = val.Key;
                        newCondition.SetCell(s.Substring(0, s.Length-1), val.Value);
                    }
                }
            }

            Runtime.RescueInfo rescue = context.runtime.FindActiveRescueFor(newCondition);

            IList<Runtime.HandlerInfo> handlers = context.runtime.FindActiveHandlersFor(newCondition, (rescue == null) ? new Runtime.BindIndex(-1,-1) : rescue.index);
        
            foreach(Runtime.HandlerInfo rhi in handlers) {
                ((Message)IokeObject.dataOf(context.runtime.callMessage)).SendTo(context.runtime.callMessage, context, ((Message)IokeObject.dataOf(context.runtime.handlerMessage)).SendTo(context.runtime.handlerMessage, context, rhi.handler), newCondition);
            }

            if(rescue != null) {
                throw new ControlFlow.Rescue(rescue, newCondition);
            }
                    
            return newCondition;
        }

        public static void Init(IokeObject obj) {
            Runtime runtime = obj.runtime;
            obj.Kind = "DefaultBehavior Conditions";

            obj.RegisterMethod(runtime.NewNativeMethod("takes one optional unevaluated parameter (this should be the first if provided), that is the name of the restart to create. this will default to nil. takes two keyword arguments, report: and test:. These should both be lexical blocks. if not provided, there will be reasonable defaults. the only required argument is something that evaluates into a lexical block. this block is what will be executed when the restart is invoked. will return a Restart mimic.", 
                                                       new NativeMethod("restart", DefaultArgumentsDefinition.builder()
                                                                        .WithOptionalPositionalUnevaluated("name")
                                                                        .WithKeyword("report")
                                                                        .WithKeyword("test")
                                                                        .WithRequiredPositional("action")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);

                                                                            string name = null;
                                                                            IokeObject report = null;
                                                                            IokeObject test = null;
                                                                            IokeObject code = null;
                    
                                                                            IList args = message.Arguments;
                                                                            int argCount = args.Count;
                                                                            if(argCount > 4) {
                                                                                IokeObject condition = IokeObject.As(IokeObject.GetCellChain(runtime.Condition, 
                                                                                                                                             message, 
                                                                                                                                             context, 
                                                                                                                                             "Error", 
                                                                                                                                             "Invocation", 
                                                                                                                                             "TooManyArguments"), context).Mimic(message, context);
                                                                                condition.SetCell("message", message);
                                                                                condition.SetCell("context", context);
                                                                                condition.SetCell("receiver", on);
                                                                                condition.SetCell("extra", runtime.NewList(ArrayList.Adapter(args).GetRange(4, argCount-4)));
                                                                                runtime.WithReturningRestart("ignoreExtraArguments", context, () => {runtime.ErrorCondition(condition);});
                                                                                argCount = 4;
                                                                            } else if(argCount < 1) {
                                                                                IokeObject condition = IokeObject.As(IokeObject.GetCellChain(runtime.Condition, 
                                                                                                                                             message, 
                                                                                                                                             context, 
                                                                                                                                             "Error", 
                                                                                                                                             "Invocation", 
                                                                                                                                             "TooFewArguments"), context).Mimic(message, context);
                                                                                condition.SetCell("message", message);
                                                                                condition.SetCell("context", context);
                                                                                condition.SetCell("receiver", on);
                                                                                condition.SetCell("missing", runtime.NewNumber(1-argCount));
                
                                                                                runtime.ErrorCondition(condition);
                                                                            }

                                                                            for(int i=0; i<argCount; i++) {
                                                                                object o = args[i];
                                                                                Message m = (Message)IokeObject.dataOf(o);
                                                                                if(m.IsKeyword()) {
                                                                                    string n = m.Name;
                                                                                    if(n.Equals("report:")) {
                                                                                        report = IokeObject.As(((Message)IokeObject.dataOf(m.next)).EvaluateCompleteWithoutExplicitReceiver(m.next, context, context.RealContext), context);
                                                                                    } else if(n.Equals("test:")) {
                                                                                        test = IokeObject.As(((Message)IokeObject.dataOf(m.next)).EvaluateCompleteWithoutExplicitReceiver(m.next, context, context.RealContext), context);
                                                                                    } else {
                                                                                        IokeObject condition = IokeObject.As(IokeObject.GetCellChain(runtime.Condition, 
                                                                                                                                                     message, 
                                                                                                                                                     context, 
                                                                                                                                                     "Error", 
                                                                                                                                                     "Invocation", 
                                                                                                                                                     "MismatchedKeywords"), context).Mimic(message, context);
                                                                                        condition.SetCell("message", message);
                                                                                        condition.SetCell("context", context);
                                                                                        condition.SetCell("receiver", on);
                                                                                        condition.SetCell("expected", runtime.NewList(new SaneArrayList(new object[]{runtime.NewText("report:"), runtime.NewText("test:")})));
                                                                                        IList extra = new SaneArrayList();
                                                                                        extra.Add(runtime.NewText(n));
                                                                                        condition.SetCell("extra", runtime.NewList(extra));
                                
                                                                                        runtime.WithReturningRestart("ignoreExtraKeywords", context, () => {runtime.ErrorCondition(condition);});
                                                                                    }
                                                                                } else {
                                                                                    if(code != null) {
                                                                                        name = code.Name;
                                                                                        code = IokeObject.As(o, context);
                                                                                    } else {
                                                                                        code = IokeObject.As(o, context);
                                                                                    }
                                                                                }
                                                                            }

                                                                            code = IokeObject.As(((Message)IokeObject.dataOf(code)).EvaluateCompleteWithoutExplicitReceiver(code, context, context.RealContext), context);
                                                                            object restart = ((Message)IokeObject.dataOf(runtime.mimicMessage)).SendTo(runtime.mimicMessage, context, runtime.Restart);
                    
                                                                            IokeObject.SetCell(restart, "code", code, context);

                                                                            if(null != name) {
                                                                                IokeObject.SetCell(restart, "name", runtime.GetSymbol(name), context);
                                                                            }

                                                                            if(null != test) {
                                                                                IokeObject.SetCell(restart, "test", test, context);
                                                                            }

                                                                            if(null != report) {
                                                                                IokeObject.SetCell(restart, "report", report, context);
                                                                            }

                                                                            return restart;
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("takes zero or more arguments that should evaluate to a condition mimic - this list will match all the conditions this Rescue should be able to catch. the last argument is not optional, and should be something activatable that takes one argument - the condition instance. will return a Rescue mimic.", 
                                                       new NativeMethod("rescue", DefaultArgumentsDefinition.builder()
                                                                        .WithRest("conditionsAndAction")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                            int count = message.Arguments.Count;
                                                                            IList conds = new SaneArrayList();
                                                                            for(int i=0, j=count-1; i<j; i++) {
                                                                                conds.Add(((Message)IokeObject.dataOf(message)).GetEvaluatedArgument(message, i, context));
                                                                            }

                                                                            if(conds.Count == 0) {
                                                                                conds.Add(context.runtime.Condition);
                                                                            }

                                                                            object handler = ((Message)IokeObject.dataOf(message)).GetEvaluatedArgument(message, count-1, context);
                                                                            object rescue = ((Message)IokeObject.dataOf(context.runtime.mimicMessage)).SendTo(context.runtime.mimicMessage, context, context.runtime.Rescue);
                    
                                                                            IokeObject.SetCell(rescue, "handler", handler, context);
                                                                            IokeObject.SetCell(rescue, "conditions", context.runtime.NewList(conds), context);

                                                                            return rescue;
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("takes zero or more arguments that should evaluate to a condition mimic - this list will match all the conditions this Handler should be able to catch. the last argument is not optional, and should be something activatable that takes one argument - the condition instance. will return a Handler mimic.", 
                                                       new NativeMethod("handle", DefaultArgumentsDefinition.builder()
                                                                        .WithRest("conditionsAndAction")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                            int count = message.Arguments.Count;
                                                                            IList conds = new SaneArrayList();
                                                                            for(int i=0, j=count-1; i<j; i++) {
                                                                                conds.Add(((Message)IokeObject.dataOf(message)).GetEvaluatedArgument(message, i, context));
                                                                            }

                                                                            if(conds.Count == 0) {
                                                                                conds.Add(context.runtime.Condition);
                                                                            }

                                                                            object code = ((Message)IokeObject.dataOf(message)).GetEvaluatedArgument(message, count-1, context);
                                                                            object handle = ((Message)IokeObject.dataOf(context.runtime.mimicMessage)).SendTo(context.runtime.mimicMessage, context, context.runtime.Handler);
                    
                                                                            IokeObject.SetCell(handle, "handler", code, context);
                                                                            IokeObject.SetCell(handle, "conditions", context.runtime.NewList(conds), context);

                                                                            return handle;
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("will evaluate all arguments, and expects all except for the last to be a Restart. bind will associate these restarts for the duration of the execution of the last argument and then unbind them again. it will return the result of the last argument, or if a restart is executed it will instead return the result of that invocation.", 
                                                       new NativeMethod("bind", DefaultArgumentsDefinition.builder()
                                                                        .WithRestUnevaluated("bindablesAndCode")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);

                                                                            IList args = message.Arguments;
                                                                            int argCount = args.Count;
                                                                            if(argCount == 0) {
                                                                                return context.runtime.nil;
                                                                            }

                                                                            IokeObject code = IokeObject.As(args[argCount-1], context);
                                                                            var restarts = new SaneList<Runtime.RestartInfo>();
                                                                            var rescues = new SaneList<Runtime.RescueInfo>();
                                                                            var handlers = new SaneList<Runtime.HandlerInfo>();

                                                                            Runtime.BindIndex index = context.runtime.GetBindIndex();

                                                                            bool doUnregister = true;

                                                                            try {
                                                                                foreach(object o in ArrayList.Adapter(args).GetRange(0, argCount-1)) {
                                                                                    IokeObject msg = IokeObject.As(o, context);
                                                                                    IokeObject bindable = IokeObject.As(((Message)IokeObject.dataOf(msg)).EvaluateCompleteWithoutExplicitReceiver(msg, context, context.RealContext), context);
                                                                                    bool loop = false;
                                                                                    do {
                                                                                        loop = false;
                                                                                        if(IokeObject.IsKind(bindable, "Restart")) {
                                                                                            object ioName = ((Message)IokeObject.dataOf(runtime.nameMessage)).SendTo(runtime.nameMessage, context, bindable);
                                                                                            string name = null;
                                                                                            if(ioName != runtime.nil) {
                                                                                                name = Symbol.GetText(ioName);
                                                                                            }
                                                                                            restarts.Insert(0, new Runtime.RestartInfo(name, bindable, restarts, index, null));
                                                                                            index = index.NextCol();
                                                                                        } else if(IokeObject.IsKind(bindable, "Rescue")) {
                                                                                            object conditions = ((Message)IokeObject.dataOf(runtime.conditionsMessage)).SendTo(runtime.conditionsMessage, context, bindable);
                                                                                            var applicable = IokeList.GetList(conditions);
                                                                                            rescues.Insert(0, new Runtime.RescueInfo(bindable, applicable, rescues, index));
                                                                                            index = index.NextCol();
                                                                                        } else if(IokeObject.IsKind(bindable, "Handler")) {
                                                                                            object conditions = ((Message)IokeObject.dataOf(runtime.conditionsMessage)).SendTo(runtime.conditionsMessage, context, bindable);
                                                                                            var applicable = IokeList.GetList(conditions);
                                                                                            handlers.Insert(0, new Runtime.HandlerInfo(bindable, applicable, handlers, index));
                                                                                            index = index.NextCol();
                                                                                        } else {
                                                                                            IokeObject condition = IokeObject.As(IokeObject.GetCellChain(runtime.Condition, 
                                                                                                                                                         message, 
                                                                                                                                                         context, 
                                                                                                                                                         "Error", 
                                                                                                                                                         "Type",
                                                                                                                                                         "IncorrectType"), context).Mimic(message, context);
                                                                                            condition.SetCell("message", message);
                                                                                            condition.SetCell("context", context);
                                                                                            condition.SetCell("receiver", on);
                                                                                            condition.SetCell("expectedType", runtime.GetSymbol("Bindable"));
                        
                                                                                            object[] newCell = new object[]{bindable};
                        
                                                                                            runtime.WithRestartReturningArguments(() => { runtime.ErrorCondition(condition); }, context, new IokeObject.UseValue("bindable", newCell));
                                                                                            bindable = IokeObject.As(newCell[0], context);
                                                                                            loop = true;
                                                                                        }
                                                                                    } while(loop);
                                                                                    loop = false;
                                                                                }
                                                                                runtime.RegisterRestarts(restarts);
                                                                                runtime.RegisterRescues(rescues);
                                                                                runtime.RegisterHandlers(handlers);

                                                                                return ((Message)IokeObject.dataOf(code)).EvaluateCompleteWithoutExplicitReceiver(code, context, context.RealContext);
                                                                            } catch(ControlFlow.Restart e) {
                                                                                Runtime.RestartInfo ri = null;
                                                                                if((ri = e.GetRestart).token == restarts) {
                                                                                    runtime.UnregisterHandlers(handlers);
                                                                                    runtime.UnregisterRescues(rescues);
                                                                                    runtime.UnregisterRestarts(restarts); 
                                                                                    doUnregister = false;
                                                                                    return ((Message)IokeObject.dataOf(runtime.callMessage)).SendTo(runtime.callMessage, context, ((Message)IokeObject.dataOf(runtime.codeMessage)).SendTo(runtime.codeMessage, context, ri.restart), e.Arguments);
                                                                                } else {
                                                                                    throw e;
                                                                                } 
                                                                            } catch(ControlFlow.Rescue e) {
                                                                                Runtime.RescueInfo ri = null;
                                                                                if((ri = e.GetRescue).token == rescues) {
                                                                                    runtime.UnregisterHandlers(handlers);
                                                                                    runtime.UnregisterRescues(rescues);
                                                                                    runtime.UnregisterRestarts(restarts); 
                                                                                    doUnregister = false;
                                                                                    return ((Message)IokeObject.dataOf(runtime.callMessage)).SendTo(runtime.callMessage, context, ((Message)IokeObject.dataOf(runtime.handlerMessage)).SendTo(runtime.handlerMessage, context, ri.rescue), e.Condition);
                                                                                } else {
                                                                                    throw e;
                                                                                }
                                                                            } finally {
                                                                                if(doUnregister) {
                                                                                    runtime.UnregisterHandlers(handlers);
                                                                                    runtime.UnregisterRescues(rescues);
                                                                                    runtime.UnregisterRestarts(restarts); 
                                                                                }
                                                                            }
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("takes either a name (as a symbol) or a Restart instance. if the restart is active, will transfer control to it, supplying the rest of the given arguments to that restart.", 
                                                       new NativeMethod("invokeRestart", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("nameOrRestart")
                                                                        .WithRest("arguments")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            IList posArgs = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, posArgs, new SaneDictionary<string, object>());

                                                                            IokeObject restart = IokeObject.As(posArgs[0], context);
                                                                            Runtime.RestartInfo realRestart = null;
                                                                            var args = new SaneArrayList();
                                                                            if(restart.IsSymbol) {
                                                                                string name = Symbol.GetText(restart);
                                                                                realRestart = context.runtime.FindActiveRestart(name);
                                                                                if(null == realRestart) {
                                                                                    IokeObject condition = IokeObject.As(IokeObject.GetCellChain(runtime.Condition, 
                                                                                                                                                 message, 
                                                                                                                                                 context, 
                                                                                                                                                 "Error", 
                                                                                                                                                 "RestartNotActive"), context).Mimic(message, context);
                                                                                    condition.SetCell("message", message);
                                                                                    condition.SetCell("context", context);
                                                                                    condition.SetCell("receiver", on);
                                                                                    condition.SetCell("restart", restart);
                            
                                                                                    runtime.WithReturningRestart("ignoreMissingRestart", context, ()=>{runtime.ErrorCondition(condition);});
                                                                                    return runtime.nil;
                                                                                }
                                                                            } else {
                                                                                realRestart = context.runtime.FindActiveRestart(restart);
                                                                                if(null == realRestart) {
                                                                                    IokeObject condition = IokeObject.As(IokeObject.GetCellChain(runtime.Condition, 
                                                                                                                                                 message, 
                                                                                                                                                 context, 
                                                                                                                                                 "Error", 
                                                                                                                                                 "RestartNotActive"), context).Mimic(message, context);
                                                                                    condition.SetCell("message", message);
                                                                                    condition.SetCell("context", context);
                                                                                    condition.SetCell("receiver", on);
                                                                                    condition.SetCell("restart", restart);
                            
                                                                                    runtime.WithReturningRestart("ignoreMissingRestart", context, ()=>{runtime.ErrorCondition(condition);});
                                                                                    return runtime.nil;
                                                                                }
                                                                            }

                                                                            int argCount = posArgs.Count;
                                                                            for(int i = 1;i<argCount;i++) {
                                                                                args.Add(posArgs[i]);
                                                                            }

                                                                            throw new ControlFlow.Restart(realRestart, args);
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("takes either a name (as a symbol) or a Restart instance. if the restart is active, will return that restart, otherwise returns nil.", 
                                                       new NativeMethod("findRestart", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("nameOrRestart")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            IList args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());

                                                                            IokeObject restart = IokeObject.As(args[0], context);
                                                                            Runtime.RestartInfo realRestart = null;
                                                                            while(!(restart.IsSymbol || restart.GetKind(message, context).Equals("Restart"))) {
                                                                                IokeObject condition = IokeObject.As(IokeObject.GetCellChain(runtime.Condition, 
                                                                                                                                             message, 
                                                                                                                                             context, 
                                                                                                                                             "Error", 
                                                                                                                                             "Type",
                                                                                                                                             "IncorrectType"), context).Mimic(message, context);
                                                                                condition.SetCell("message", message);
                                                                                condition.SetCell("context", context);
                                                                                condition.SetCell("receiver", on);
                                                                                condition.SetCell("expectedType", runtime.GetSymbol("Restart"));
                        
                                                                                object[] newCell = new object[]{restart};
                        
                                                                                runtime.WithRestartReturningArguments(()=>{runtime.ErrorCondition(condition);}, context, new IokeObject.UseValue("restart", newCell));
                                                                                restart = IokeObject.As(newCell[0], context);
                                                                            }

                                                                            if(restart.IsSymbol) {
                                                                                string name = Symbol.GetText(restart);
                                                                                realRestart = runtime.FindActiveRestart(name);
                                                                            } else if(restart.GetKind(message, context).Equals("Restart")) {
                                                                                realRestart = runtime.FindActiveRestart(restart);
                                                                            }
                                                                            if(realRestart == null) {
                                                                                return runtime.nil;
                                                                            } else {
                                                                                return realRestart.restart;
                                                                            }
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("takes an optional condition to specify - returns all restarts that are applicable to that condition. closer restarts will be first in the list", 
                                                       new NativeMethod("availableRestarts", DefaultArgumentsDefinition.builder()
                                                                        .WithOptionalPositional("condition", "Condition")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            IList args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                            object toLookFor = runtime.Condition;
                                                                            if(args.Count > 0) {
                                                                                toLookFor = args[0];
                                                                            }

                                                                            var result = new SaneArrayList();
                                                                            var activeRestarts = runtime.ActiveRestarts;

                                                                            foreach(var lri in activeRestarts) {
                                                                                foreach(var rri in lri) {
                                                                                    if(IokeObject.IsObjectTrue(((Message)IokeObject.dataOf(runtime.callMessage)).SendTo(runtime.callMessage, context, ((Message)IokeObject.dataOf(runtime.testMessage)).SendTo(runtime.testMessage, context, rri.restart), toLookFor))) {
                                                                                        result.Add(rri.restart);
                                                                                    }
                                                                                }
                                                                            }

                                                                            return runtime.NewList(result);
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("takes one or more datums descibing the condition to signal. this datum can be either a mimic of a Condition, in which case it will be signalled directly, or it can be a mimic of a Condition with arguments, in which case it will first be mimicked and the arguments assigned in some way. finally, if the argument is a Text, a mimic of Condition Default will be signalled, with the provided text.", 
                                                       new NativeMethod("signal!", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("datum")
                                                                        .WithKeywordRest("conditionArguments")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            IList positionalArgs = new SaneArrayList();
                                                                            IDictionary<string, object> keywordArgs = new SaneDictionary<string, object>();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, positionalArgs, keywordArgs);
                                                                            object datum = positionalArgs[0];
                                                                            return Signal(datum, positionalArgs, keywordArgs, message, context);
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("takes the same kind of arguments as 'signal!', and will signal a condition. the default condition used is Condition Error Default. if no rescue or restart is invoked error! will report the condition to System err and exit the currently running Ioke VM. this might be a problem when exceptions happen inside of running Java code, as callbacks and so on.. if 'System currentDebugger' is non-nil, it will be invoked before the exiting of the VM. the exit can only be avoided by invoking a restart. that means that error! will never return. ", 
                                                       new NativeMethod("error!", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("datum")
                                                                        .WithKeywordRest("errorArguments")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            IList positionalArgs = new SaneArrayList();
                                                                            IDictionary<string, object> keywordArgs = new SaneDictionary<string, object>();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, positionalArgs, keywordArgs);

                                                                            object datum = positionalArgs[0];

                                                                            if(IokeObject.dataOf(datum) is Text) {
                                                                                object oldDatum = datum;
                                                                                datum = IokeObject.As(IokeObject.GetCellChain(runtime.Condition, message, context, "Error", "Default"), context).Mimic(message, context);
                                                                                IokeObject.SetCell(datum, message, context, "text", oldDatum);
                                                                            }

                                                                            IokeObject condition = Signal(datum, positionalArgs, keywordArgs, message, context);
                                                                            IokeObject err = IokeObject.As(context.runtime.System.GetCell(message, context, "err"), context);
                    
                                                                            ((Message)IokeObject.dataOf(context.runtime.printMessage)).SendTo(context.runtime.printMessage, context, err, context.runtime.NewText("*** - "));
                                                                            ((Message)IokeObject.dataOf(context.runtime.printlnMessage)).SendTo(context.runtime.printlnMessage, context, err, ((Message)IokeObject.dataOf(context.runtime.reportMessage)).SendTo(context.runtime.reportMessage, context, condition));
                    
                                                                            IokeObject currentDebugger = IokeObject.As(((Message)IokeObject.dataOf(context.runtime.currentDebuggerMessage)).SendTo(context.runtime.currentDebuggerMessage, context, context.runtime.System), context);

                                                                            if(!currentDebugger.IsNil) {
                                                                                ((Message)IokeObject.dataOf(context.runtime.invokeMessage)).SendTo(context.runtime.invokeMessage, context, currentDebugger, condition, context);
                                                                            }

                                                                            throw new ControlFlow.Exit(condition);
                                                                        })));
        }
    }
}
