/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.Arrays;
import java.util.ArrayList;
import java.util.List;
import java.util.HashSet;

import ioke.lang.exceptions.ControlFlow;
import ioke.lang.exceptions.MismatchedArgumentCount;
import ioke.lang.exceptions.MismatchedKeywords;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class DefaultBehavior {
    public abstract static class DefaultBehaviorJavaMethod extends JavaMethod {
        public DefaultBehaviorJavaMethod(String name) {
            super(name);
        }

        @Override
        public String inspectName() {
            return "DefaultBehavior_" + this.getName();
        }
    }

    public static void init(IokeObject obj) {
        final Runtime runtime = obj.runtime;
        obj.setKind("DefaultBehavior");

        obj.registerMethod(runtime.newJavaMethod("returns result of evaluating first argument", new DefaultBehaviorJavaMethod("") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    return message.getEvaluatedArgument(0, context);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns true if this object is nil, false otherwise.", new DefaultBehaviorJavaMethod("nil?") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    return IokeObject.as(on).isNil() ? method.runtime._true : method.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns true if this object is not true, false otherwise.", new DefaultBehaviorJavaMethod("false?") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    return IokeObject.isTrue(on) ? method.runtime._false : method.runtime._true;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns true if this object is true, false otherwise.", new DefaultBehaviorJavaMethod("true?") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    return IokeObject.isTrue(on) ? method.runtime._true : method.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("calls mimic.", new DefaultBehaviorJavaMethod("derive") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    return IokeObject.activate(runtime.base.getCell(message, context, "mimic"), context, message, on);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("executes the argument with the receiver as context and ground, and then returns the receiver.", new DefaultBehaviorJavaMethod("do") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    IokeObject code = IokeObject.as(message.getArguments().get(0));
                    code.evaluateCompleteWith(IokeObject.as(on), IokeObject.as(on));
                    return on;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("breaks out of the enclosing context. if an argument is supplied, this will be returned as the result of the object breaking out of", new DefaultBehaviorJavaMethod("break") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object value = runtime.nil;
                    if(message.getArgumentCount() > 0) {
                        value = message.getEvaluatedArgument(0, context);
                    }
                    throw new ControlFlow.Break(value);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("until the first argument evaluates to something true, loops and evaluates the next argument", new DefaultBehaviorJavaMethod("until") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    if(message.getArgumentCount() == 0) {
                        return runtime.nil;
                    }

                    boolean body = message.getArgumentCount() > 1;
                    Object ret = runtime.nil;

                    try {
                        while(!IokeObject.isTrue(message.getEvaluatedArgument(0, context))) {
                            if(body) {
                                ret = message.getEvaluatedArgument(1, context);
                            }
                        }
                    } catch(ControlFlow.Break e) {
                        ret = e.getValue();
                    }
                    return ret;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("while the first argument evaluates to something true, loops and evaluates the next argument", new DefaultBehaviorJavaMethod("while") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    if(message.getArgumentCount() == 0) {
                        return runtime.nil;
                    }

                    boolean body = message.getArgumentCount() > 1;
                    Object ret = runtime.nil;

                    try {
                        while(IokeObject.isTrue(message.getEvaluatedArgument(0, context))) {
                            if(body) {
                                ret = message.getEvaluatedArgument(1, context);
                            }
                        }
                    } catch(ControlFlow.Break e) {
                        ret = e.getValue();
                    }
                    return ret;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("loops forever - executing it's argument over and over until interrupted in some way.", new DefaultBehaviorJavaMethod("loop") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    if(message.getArgumentCount() > 0) {
                        try {
                            while(true) {
                                message.getEvaluatedArgument(0, context);
                            }
                        } catch(ControlFlow.Break e) {
                            return e.getValue();
                        }
                    } else {
                        while(true){}
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("evaluates the first arguments, and then evaluates the second argument if the result was true, otherwise the last argument. returns the result of the call, or the result if it's not true.", new DefaultBehaviorJavaMethod("if") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object test = message.getEvaluatedArgument(0, context);
                    if(IokeObject.isTrue(test)) {
                        if(message.getArgumentCount() > 1) {
                            return message.getEvaluatedArgument(1, context);
                        } else {
                            return test;
                        }
                    } else {
                        if(message.getArgumentCount() > 2) {
                            return message.getEvaluatedArgument(2, context);
                        } else {
                            return test;
                        }
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects one 'strange' argument. creates a new instance of Text with the given Java String backing it.", new DefaultBehaviorJavaMethod("internal:createText") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object o = Message.getArg1(message);
                    if(o instanceof String) {
                        String s = (String)o;
                        return runtime.newText(s.substring(1, s.length()-1));
                    } else {
                        return IokeObject.convertToText(message.getEvaluatedArgument(0, context), message, context);
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects one 'strange' argument. creates a new instance of Number that represents the number found in the strange argument.", new DefaultBehaviorJavaMethod("internal:createNumber") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    String s = (String)Message.getArg1(message);
                    return runtime.newNumber(s);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects one argument, which is the unevaluated name of the cell to work on. will retrieve the current value of this cell, call 'succ' to that value and then send = to the current receiver with the name and the resulting value.", new DefaultBehaviorJavaMethod("++") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    IokeObject nameMessage = (IokeObject)Message.getArg1(message);
                    String name = nameMessage.getName();
                    Object current = IokeObject.getCell(on, message, context, name);
                    Object value = runtime.succ.sendTo(context, current);
                    return runtime.setValue.sendTo(context, on, nameMessage, value);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects one argument, which is the unevaluated name of the cell to work on. will retrieve the current value of this cell, call 'pred' to that value and then send = to the current receiver with the name and the resulting value.", new DefaultBehaviorJavaMethod("--") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    IokeObject nameMessage = (IokeObject)Message.getArg1(message);
                    String name = nameMessage.getName();
                    Object current = IokeObject.getCell(on, message, context, name);
                    Object value = runtime.pred.sendTo(context, current);
                    return runtime.setValue.sendTo(context, on, nameMessage, value);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects two arguments, the first unevaluated, the second evaluated. assigns the result of evaluating the second argument in the context of the caller, and assigns this result to the name provided by the first argument. the first argument remains unevaluated. the result of the assignment is the value assigned to the name. if the second argument is a method-like object and it's name is not set, that name will be set to the name of the cell.", new DefaultBehaviorJavaMethod("=") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    String name = ((IokeObject)Message.getArg1(message)).getName();
                    Object value = message.getEvaluatedArgument(1, context);
                    IokeObject.assign(on, name, value);

                    if((IokeObject.data(value) instanceof Method) && ((Method)IokeObject.data(value)).name == null) {
                        ((Method)IokeObject.data(value)).name = name;
                    } else if(name.length() > 0 && Character.isUpperCase(name.charAt(0)) && !IokeObject.as(value).hasKind()) {
                        if(on == context.runtime.ground) {
                            IokeObject.as(value).setKind(name);
                        } else {
                            IokeObject.as(value).setKind(IokeObject.as(on).getKind() + " " + name);
                        }
                    }
                    
                    return value;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns a textual representation of the object called on.", new DefaultBehaviorJavaMethod("asText") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    return runtime.newText(on.toString());
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns a more detailed textual representation of the object called on, than asText.", new DefaultBehaviorJavaMethod("representation") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    return runtime.newText(IokeObject.as(on).representation());
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns the documentation text of the object called on. anything can have a documentation text and an object inherits it's documentation string text the object it mimcs - at mimic time.", new DefaultBehaviorJavaMethod("documentation") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    return runtime.newText(IokeObject.as(on).documentation);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects one evaluated text argument and returns the cell that matches that name, without activating even if it's activatable.", new DefaultBehaviorJavaMethod("cell") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    String name = Text.getText(runtime.asText.sendTo(context, IokeObject.as(message.getArguments().get(0)).evaluateCompleteWith(context, context.getRealContext())));
                    return IokeObject.getCell(on, message, context, name);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects any number of unevaluated arguments. if no arguments at all are given, will just return nil. creates a new method based on the arguments. this method will be evaluated using the context of the object it's called on, and thus the definition can not refer to the outside scope where the method is defined. (there are other ways of achieving this). all arguments except the last one is expected to be names of arguments that will be used in the method. there will possible be additions to the format of arguments later on - including named parameters and optional arguments. the actual code is the last argument given.", new DefaultBehaviorJavaMethod("method") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    List<Object> args = message.getArguments();

                    if(args.size() == 0) {
                        return runtime.newJavaMethod("returns nil", new DefaultBehaviorJavaMethod("nil") {
                                @Override
                                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                                    return runtime.nil;
                                }});
                    }

                    String doc = null;

                    List<String> argNames = new ArrayList<String>(args.size()-1);
                    int start = 0;
                    if(args.size() > 0 && ((IokeObject)Message.getArg1(message)).getName().equals("internal:createText")) {
                        start++;
                        String s = ((String)((IokeObject)args.get(0)).getArguments().get(0));
                        doc = s.substring(1, s.length()-1);
                    }

                    DefaultArgumentsDefinition def = DefaultArgumentsDefinition.createFrom(args, start, args.size()-1, message, on, context);

                    return runtime.newMethod(doc, runtime.defaultMethod, new DefaultMethod(context, def, (IokeObject)args.get(args.size()-1)));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("creates a new lexical block that can be executed at will, while retaining a reference to the lexical closure it was created in. it will always update variables if they exist. there is currently no way of introducing shadowing variables in the local context. new variables can be created though, just like in a method. a lexical block mimics LexicalBlock, and can take arguments. at the moment these are restricted to required arguments, but support for the same argument types as DefaultMethod will come.", new DefaultBehaviorJavaMethod("fn") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    List<Object> args = message.getArguments();
                    if(args.isEmpty()) {
                        return runtime.newLexicalBlock(runtime.lexicalBlock, new LexicalBlock(context, DefaultArgumentsDefinition.empty(), method.runtime.nilMessage));
                    }

                    IokeObject code = IokeObject.as(args.get(args.size()-1));

                    DefaultArgumentsDefinition def = DefaultArgumentsDefinition.createFrom(args, 0, args.size()-1, message, on, context);
                    return runtime.newLexicalBlock(runtime.lexicalBlock, new LexicalBlock(context, def, code));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("does the same things as fn, but returns something that is activatable.", new DefaultBehaviorJavaMethod("fnx") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    List<Object> args = message.getArguments();
                    if(args.isEmpty()) {
                        IokeObject result = runtime.newLexicalBlock(runtime.lexicalBlock, new LexicalBlock(context, DefaultArgumentsDefinition.empty(), method.runtime.nilMessage));
                        result.setCell("activatable", runtime._true);
                        return result;
                    }

                    IokeObject code = IokeObject.as(args.get(args.size()-1));

                    DefaultArgumentsDefinition def = DefaultArgumentsDefinition.createFrom(args, 0, args.size()-1, message, on, context);
                    IokeObject result = runtime.newLexicalBlock(runtime.lexicalBlock, new LexicalBlock(context, def, code));
                    result.setCell("activatable", runtime._true);
                    return result;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("takes one or more evaluated string argument. will import the files corresponding to each of the strings named based on the Ioke loading behavior that can be found in the documentation for the loadBehavior cell on System.", new DefaultBehaviorJavaMethod("use") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    if(message.getArgumentCount() > 0) {
                        String name = Text.getText(runtime.asText.sendTo(context, message.getEvaluatedArgument(0, context)));
                        if(((IokeSystem)runtime.system.data).use(context, message, name)) {
                            return runtime._true;
                        } else {
                            return runtime._false;
                        }
                    }
                    
                    return runtime.nil;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("takes one optional unevaluated parameter (this should be the first if provided), that is the name of the restart to create. this will default to nil. takes two keyword arguments, report: and test:. These should both be lexical blocks. if not provided, there will be reasonable defaults. the only required argument is something that evaluates into a lexical block. this block is what will be executed when the restart is invoked. will return a Restart mimic.", new DefaultBehaviorJavaMethod("restart") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    String name = null;
                    IokeObject report = null;
                    IokeObject test = null;
                    IokeObject code = null;
                    
                    List<Object> args = message.getArguments();

                    if(args.size() > 4 || args.size() < 1) {
                        throw new MismatchedArgumentCount(message, "1..4", args.size(), on, context);
                    }

                    for(Object o : args) {
                        Message m = (Message)IokeObject.data(o);
                        if(m.isKeyword()) {
                            String n = m.getName(null);
                            if(n.equals("report:")) {
                                report = IokeObject.as(m.next.evaluateCompleteWithoutExplicitReceiver(context, context.getRealContext()));
                            } else if(n.equals("test:")) {
                                test = IokeObject.as(m.next.evaluateCompleteWithoutExplicitReceiver(context, context.getRealContext()));
                            } else {
                                throw new MismatchedKeywords(message, new HashSet<String>(Arrays.asList("report:", "test:")), new HashSet<String>(Arrays.asList(n)), on, context);
                            }
                        } else {
                            if(code != null) {
                                name = code.getName();
                                code = IokeObject.as(o);
                            } else {
                                code = IokeObject.as(o);
                            }
                        }
                    }

                    code = IokeObject.as(code.evaluateCompleteWithoutExplicitReceiver(context, context.getRealContext()));
                    Object restart = runtime.mimic.sendTo(context, runtime.restart);
                    
                    IokeObject.setCell(restart, "code", code);

                    if(null != name) {
                        IokeObject.setCell(restart, "name", runtime.getSymbol(name));
                    }

                    if(null != test) {
                        IokeObject.setCell(restart, "test", test);
                    }

                    if(null != report) {
                        IokeObject.setCell(restart, "report", report);
                    }

                    return restart;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("will evaluate all arguments, and expects all except for the last to be a Restart. bind will associate these restarts for the duration of the execution of the last argument and then unbind them again. it will return the result of the last argument, or if a restart is executed it will instead return the result of that invocation.", new DefaultBehaviorJavaMethod("bind") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = message.getArguments();
                    int argCount = args.size();
                    if(argCount == 0) {
                        return context.runtime.nil;
                    }

                    IokeObject code = IokeObject.as(args.get(argCount-1));
                    List<Runtime.RestartInfo> restarts = new ArrayList<Runtime.RestartInfo>();

                    try {
                        for(Object o : args.subList(0, argCount-1)) {
                            IokeObject restart = IokeObject.as(IokeObject.as(o).evaluateCompleteWithoutExplicitReceiver(context, context.getRealContext()));
                            if(!restart.getKind().equals("Restart")) {
                                throw new RuntimeException("argument " + o + " did not evaluate to a Restart");
                            }
                            Object ioName = runtime.name.sendTo(context, restart);
                            String name = null;
                            if(ioName != runtime.nil) {
                                name = Symbol.getText(ioName);
                            }
                            
                            restarts.add(new Runtime.RestartInfo(name, restart, restarts));
                        }
                        runtime.registerRestarts(restarts);

                        return code.evaluateCompleteWithoutExplicitReceiver(context, context.getRealContext());
                    } catch(ControlFlow.Restart e) {
                        Runtime.RestartInfo ri = null;
                        if((ri = e.getRestart()).token == restarts) {
                            // Might need to unregister restarts before doing this...
                            return runtime.call.sendTo(context, runtime.code.sendTo(context, ri.restart), e.getArguments());
                        } else {
                            throw e;
                        }
                    } finally {
                        runtime.unregisterRestarts(restarts);
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("takes either a name (as a symbol) or a Restart instance. if the restart is active, will transfer control to it, supplying the rest of the given arguments to that restart.", new DefaultBehaviorJavaMethod("invokeRestart") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    IokeObject restart = IokeObject.as(message.getEvaluatedArgument(0, context));
                    Runtime.RestartInfo realRestart = null;
                    List<Object> args = new ArrayList<Object>();
                    if(restart.isSymbol()) {
                        String name = Symbol.getText(restart);
                        realRestart = context.runtime.findActiveRestart(name);
                        if(null == realRestart) {
                            throw new RuntimeException("No restart " + name + " is active");
                        }
                        
                    } else {
                        realRestart = context.runtime.findActiveRestart(restart);
                        if(null == realRestart) {
                            throw new RuntimeException("The restart " + restart + " is not active");
                        }
                    }

                    int argCount = message.getArguments().size();
                    for(int i = 1;i<argCount;i++) {
                        args.add(message.getEvaluatedArgument(i, context));
                    }

                    throw new ControlFlow.Restart(realRestart, args);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("takes either a name (as a symbol) or a Restart instance. if the restart is active, will return that restart, otherwise returns nil..", new DefaultBehaviorJavaMethod("findRestart") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    IokeObject restart = IokeObject.as(message.getEvaluatedArgument(0, context));
                    Runtime.RestartInfo realRestart = null;
                    if(restart.isSymbol()) {
                        String name = Symbol.getText(restart);
                        realRestart = context.runtime.findActiveRestart(name);
                    } else if(restart.getKind().equals("Restart")) {
                        realRestart = context.runtime.findActiveRestart(restart);
                    } else {
                        throw new RuntimeException("unexpected argument: " + restart);
                    }
                    if(realRestart == null) {
                        return context.runtime.nil;
                    } else {
                        return realRestart.restart;
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Takes one evaluated Text argument and returns either true or false if this object or one of it's mimics have the kind of the name specified", new DefaultBehaviorJavaMethod("kind?") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    String kind = Text.getText(message.getEvaluatedArgument(0, context));
                    return IokeObject.isKind(on, kind) ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Takes one evaluated argument and returns either true or false if this object or one of it's mimics mimics that argument", new DefaultBehaviorJavaMethod("mimics?") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    IokeObject arg = IokeObject.as(message.getEvaluatedArgument(0, context));
                    return IokeObject.isMimic(on, arg) ? context.runtime._true : context.runtime._false;
                }
            }));


        obj.registerMethod(runtime.newJavaMethod("Takes one evaluated argument and returns either true or false if this object or one of it's mimics mimics that argument. exactly the same as 'mimics?'", new DefaultBehaviorJavaMethod("is?") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    IokeObject arg = IokeObject.as(message.getEvaluatedArgument(0, context));
                    return IokeObject.isMimic(on, arg) ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Takes one evaluated argument and adds it to the list of mimics for the receiver. the receiver will be returned.", new DefaultBehaviorJavaMethod("mimic!") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    IokeObject newMimic = IokeObject.as(message.getEvaluatedArgument(0, context));
                    IokeObject.as(on).mimics(newMimic, message, context);
                    return on;
                }
            }));
    }
}// DefaultBehavior
