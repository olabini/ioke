/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.ArrayList;
import java.util.List;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class DefaultBehavior {
    public static void init(IokeObject obj) {
        final Runtime runtime = obj.runtime;
        obj.setKind("DefaultBehavior");

        obj.registerMethod(runtime.newJavaMethod("returns result of evaluating first argument", new JavaMethod("") {
                @Override
                public IokeObject activate(IokeObject method, IokeObject context, Message message, IokeObject on) throws ControlFlow {
                    return message.getEvaluatedArgument(0, context);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("calls mimic.", new JavaMethod("derive") {
                @Override
                public IokeObject activate(IokeObject method, IokeObject context, Message message, IokeObject on) throws ControlFlow {
                    return runtime.base.getCell(message, context, "mimic").activate(context, message, on);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("breaks out of the enclosing context. if an argument is supplied, this will be returned as the result of the object breaking out of", new JavaMethod("break") {
                @Override
                public IokeObject activate(IokeObject method, IokeObject context, Message message, IokeObject on) throws ControlFlow {
                    IokeObject value = runtime.nil;
                    if(message.getArgumentCount() > 0) {
                        value = message.getEvaluatedArgument(0, context);
                    }
                    throw new ControlFlow.Break(value);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("until the first argument evaluates to something true, loops and evaluates the next argument", new JavaMethod("until") {
                @Override
                public IokeObject activate(IokeObject method, IokeObject context, Message message, IokeObject on) throws ControlFlow {
                    if(message.getArgumentCount() == 0) {
                        return runtime.nil;
                    }

                    boolean body = message.getArgumentCount() > 1;
                    IokeObject ret = runtime.nil;

                    try {
                        while(!message.getEvaluatedArgument(0, context).isTrue()) {
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

        obj.registerMethod(runtime.newJavaMethod("while the first argument evaluates to something true, loops and evaluates the next argument", new JavaMethod("while") {
                @Override
                public IokeObject activate(IokeObject method, IokeObject context, Message message, IokeObject on) throws ControlFlow {
                    if(message.getArgumentCount() == 0) {
                        return runtime.nil;
                    }

                    boolean body = message.getArgumentCount() > 1;
                    IokeObject ret = runtime.nil;

                    try {
                        while(message.getEvaluatedArgument(0, context).isTrue()) {
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

        obj.registerMethod(runtime.newJavaMethod("loops forever - executing it's argument over and over until interrupted in some way.", new JavaMethod("loop") {
                @Override
                public IokeObject activate(IokeObject method, IokeObject context, Message message, IokeObject on) throws ControlFlow {
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

        obj.registerMethod(runtime.newJavaMethod("evaluates the first arguments, and then evaluates the second argument if the result was true, otherwise the last argument. returns the result of the call, or the result if it's not true.", new JavaMethod("if") {
                @Override
                public IokeObject activate(IokeObject method, IokeObject context, Message message, IokeObject on) throws ControlFlow {
                    IokeObject test = message.getEvaluatedArgument(0, context);
                    if(test.isTrue()) {
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

        obj.registerMethod(runtime.newJavaMethod("expects one 'strange' argument. creates a new instance of Text with the given Java String backing it.", new JavaMethod("internal:createText") {
                @Override
                public IokeObject activate(IokeObject method, IokeObject context, Message message, IokeObject on) {
                    String s = (String)message.getArg1();
                    
                    return runtime.newText(s.substring(1, s.length()-1));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects one 'strange' argument. creates a new instance of Number that represents the number found in the strange argument.", new JavaMethod("internal:createNumber") {
                @Override
                public IokeObject activate(IokeObject method, IokeObject context, Message message, IokeObject on) {
                    String s = (String)message.getArg1();
                    return runtime.newNumber(s);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects one argument, which is the unevaluated name of the cell to work on. will retrieve the current value of this cell, call 'succ' to that value and then send = to the current receiver with the name and the resulting value.", new JavaMethod("++") {
                @Override
                public IokeObject activate(IokeObject method, IokeObject context, Message message, IokeObject on) throws ControlFlow {
                    Message nameMessage = (Message)message.getArg1();
                    String name = nameMessage.getName();
                    IokeObject current = on.getCell(message, context, name);
                    IokeObject value = runtime.succ.sendTo(context, current);
                    return runtime.setValue.sendTo(context, on, nameMessage, value);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects two arguments, the first unevaluated, the second evaluated. assigns the result of evaluating the second argument in the context of the caller, and assigns this result to the name provided by the first argument. the first argument remains unevaluated. the result of the assignment is the value assigned to the name. if the second argument is a method-like object and it's name is not set, that name will be set to the name of the cell.", new JavaMethod("=") {
                @Override
                public IokeObject activate(IokeObject method, IokeObject context, Message message, IokeObject on) throws ControlFlow {
                    String name = ((Message)message.getArg1()).getName();
                    IokeObject value = message.getEvaluatedArgument(1, context);
                    on.setCell(name, value);

                    if((value.data instanceof Method) && (((Method)value.data).name == null)) {
                        ((Method)value.data).name = name;
                    }
                    
                    return value;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns a textual representation of the object called on.", new JavaMethod("asText") {
                @Override
                public IokeObject activate(IokeObject method, IokeObject context, Message message, IokeObject on) {
                    return runtime.newText(on.toString());
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns a more detailed textual representation of the object called on, than asText.", new JavaMethod("representation") {
                @Override
                public IokeObject activate(IokeObject method, IokeObject context, Message message, IokeObject on) {
                    return runtime.newText(on.representation());
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns the documentation text of the object called on. anything can have a documentation text and an object inherits it's documentation string text the object it mimcs - at mimic time.", new JavaMethod("documentation") {
                @Override
                public IokeObject activate(IokeObject method, IokeObject context, Message message, IokeObject on) {
                    return runtime.newText(on.documentation);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects one evaluated text argument and returns the cell that matches that name, without activating even if it's activatable.", new JavaMethod("cell") {
                @Override
                public IokeObject activate(IokeObject method, IokeObject context, Message message, IokeObject on) throws ControlFlow {
                    String name = ((Text)(runtime.asText.sendTo(context, ((Message)message.getArguments().get(0)).evaluateCompleteWith(context, context.getRealContext())).data)).getText();
                    return on.getCell(message, context, name);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects any number of unevaluated arguments. if no arguments at all are given, will just return nil. creates a new method based on the arguments. this method will be evaluated using the context of the object it's called on, and thus the definition can not refer to the outside scope where the method is defined. (there are other ways of achieving this). all arguments except the last one is expected to be names of arguments that will be used in the method. there will possible be additions to the format of arguments later on - including named parameters and optional arguments. the actual code is the last argument given.", new JavaMethod("method") {
                @Override
                public IokeObject activate(IokeObject method, IokeObject context, Message message, IokeObject on) {
                    List<Object> args = message.getArguments();

                    if(args.size() == 0) {
                        return runtime.newJavaMethod("returns nil", new JavaMethod("nil") {
                            public IokeObject activate(IokeObject context, Message message, IokeObject on) {
                                return runtime.nil;
                            }});
                    }

                    String doc = null;

                    List<String> argNames = new ArrayList<String>(args.size()-1);
                    int start = 0;
                    if(args.size() > 0 && ((Message)args.get(0)).getName().equals("internal:createText")) {
                        start++;
                        String s = ((String)((Message)args.get(0)).getArguments().get(0));
                        doc = s.substring(1, s.length()-1);
                    }

                    for(Object obj : args.subList(start, args.size()-1)) {
                        argNames.add(((Message)obj).getName());
                    }

                    return runtime.newMethod(doc, runtime.defaultMethod, new DefaultMethod(context, argNames, (Message)args.get(args.size()-1)));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("takes one or more evaluated string argument. will import the files corresponding to each of the strings named based on the Ioke loading behavior that can be found in the documentation for the loadBehavior cell on System.", new JavaMethod("use") {
                @Override
                public IokeObject activate(IokeObject method, IokeObject context, Message message, IokeObject on) throws ControlFlow {
                    if(message.getArgumentCount() > 0) {
                        String name = ((Text)runtime.asText.sendTo(context, message.getEvaluatedArgument(0, context)).data).getText();
                        if(((IokeSystem)runtime.system.data).use(context, message, name)) {
                            return runtime._true;
                        } else {
                            return runtime._false;
                        }
                    }
                    
                    return runtime.nil;
                }
            }));
    }
}// DefaultBehavior
