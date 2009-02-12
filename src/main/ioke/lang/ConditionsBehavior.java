/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.Arrays;
import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.HashSet;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class ConditionsBehavior {
    public static IokeObject signal(Object datum, List<Object> positionalArgs, Map<String, Object> keywordArgs, IokeObject message, IokeObject context) throws ControlFlow {
        IokeObject newCondition = null;
        if(Text.isText(datum)) {
            newCondition = IokeObject.as(context.runtime.condition.getCell(message, context, "Default"), context).mimic(message, context);
            newCondition.setCell("context", context);
            newCondition.setCell("text", datum);
        } else {
            if(keywordArgs.size() == 0) {
                newCondition = IokeObject.as(datum, context);
            } else {
                newCondition = IokeObject.as(datum, context).mimic(message, context);
                newCondition.setCell("context", context);
                for(Map.Entry<String,Object> val : keywordArgs.entrySet()) {
                    String s = val.getKey();
                    newCondition.setCell(s.substring(0, s.length()-1), val.getValue());
                }
            }
        }

        Runtime.RescueInfo rescue = context.runtime.findActiveRescueFor(newCondition);

        List<Runtime.HandlerInfo> handlers = context.runtime.findActiveHandlersFor(newCondition, (rescue == null) ? new Runtime.BindIndex(-1,-1) : rescue.index);
        
        for(Runtime.HandlerInfo rhi : handlers) {
            context.runtime.callMessage.sendTo(context, context.runtime.handlerMessage.sendTo(context, rhi.handler), newCondition);
        }

        if(rescue != null) {
            throw new ControlFlow.Rescue(rescue, newCondition);
        }
                    
        return newCondition;
    }

    public static void init(IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;
        obj.setKind("DefaultBehavior Conditions");

        obj.registerMethod(runtime.newJavaMethod("takes one optional unevaluated parameter (this should be the first if provided), that is the name of the restart to create. this will default to nil. takes two keyword arguments, report: and test:. These should both be lexical blocks. if not provided, there will be reasonable defaults. the only required argument is something that evaluates into a lexical block. this block is what will be executed when the restart is invoked. will return a Restart mimic.", new JavaMethod("restart") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withOptionalPositionalUnevaluated("name")
                    .withKeyword("report")
                    .withKeyword("test")
                    .withRequiredPositional("action")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    String name = null;
                    IokeObject report = null;
                    IokeObject test = null;
                    IokeObject code = null;
                    final Runtime runtime = context.runtime;
                    
                    List<Object> args = message.getArguments();
                    int argCount = args.size();
                    if(argCount > 4) {
                        final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition, 
                                                                                     message, 
                                                                                     context, 
                                                                                     "Error", 
                                                                                     "Invocation", 
                                                                                     "TooManyArguments"), context).mimic(message, context);
                        condition.setCell("message", message);
                        condition.setCell("context", context);
                        condition.setCell("receiver", on);
                        condition.setCell("extra", runtime.newList(args.subList(4, argCount)));
                        runtime.withReturningRestart("ignoreExtraArguments", context, new RunnableWithControlFlow() {
                                public void run() throws ControlFlow {
                                    runtime.errorCondition(condition);
                                }});
                        argCount = 4;
                    } else if(argCount < 1) {
                        final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition, 
                                                                                           message, 
                                                                                           context, 
                                                                                           "Error", 
                                                                                           "Invocation", 
                                                                                           "TooFewArguments"), context).mimic(message, context);
                        condition.setCell("message", message);
                        condition.setCell("context", context);
                        condition.setCell("receiver", on);
                        condition.setCell("missing", runtime.newNumber(1-argCount));
                
                        runtime.errorCondition(condition);
                    }

                    for(int i=0; i<argCount; i++) {
                        Object o = args.get(i);
                        Message m = (Message)IokeObject.data(o);
                        if(m.isKeyword()) {
                            String n = m.getName(null);
                            if(n.equals("report:")) {
                                report = IokeObject.as(m.next.evaluateCompleteWithoutExplicitReceiver(context, context.getRealContext()), context);
                            } else if(n.equals("test:")) {
                                test = IokeObject.as(m.next.evaluateCompleteWithoutExplicitReceiver(context, context.getRealContext()), context);
                            } else {
                                final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition, 
                                                                                                   message, 
                                                                                                   context, 
                                                                                                   "Error", 
                                                                                                   "Invocation", 
                                                                                                   "MismatchedKeywords"), context).mimic(message, context);
                                condition.setCell("message", message);
                                condition.setCell("context", context);
                                condition.setCell("receiver", on);
                                condition.setCell("expected", runtime.newList(new ArrayList<Object>(Arrays.<Object>asList(runtime.newText("report:"), runtime.newText("test:")))));
                                List<Object> extra = new ArrayList<Object>();
                                extra.add(runtime.newText(n));
                                condition.setCell("extra", runtime.newList(extra));
                                
                                runtime.withReturningRestart("ignoreExtraKeywords", context, new RunnableWithControlFlow() {
                                        public void run() throws ControlFlow {
                                            runtime.errorCondition(condition);
                                        }});
                            }
                        } else {
                            if(code != null) {
                                name = code.getName();
                                code = IokeObject.as(o, context);
                            } else {
                                code = IokeObject.as(o, context);
                            }
                        }
                    }

                    code = IokeObject.as(code.evaluateCompleteWithoutExplicitReceiver(context, context.getRealContext()), context);
                    Object restart = runtime.mimic.sendTo(context, runtime.restart);
                    
                    IokeObject.setCell(restart, "code", code, context);

                    if(null != name) {
                        IokeObject.setCell(restart, "name", runtime.getSymbol(name), context);
                    }

                    if(null != test) {
                        IokeObject.setCell(restart, "test", test, context);
                    }

                    if(null != report) {
                        IokeObject.setCell(restart, "report", report, context);
                    }

                    return restart;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("takes zero or more arguments that should evaluate to a condition mimic - this list will match all the conditions this Rescue should be able to catch. the last argument is not optional, and should be something activatable that takes one argument - the condition instance. will return a Rescue mimic.", new JavaMethod("rescue") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRest("conditionsAndAction")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);
                    int count = message.getArgumentCount();
                    List<Object> conds = new ArrayList<Object>();
                    for(int i=0, j=count-1; i<j; i++) {
                        conds.add(message.getEvaluatedArgument(i, context));
                    }

                    if(conds.isEmpty()) {
                        conds.add(context.runtime.condition);
                    }

                    Object handler = message.getEvaluatedArgument(count-1, context);
                    Object rescue = context.runtime.mimic.sendTo(context, context.runtime.rescue);
                    
                    IokeObject.setCell(rescue, "handler", handler, context);
                    IokeObject.setCell(rescue, "conditions", context.runtime.newList(conds), context);

                    return rescue;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("takes zero or more arguments that should evaluate to a condition mimic - this list will match all the conditions this Handler should be able to catch. the last argument is not optional, and should be something activatable that takes one argument - the condition instance. will return a Handler mimic.", new JavaMethod("handle") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRest("conditionsAndAction")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    int count = message.getArgumentCount();
                    List<Object> conds = new ArrayList<Object>();
                    for(int i=0, j=count-1; i<j; i++) {
                        conds.add(message.getEvaluatedArgument(i, context));
                    }

                    if(conds.isEmpty()) {
                        conds.add(context.runtime.condition);
                    }

                    Object code = message.getEvaluatedArgument(count-1, context);
                    Object handle = context.runtime.mimic.sendTo(context, context.runtime.handler);
                    
                    IokeObject.setCell(handle, "handler", code, context);
                    IokeObject.setCell(handle, "conditions", context.runtime.newList(conds), context);

                    return handle;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("will evaluate all arguments, and expects all except for the last to be a Restart. bind will associate these restarts for the duration of the execution of the last argument and then unbind them again. it will return the result of the last argument, or if a restart is executed it will instead return the result of that invocation.", new JavaMethod("bind") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRestUnevaluated("bindablesAndCode")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, final IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    final Runtime runtime = context.runtime;
                    List<Object> args = message.getArguments();
                    int argCount = args.size();
                    if(argCount == 0) {
                        return context.runtime.nil;
                    }

                    IokeObject code = IokeObject.as(args.get(argCount-1), context);
                    List<Runtime.RestartInfo> restarts = new ArrayList<Runtime.RestartInfo>();
                    List<Runtime.RescueInfo> rescues = new ArrayList<Runtime.RescueInfo>();
                    List<Runtime.HandlerInfo> handlers = new ArrayList<Runtime.HandlerInfo>();

                    Runtime.BindIndex index = context.runtime.getBindIndex();

                    boolean doUnregister = true;

                    try {
                        for(Object o : args.subList(0, argCount-1)) {
                            IokeObject bindable = IokeObject.as(IokeObject.as(o, context).evaluateCompleteWithoutExplicitReceiver(context, context.getRealContext()), context);
                            boolean loop = false;
                            do {
                                loop = false;
                                if(IokeObject.isKind(bindable, "Restart")) {
                                    Object ioName = runtime.name.sendTo(context, bindable);
                                    String name = null;
                                    if(ioName != runtime.nil) {
                                        name = Symbol.getText(ioName);
                                    }
                            
                                    restarts.add(0, new Runtime.RestartInfo(name, bindable, restarts, index, null));
                                    index = index.nextCol();
                                } else if(IokeObject.isKind(bindable, "Rescue")) {
                                    Object conditions = runtime.conditionsMessage.sendTo(context, bindable);
                                    List<Object> applicable = IokeList.getList(conditions);
                                    rescues.add(0, new Runtime.RescueInfo(bindable, applicable, rescues, index));
                                    index = index.nextCol();
                                } else if(IokeObject.isKind(bindable, "Handler")) {
                                    Object conditions = runtime.conditionsMessage.sendTo(context, bindable);
                                    List<Object> applicable = IokeList.getList(conditions);
                                    handlers.add(0, new Runtime.HandlerInfo(bindable, applicable, handlers, index));
                                    index = index.nextCol();
                                } else {
                                    final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition, 
                                                                                                       message, 
                                                                                                       context, 
                                                                                                       "Error", 
                                                                                                       "Type",
                                                                                                       "IncorrectType"), context).mimic(message, context);
                                    condition.setCell("message", message);
                                    condition.setCell("context", context);
                                    condition.setCell("receiver", on);
                                    condition.setCell("expectedType", runtime.getSymbol("Bindable"));
                        
                                    final Object[] newCell = new Object[]{bindable};
                        
                                    runtime.withRestartReturningArguments(new RunnableWithControlFlow() {
                                            public void run() throws ControlFlow {
                                                runtime.errorCondition(condition);
                                            }}, 
                                        context,
                                        new Restart.ArgumentGivingRestart("useValue") { 
                                            public List<String> getArgumentNames() {
                                                return new ArrayList<String>(Arrays.asList("newValue"));
                                            }
                                    
                                            public IokeObject invoke(IokeObject context, List<Object> arguments) throws ControlFlow {
                                                newCell[0] = arguments.get(0);
                                                return runtime.nil;
                                            }
                                        }
                                        );
                                    bindable = IokeObject.as(newCell[0], context);
                                    loop = true;
                                }
                            } while(loop);
                            loop = false;
                        }
                        runtime.registerRestarts(restarts);
                        runtime.registerRescues(rescues);
                        runtime.registerHandlers(handlers);

                        return code.evaluateCompleteWithoutExplicitReceiver(context, context.getRealContext());
                    } catch(ControlFlow.Restart e) {
                        Runtime.RestartInfo ri = null;
                        if((ri = e.getRestart()).token == restarts) {
                            runtime.unregisterHandlers(handlers);
                            runtime.unregisterRescues(rescues);
                            runtime.unregisterRestarts(restarts); 
                            doUnregister = false;
                            return runtime.callMessage.sendTo(context, runtime.code.sendTo(context, ri.restart), e.getArguments());
                        } else {
                            throw e;
                        } 
                    } catch(ControlFlow.Rescue e) {
                        Runtime.RescueInfo ri = null;
                        if((ri = e.getRescue()).token == rescues) {
                            runtime.unregisterHandlers(handlers);
                            runtime.unregisterRescues(rescues);
                            runtime.unregisterRestarts(restarts); 
                            doUnregister = false;
                            return runtime.callMessage.sendTo(context, runtime.handlerMessage.sendTo(context, ri.rescue), e.getCondition());
                        } else {
                            throw e;
                        }
                   } finally {
                        if(doUnregister) {
                            runtime.unregisterHandlers(handlers);
                            runtime.unregisterRescues(rescues);
                            runtime.unregisterRestarts(restarts); 
                        }
                   }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("takes either a name (as a symbol) or a Restart instance. if the restart is active, will transfer control to it, supplying the rest of the given arguments to that restart.", new JavaMethod("invokeRestart") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("nameOrRestart")
                    .withRest("arguments")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> posArgs = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, posArgs, new HashMap<String, Object>());

                    final Runtime runtime = context.runtime;

                    IokeObject restart = IokeObject.as(posArgs.get(0), context);
                    Runtime.RestartInfo realRestart = null;
                    List<Object> args = new ArrayList<Object>();
                    if(restart.isSymbol()) {
                        String name = Symbol.getText(restart);
                        realRestart = context.runtime.findActiveRestart(name);
                        if(null == realRestart) {
                            final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition, 
                                                                                               message, 
                                                                                               context, 
                                                                                               "Error", 
                                                                                               "RestartNotActive"), context).mimic(message, context);
                            condition.setCell("message", message);
                            condition.setCell("context", context);
                            condition.setCell("receiver", on);
                            condition.setCell("restart", restart);
                            
                            runtime.withReturningRestart("ignoreMissingRestart", context, new RunnableWithControlFlow() {
                                    public void run() throws ControlFlow {
                                        runtime.errorCondition(condition);
                                    }});
                            return runtime.nil;
                        }
                    } else {
                        realRestart = context.runtime.findActiveRestart(restart);
                        if(null == realRestart) {
                            final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition, 
                                                                                               message, 
                                                                                               context, 
                                                                                               "Error", 
                                                                                               "RestartNotActive"), context).mimic(message, context);
                            condition.setCell("message", message);
                            condition.setCell("context", context);
                            condition.setCell("receiver", on);
                            condition.setCell("restart", restart);
                            
                            runtime.withReturningRestart("ignoreMissingRestart", context, new RunnableWithControlFlow() {
                                    public void run() throws ControlFlow {
                                        runtime.errorCondition(condition);
                                    }});
                            return runtime.nil;
                        }
                    }

                    int argCount = posArgs.size();
                    for(int i = 1;i<argCount;i++) {
                        args.add(posArgs.get(i));
                    }

                    throw new ControlFlow.Restart(realRestart, args);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("takes either a name (as a symbol) or a Restart instance. if the restart is active, will return that restart, otherwise returns nil.", new JavaMethod("findRestart") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("nameOrRestart")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, final IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    final Runtime runtime = context.runtime;
                    IokeObject restart = IokeObject.as(args.get(0), context);
                    Runtime.RestartInfo realRestart = null;
                    while(!(restart.isSymbol() || restart.getKind(message, context).equals("Restart"))) {
                        final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition, 
                                                                                           message, 
                                                                                           context, 
                                                                                           "Error", 
                                                                                           "Type",
                                                                                           "IncorrectType"), context).mimic(message, context);
                        condition.setCell("message", message);
                        condition.setCell("context", context);
                        condition.setCell("receiver", on);
                        condition.setCell("expectedType", runtime.getSymbol("Restart"));
                        
                        final Object[] newCell = new Object[]{restart};
                        
                        runtime.withRestartReturningArguments(new RunnableWithControlFlow() {
                                public void run() throws ControlFlow {
                                    runtime.errorCondition(condition);
                                }}, 
                            context,
                            new Restart.ArgumentGivingRestart("useValue") { 
                                public List<String> getArgumentNames() {
                                    return new ArrayList<String>(Arrays.asList("newValue"));
                                }
                                    
                                public IokeObject invoke(IokeObject context, List<Object> arguments) throws ControlFlow {
                                    newCell[0] = arguments.get(0);
                                    return runtime.nil;
                                }
                            }
                            );
                        restart = IokeObject.as(newCell[0], context);
                    }

                    if(restart.isSymbol()) {
                        String name = Symbol.getText(restart);
                        realRestart = runtime.findActiveRestart(name);
                    } else if(restart.getKind(message, context).equals("Restart")) {
                        realRestart = runtime.findActiveRestart(restart);
                    }
                    if(realRestart == null) {
                        return runtime.nil;
                    } else {
                        return realRestart.restart;
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("takes an optional condition to specify - returns all restarts that are applicable to that condition. closer restarts will be first in the list", new JavaMethod("availableRestarts") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withOptionalPositional("condition", "Condition")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, final IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());
                    final Runtime runtime = context.runtime;

                    Object toLookFor = runtime.condition;
                    if(args.size() > 0) {
                        toLookFor = args.get(0);
                    }

                    List<Object> result = new ArrayList<Object>();
                    List<List<Runtime.RestartInfo>> activeRestarts = runtime.getActiveRestarts();

                    for(List<Runtime.RestartInfo> lri : activeRestarts) {
                        for(Runtime.RestartInfo rri : lri) {
                            if(IokeObject.isTrue(runtime.callMessage.sendTo(context, runtime.testMessage.sendTo(context, rri.restart), toLookFor))) {
                                result.add(rri.restart);
                            }
                        }
                    }

                    return runtime.newList(result);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("takes one or more datums descibing the condition to signal. this datum can be either a mimic of a Condition, in which case it will be signalled directly, or it can be a mimic of a Condition with arguments, in which case it will first be mimicked and the arguments assigned in some way. finally, if the argument is a Text, a mimic of Condition Default will be signalled, with the provided text.", new JavaMethod("signal!") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("datum")
                    .withKeywordRest("conditionArguments")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> positionalArgs = new ArrayList<Object>();
                    Map<String, Object> keywordArgs = new HashMap<String, Object>();
                    getArguments().getEvaluatedArguments(context, message, on, positionalArgs, keywordArgs);

                    Object datum = positionalArgs.get(0);
                    
                    return signal(datum, positionalArgs, keywordArgs, message, context);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("takes the same kind of arguments as 'signal!', and will signal a condition. the default condition used is Condition Error Default. if no rescue or restart is invoked error! will report the condition to System err and exit the currently running Ioke VM. this might be a problem when exceptions happen inside of running Java code, as callbacks and so on.. if 'System currentDebugger' is non-nil, it will be invoked before the exiting of the VM. the exit can only be avoided by invoking a restart. that means that error! will never return. ", new JavaMethod("error!") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("datum")
                    .withKeywordRest("errorArguments")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> positionalArgs = new ArrayList<Object>();
                    Map<String, Object> keywordArgs = new HashMap<String, Object>();
                    getArguments().getEvaluatedArguments(context, message, on, positionalArgs, keywordArgs);

                    Object datum = positionalArgs.get(0);

                    if(IokeObject.data(datum) instanceof Text) {
                        Object oldDatum = datum;
                        datum = IokeObject.as(IokeObject.as(context.runtime.condition.getCell(message, context, "Error"), context).getCell(message, context, "Default"), context).mimic(message, context);
                        IokeObject.setCell(datum, message, context, "text", oldDatum);
                    }

                    IokeObject condition = signal(datum, positionalArgs, keywordArgs, message, context);
                    IokeObject err = IokeObject.as(context.runtime.system.getCell(message, context, "err"), context);
                    
                    context.runtime.printMessage.sendTo(context, err, context.runtime.newText("*** - "));
                    context.runtime.printlnMessage.sendTo(context, err, context.runtime.reportMessage.sendTo(context, condition));
                    
                    IokeObject currentDebugger = IokeObject.as(context.runtime.currentDebuggerMessage.sendTo(context, context.runtime.system), context);

                    if(!currentDebugger.isNil()) {
                        context.runtime.invokeMessage.sendTo(context, currentDebugger, condition, context);
                    }

                    throw new ControlFlow.Exit(condition);
                }
            }));
    }
}
