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
import ioke.lang.util.StringUtils;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class DefaultBehavior {
    public static IokeObject signal(Object datum, List<Object> positionalArgs, Map<String, Object> keywordArgs, IokeObject message, IokeObject context) throws ControlFlow {
        IokeObject newCondition = null;
        if(Text.isText(datum)) {
            newCondition = IokeObject.as(context.runtime.condition.getCell(message, context, "Default")).mimic(message, context);
            newCondition.setCell("text", datum);
        } else {
            if(keywordArgs.size() == 0) {
                newCondition = IokeObject.as(datum);
            } else {
                newCondition = IokeObject.as(datum).mimic(message, context);
                for(Map.Entry<String,Object> val : keywordArgs.entrySet()) {
                    newCondition.setCell(val.getKey(), val.getValue());
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

    public static void init(IokeObject obj) {
        final Runtime runtime = obj.runtime;
        obj.setKind("DefaultBehavior");

        obj.setCell("=",         runtime.base.getCells().get("="));
        obj.setCell("cell",      runtime.base.getCells().get("cell"));
        obj.setCell("cell=",     runtime.base.getCells().get("cell="));
        obj.setCell("cells",     runtime.base.getCells().get("cells"));
        obj.setCell("cellNames", runtime.base.getCells().get("cellNames"));


        obj.registerMethod(runtime.newJavaMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the + method will be called on it. finally, the result of the call to + will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.", new JavaMethod("+=") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    IokeObject m1 = IokeObject.as(Message.getArg1(message));
                    String name = m1.getName();
                    if(m1.getArgumentCount() == 0) {
                        Object val = IokeObject.getCell(on, message, context, name);
                        Object result = context.runtime.plusMessage.sendTo(context, val, Message.getArg2(message));
                        return context.runtime.setValue.sendTo(context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result))));
                    } else {
                        Object val = m1.sendTo(context, on);
                        Object result = context.runtime.plusMessage.sendTo(context, val, Message.getArg2(message));
                        return context.runtime.setValue.sendTo(context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result))));
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the - method will be called on it. finally, the result of the call to - will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.", new JavaMethod("-=") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    IokeObject m1 = IokeObject.as(Message.getArg1(message));
                    String name = m1.getName();
                    if(m1.getArgumentCount() == 0) {
                        Object val = IokeObject.getCell(on, message, context, name);
                        Object result = context.runtime.minusMessage.sendTo(context, val, Message.getArg2(message));
                        return context.runtime.setValue.sendTo(context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result))));
                    } else {
                        Object val = m1.sendTo(context, on);
                        Object result = context.runtime.minusMessage.sendTo(context, val, Message.getArg2(message));
                        return context.runtime.setValue.sendTo(context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result))));
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the * method will be called on it. finally, the result of the call to * will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.", new JavaMethod("*=") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    IokeObject m1 = IokeObject.as(Message.getArg1(message));
                    String name = m1.getName();
                    if(m1.getArgumentCount() == 0) {
                        Object val = IokeObject.getCell(on, message, context, name);
                        Object result = context.runtime.multMessage.sendTo(context, val, Message.getArg2(message));
                        return context.runtime.setValue.sendTo(context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result))));
                    } else {
                        Object val = m1.sendTo(context, on);
                        Object result = context.runtime.multMessage.sendTo(context, val, Message.getArg2(message));
                        return context.runtime.setValue.sendTo(context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result))));
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the / method will be called on it. finally, the result of the call to / will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.", new JavaMethod("/=") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    IokeObject m1 = IokeObject.as(Message.getArg1(message));
                    String name = m1.getName();
                    if(m1.getArgumentCount() == 0) {
                        Object val = IokeObject.getCell(on, message, context, name);
                        Object result = context.runtime.divMessage.sendTo(context, val, Message.getArg2(message));
                        return context.runtime.setValue.sendTo(context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result))));
                    } else {
                        Object val = m1.sendTo(context, on);
                        Object result = context.runtime.divMessage.sendTo(context, val, Message.getArg2(message));
                        return context.runtime.setValue.sendTo(context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result))));
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the % method will be called on it. finally, the result of the call to % will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.", new JavaMethod("%=") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    IokeObject m1 = IokeObject.as(Message.getArg1(message));
                    String name = m1.getName();
                    if(m1.getArgumentCount() == 0) {
                        Object val = IokeObject.getCell(on, message, context, name);
                        Object result = context.runtime.modMessage.sendTo(context, val, Message.getArg2(message));
                        return context.runtime.setValue.sendTo(context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result))));
                    } else {
                        Object val = m1.sendTo(context, on);
                        Object result = context.runtime.modMessage.sendTo(context, val, Message.getArg2(message));
                        return context.runtime.setValue.sendTo(context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result))));
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the ** method will be called on it. finally, the result of the call to ** will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.", new JavaMethod("**=") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    IokeObject m1 = IokeObject.as(Message.getArg1(message));
                    String name = m1.getName();
                    if(m1.getArgumentCount() == 0) {
                        Object val = IokeObject.getCell(on, message, context, name);
                        Object result = context.runtime.expMessage.sendTo(context, val, Message.getArg2(message));
                        return context.runtime.setValue.sendTo(context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result))));
                    } else {
                        Object val = m1.sendTo(context, on);
                        Object result = context.runtime.expMessage.sendTo(context, val, Message.getArg2(message));
                        return context.runtime.setValue.sendTo(context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result))));
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the & method will be called on it. finally, the result of the call to & will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.", new JavaMethod("&=") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    IokeObject m1 = IokeObject.as(Message.getArg1(message));
                    String name = m1.getName();
                    if(m1.getArgumentCount() == 0) {
                        Object val = IokeObject.getCell(on, message, context, name);
                        Object result = context.runtime.binAndMessage.sendTo(context, val, Message.getArg2(message));
                        return context.runtime.setValue.sendTo(context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result))));
                    } else {
                        Object val = m1.sendTo(context, on);
                        Object result = context.runtime.binAndMessage.sendTo(context, val, Message.getArg2(message));
                        return context.runtime.setValue.sendTo(context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result))));
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the | method will be called on it. finally, the result of the call to | will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.", new JavaMethod("|=") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    IokeObject m1 = IokeObject.as(Message.getArg1(message));
                    String name = m1.getName();
                    if(m1.getArgumentCount() == 0) {
                        Object val = IokeObject.getCell(on, message, context, name);
                        Object result = context.runtime.binOrMessage.sendTo(context, val, Message.getArg2(message));
                        return context.runtime.setValue.sendTo(context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result))));
                    } else {
                        Object val = m1.sendTo(context, on);
                        Object result = context.runtime.binOrMessage.sendTo(context, val, Message.getArg2(message));
                        return context.runtime.setValue.sendTo(context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result))));
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the ^ method will be called on it. finally, the result of the call to ^ will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.", new JavaMethod("^=") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    IokeObject m1 = IokeObject.as(Message.getArg1(message));
                    String name = m1.getName();
                    if(m1.getArgumentCount() == 0) {
                        Object val = IokeObject.getCell(on, message, context, name);
                        Object result = context.runtime.binXorMessage.sendTo(context, val, Message.getArg2(message));
                        return context.runtime.setValue.sendTo(context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result))));
                    } else {
                        Object val = m1.sendTo(context, on);
                        Object result = context.runtime.binXorMessage.sendTo(context, val, Message.getArg2(message));
                        return context.runtime.setValue.sendTo(context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result))));
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the << method will be called on it. finally, the result of the call to << will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.", new JavaMethod("<<=") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    IokeObject m1 = IokeObject.as(Message.getArg1(message));
                    String name = m1.getName();
                    if(m1.getArgumentCount() == 0) {
                        Object val = IokeObject.getCell(on, message, context, name);
                        Object result = context.runtime.lshMessage.sendTo(context, val, Message.getArg2(message));
                        return context.runtime.setValue.sendTo(context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result))));
                    } else {
                        Object val = m1.sendTo(context, on);
                        Object result = context.runtime.lshMessage.sendTo(context, val, Message.getArg2(message));
                        return context.runtime.setValue.sendTo(context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result))));
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the >> method will be called on it. finally, the result of the call to >> will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.", new JavaMethod(">>=") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    IokeObject m1 = IokeObject.as(Message.getArg1(message));
                    String name = m1.getName();
                    if(m1.getArgumentCount() == 0) {
                        Object val = IokeObject.getCell(on, message, context, name);
                        Object result = context.runtime.rshMessage.sendTo(context, val, Message.getArg2(message));
                        return context.runtime.setValue.sendTo(context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result))));
                    } else {
                        Object val = m1.sendTo(context, on);
                        Object result = context.runtime.rshMessage.sendTo(context, val, Message.getArg2(message));
                        return context.runtime.setValue.sendTo(context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result))));
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns true if the left hand side is equal to the right hand side. exactly what this means depend on the object. the default behavior of Ioke objects is to only be equal if they are the same instance.", new JavaMethod("==") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    return IokeObject.equals(on, message.getEvaluatedArgument(0, context)) ? context.runtime._true : context.runtime._false ;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns a text hex representation of the receiver in upper case hex literal, starting with 0x. This value is based on System.identityHashCode, and as such is not totally guaranteed to be totally unique. but almost.", new JavaMethod("uniqueHexId") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    return context.runtime.newText("0x" + Integer.toHexString(System.identityHashCode(on)).toUpperCase());
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns false if the left hand side is equal to the right hand side. exactly what this means depend on the object. the default behavior of Ioke objects is to only be equal if they are the same instance.", new JavaMethod("!=") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    return !IokeObject.equals(on, message.getEvaluatedArgument(0, context)) ? context.runtime._true : context.runtime._false ;
                }
            }));


        obj.registerMethod(runtime.newJavaMethod("breaks out of the enclosing context. if an argument is supplied, this will be returned as the result of the object breaking out of", new JavaMethod("break") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object value = runtime.nil;
                    if(message.getArgumentCount() > 0) {
                        value = message.getEvaluatedArgument(0, context);
                    }
                    throw new ControlFlow.Break(value);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("until the first argument evaluates to something true, loops and evaluates the next argument", new JavaMethod("until") {
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

        obj.registerMethod(runtime.newJavaMethod("while the first argument evaluates to something true, loops and evaluates the next argument", new JavaMethod("while") {
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

        obj.registerMethod(runtime.newJavaMethod("loops forever - executing it's argument over and over until interrupted in some way.", new JavaMethod("loop") {
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

        obj.registerMethod(runtime.newJavaMethod("evaluates the first arguments, and then evaluates the second argument if the result was true, otherwise the last argument. returns the result of the call, or the result if it's not true.", new JavaMethod("if") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object test = message.getEvaluatedArgument(0, context);

                    LexicalContext itContext = new LexicalContext(context.runtime, context.getRealContext(), "Lexical activation context", message, context);
                    itContext.setCell("it", test);

                    if(IokeObject.isTrue(test)) {
                        if(message.getArgumentCount() > 1) {
                            return message.getEvaluatedArgument(1, itContext);
                        } else {
                            return test;
                        }
                    } else {
                        if(message.getArgumentCount() > 2) {
                            return message.getEvaluatedArgument(2, itContext);
                        } else {
                            return test;
                        }
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("evaluates the first arguments, and then evaluates the second argument if the result was false, otherwise the last argument. returns the result of the call, or the result if it's true.", new JavaMethod("unless") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object test = message.getEvaluatedArgument(0, context);

                    LexicalContext itContext = new LexicalContext(context.runtime, context.getRealContext(), "Lexical activation context", message, context);
                    itContext.setCell("it", test);

                    if(IokeObject.isTrue(test)) {
                        if(message.getArgumentCount() > 2) {
                            return message.getEvaluatedArgument(2, itContext);
                        } else {
                            return test;
                        }
                    } else {
                        if(message.getArgumentCount() > 1) {
                            return message.getEvaluatedArgument(1, itContext);
                        } else {
                            return test;
                        }
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("takes zero or more arguments, calls asText on non-text arguments, and then concatenates them and returns the result.", new JavaMethod("internal:concatenateText") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    DefaultArgumentsDefinition.getEvaluatedArguments(message, context, args, new HashMap<String, Object>());

                    StringBuilder sb = new StringBuilder();

                    if(IokeObject.data(on) instanceof Text) {
                        sb.append(Text.getText(on));
                    }

                    for(Object o : args) {
                        if(IokeObject.data(o) instanceof Text) {
                            sb.append(Text.getText(o));
                        } else {
                            sb.append(Text.getText(context.runtime.asText.sendTo(context, o)));
                        }
                    }

                    return context.runtime.newText(sb.toString());
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects one 'strange' argument. creates a new instance of Text with the given Java String backing it.", new JavaMethod("internal:createText") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object o = Message.getArg1(message);
                    if(o instanceof String) {
                        String s = (String)o;
                        return runtime.newText(new StringUtils().replaceEscapes(s));
                    } else {
                        return IokeObject.convertToText(message.getEvaluatedArgument(0, context), message, context);
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects one 'strange' argument. creates a new instance of Pattern with the given Java String backing it.", new JavaMethod("internal:createPattern") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object o = Message.getArg1(message);
                    if(o instanceof String) {
                        String s = (String)o;
                        return runtime.newPattern(new StringUtils().replaceEscapes(s));
                    } else {
                        return IokeObject.convertToPattern(message.getEvaluatedArgument(0, context), message, context);
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects one 'strange' argument. creates a new instance of Number that represents the number found in the strange argument.", new JavaMethod("internal:createNumber") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    String s = (String)Message.getArg1(message);
                    return runtime.newNumber(s);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects one argument, which is the unevaluated name of the cell to work on. will retrieve the current value of this cell, call 'succ' to that value and then send = to the current receiver with the name and the resulting value.", new JavaMethod("++") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    IokeObject nameMessage = (IokeObject)Message.getArg1(message);
                    String name = nameMessage.getName();
                    Object current = IokeObject.getCell(on, message, context, name);
                    Object value = runtime.succ.sendTo(context, current);
                    return runtime.setValue.sendTo(context, on, nameMessage, value);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects one argument, which is the unevaluated name of the cell to work on. will retrieve the current value of this cell, call 'pred' to that value and then send = to the current receiver with the name and the resulting value.", new JavaMethod("--") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    IokeObject nameMessage = (IokeObject)Message.getArg1(message);
                    String name = nameMessage.getName();
                    Object current = IokeObject.getCell(on, message, context, name);
                    Object value = runtime.pred.sendTo(context, current);
                    return runtime.setValue.sendTo(context, on, nameMessage, value);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns a textual representation of the object called on.", new JavaMethod("asText") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    return runtime.newText(on.toString());
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns the documentation text of the object called on. anything can have a documentation text and an object inherits it's documentation string text the object it mimcs - at mimic time.", new JavaMethod("documentation") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    return runtime.newText(IokeObject.as(on).documentation);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects any number of unevaluated arguments. if no arguments at all are given, will just return nil. creates a new method based on the arguments. this method will be evaluated using the context of the object it's called on, and thus the definition can not refer to the outside scope where the method is defined. (there are other ways of achieving this). all arguments except the last one is expected to be names of arguments that will be used in the method. there will possible be additions to the format of arguments later on - including named parameters and optional arguments. the actual code is the last argument given.", new JavaMethod("method") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = message.getArguments();

                    if(args.size() == 0) {
                        final Message mx = new Message(context.runtime, "nil", null, Message.Type.MESSAGE);
                        mx.setFile(Message.file(message));
                        mx.setLine(Message.line(message));
                        mx.setPosition(Message.position(message));
                        final IokeObject mmx = context.runtime.createMessage(mx);
                        return runtime.newMethod(null, runtime.defaultMethod, new DefaultMethod(context, DefaultArgumentsDefinition.empty(), mmx));
                    }

                    String doc = null;

                    List<String> argNames = new ArrayList<String>(args.size()-1);
                    int start = 0;
                    if(args.size() > 1 && ((IokeObject)Message.getArg1(message)).getName().equals("internal:createText")) {
                        start++;
                        String s = ((String)((IokeObject)args.get(0)).getArguments().get(0));
                        doc = s;
                    }

                    DefaultArgumentsDefinition def = DefaultArgumentsDefinition.createFrom(args, start, args.size()-1, message, on, context);

                    return runtime.newMethod(doc, runtime.defaultMethod, new DefaultMethod(context, def, (IokeObject)args.get(args.size()-1)));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects one code argument, optionally preceeded by a documentation string. will create a new DefaultMacro based on the code and return it.", new JavaMethod("macro") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = message.getArguments();

                    if(args.size() == 0) {
                        final Message mx = new Message(context.runtime, "nil", null, Message.Type.MESSAGE);
                        mx.setFile(Message.file(message));
                        mx.setLine(Message.line(message));
                        mx.setPosition(Message.position(message));
                        final IokeObject mmx = context.runtime.createMessage(mx);

                        return runtime.newMacro(null, runtime.defaultMacro, new DefaultMacro(context, mmx));
                    }

                    String doc = null;

                    int start = 0;
                    if(args.size() > 1 && ((IokeObject)Message.getArg1(message)).getName().equals("internal:createText")) {
                        start++;
                        String s = ((String)((IokeObject)args.get(0)).getArguments().get(0));
                        doc = s;
                    }

                    return runtime.newMacro(doc, runtime.defaultMacro, new DefaultMacro(context, (IokeObject)args.get(start)));
                }
            }));

        /// TODO: when tests are converted to Ioke, this should be unescaped again.
        // Since Java 1.5 and 1.6 on Java + JRuby have trouble with the lambda sign, comment it out for now.

//         obj.registerMethod(runtime.newJavaMethod("creates a new lexical block that can be executed at will, while retaining a reference to the lexical closure it was created in. it will always update variables if they exist. there is currently no way of introducing shadowing variables in the local context. new variables can be created though, just like in a method. a lexical block mimics LexicalBlock, and can take arguments. at the moment these are restricted to required arguments, but support for the same argument types as DefaultMethod will come. same as fn()", new JavaMethod("ʎ") {
//                 @Override
//                 public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
//                     List<Object> args = message.getArguments();
//                     if(args.isEmpty()) {
//                         return runtime.newLexicalBlock(runtime.lexicalBlock, new LexicalBlock(context, DefaultArgumentsDefinition.empty(), method.runtime.nilMessage));
//                     }

//                     IokeObject code = IokeObject.as(args.get(args.size()-1));

//                     DefaultArgumentsDefinition def = DefaultArgumentsDefinition.createFrom(args, 0, args.size()-1, message, on, context);
//                     return runtime.newLexicalBlock(runtime.lexicalBlock, new LexicalBlock(context, def, code));
//                 }
//             }));

        obj.registerMethod(runtime.newJavaMethod("creates a new lexical block that can be executed at will, while retaining a reference to the lexical closure it was created in. it will always update variables if they exist. there is currently no way of introducing shadowing variables in the local context. new variables can be created though, just like in a method. a lexical block mimics LexicalBlock, and can take arguments. at the moment these are restricted to required arguments, but support for the same argument types as DefaultMethod will come.", new JavaMethod("fn") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = message.getArguments();
                    if(args.isEmpty()) {
                        return runtime.newLexicalBlock(runtime.lexicalBlock, new LexicalBlock(context, DefaultArgumentsDefinition.empty(), method.runtime.nilMessage));
                    }

                    IokeObject code = IokeObject.as(args.get(args.size()-1));

                    DefaultArgumentsDefinition def = DefaultArgumentsDefinition.createFrom(args, 0, args.size()-1, message, on, context);
                    return runtime.newLexicalBlock(runtime.lexicalBlock, new LexicalBlock(context, def, code));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("takes one or more evaluated string argument. will import the files corresponding to each of the strings named based on the Ioke loading behavior that can be found in the documentation for the loadBehavior cell on System.", new JavaMethod("use") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    if(message.getArgumentCount() > 0) {
                        String name = Text.getText(runtime.asText.sendTo(context, message.getEvaluatedArgument(0, context)));
                        if(((IokeSystem)runtime.system.data).use(IokeObject.as(on), context, message, name)) {
                            return runtime._true;
                        } else {
                            return runtime._false;
                        }
                    }
                    
                    return runtime.nil;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("takes one optional unevaluated parameter (this should be the first if provided), that is the name of the restart to create. this will default to nil. takes two keyword arguments, report: and test:. These should both be lexical blocks. if not provided, there will be reasonable defaults. the only required argument is something that evaluates into a lexical block. this block is what will be executed when the restart is invoked. will return a Restart mimic.", new JavaMethod("restart") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
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
                                                                                     "TooManyArguments")).mimic(message, context);
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
                                                                                           "TooFewArguments")).mimic(message, context);
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
                                report = IokeObject.as(m.next.evaluateCompleteWithoutExplicitReceiver(context, context.getRealContext()));
                            } else if(n.equals("test:")) {
                                test = IokeObject.as(m.next.evaluateCompleteWithoutExplicitReceiver(context, context.getRealContext()));
                            } else {
                                final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition, 
                                                                                                   message, 
                                                                                                   context, 
                                                                                                   "Error", 
                                                                                                   "Invocation", 
                                                                                                   "MismatchedKeywords")).mimic(message, context);
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

        obj.registerMethod(runtime.newJavaMethod("takes zero or more arguments that should evaluate to a condition mimic - this list will match all the conditions this Rescue should be able to catch. the last argument is not optional, and should be something activatable that takes one argument - the condition instance. will return a Rescue mimic.", new JavaMethod("rescue") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
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
                    
                    IokeObject.setCell(rescue, "handler", handler);
                    IokeObject.setCell(rescue, "conditions", context.runtime.newList(conds));

                    return rescue;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("takes zero or more arguments that should evaluate to a condition mimic - this list will match all the conditions this Handler should be able to catch. the last argument is not optional, and should be something activatable that takes one argument - the condition instance. will return a Handler mimic.", new JavaMethod("handle") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
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
                    
                    IokeObject.setCell(handle, "handler", code);
                    IokeObject.setCell(handle, "conditions", context.runtime.newList(conds));

                    return handle;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("will evaluate all arguments, and expects all except for the last to be a Restart. bind will associate these restarts for the duration of the execution of the last argument and then unbind them again. it will return the result of the last argument, or if a restart is executed it will instead return the result of that invocation.", new JavaMethod("bind") {
                @Override
                public Object activate(IokeObject method, final IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    final Runtime runtime = context.runtime;
                    List<Object> args = message.getArguments();
                    int argCount = args.size();
                    if(argCount == 0) {
                        return context.runtime.nil;
                    }

                    IokeObject code = IokeObject.as(args.get(argCount-1));
                    List<Runtime.RestartInfo> restarts = new ArrayList<Runtime.RestartInfo>();
                    List<Runtime.RescueInfo> rescues = new ArrayList<Runtime.RescueInfo>();
                    List<Runtime.HandlerInfo> handlers = new ArrayList<Runtime.HandlerInfo>();

                    Runtime.BindIndex index = context.runtime.getBindIndex();

                    try {
                        for(Object o : args.subList(0, argCount-1)) {
                            IokeObject bindable = IokeObject.as(IokeObject.as(o).evaluateCompleteWithoutExplicitReceiver(context, context.getRealContext()));
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
                                                                                                       "IncorrectType")).mimic(message, context);
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
                                            public IokeObject invoke(IokeObject context, List<Object> arguments) throws ControlFlow {
                                                newCell[0] = arguments.get(0);
                                                return runtime.nil;
                                            }
                                        }
                                        );
                                    bindable = IokeObject.as(newCell[0]);
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
                            // Might need to unregister restarts before doing this...
                            return runtime.callMessage.sendTo(context, runtime.code.sendTo(context, ri.restart), e.getArguments());
                        } else {
                            throw e;
                        } 
                    } catch(ControlFlow.Rescue e) {
                        Runtime.RescueInfo ri = null;
                        if((ri = e.getRescue()).token == rescues) {
                            return runtime.callMessage.sendTo(context, runtime.handlerMessage.sendTo(context, ri.rescue), e.getCondition());
                        } else {
                            throw e;
                        }
                   } finally {
                        runtime.unregisterHandlers(handlers);
                        runtime.unregisterRescues(rescues);
                        runtime.unregisterRestarts(restarts); 
                   }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("takes either a name (as a symbol) or a Restart instance. if the restart is active, will transfer control to it, supplying the rest of the given arguments to that restart.", new JavaMethod("invokeRestart") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    final Runtime runtime = context.runtime;

                    IokeObject restart = IokeObject.as(message.getEvaluatedArgument(0, context));
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
                                                                                               "RestartNotActive")).mimic(message, context);
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
                                                                                               "RestartNotActive")).mimic(message, context);
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

                    int argCount = message.getArguments().size();
                    for(int i = 1;i<argCount;i++) {
                        args.add(message.getEvaluatedArgument(i, context));
                    }

                    throw new ControlFlow.Restart(realRestart, args);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("takes either a name (as a symbol) or a Restart instance. if the restart is active, will return that restart, otherwise returns nil.", new JavaMethod("findRestart") {
                @Override
                public Object activate(IokeObject method, final IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    final Runtime runtime = context.runtime;
                    IokeObject restart = IokeObject.as(message.getEvaluatedArgument(0, context));
                    Runtime.RestartInfo realRestart = null;
                    while(!(restart.isSymbol() || restart.getKind().equals("Restart"))) {
                        final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition, 
                                                                                           message, 
                                                                                           context, 
                                                                                           "Error", 
                                                                                           "Type",
                                                                                           "IncorrectType")).mimic(message, context);
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
                                public IokeObject invoke(IokeObject context, List<Object> arguments) throws ControlFlow {
                                    newCell[0] = arguments.get(0);
                                    return runtime.nil;
                                }
                            }
                            );
                        restart = IokeObject.as(newCell[0]);
                    }

                    if(restart.isSymbol()) {
                        String name = Symbol.getText(restart);
                        realRestart = runtime.findActiveRestart(name);
                    } else if(restart.getKind().equals("Restart")) {
                        realRestart = runtime.findActiveRestart(restart);
                    }
                    if(realRestart == null) {
                        return runtime.nil;
                    } else {
                        return realRestart.restart;
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("takes one or more datums descibing the condition to signal. this datum can be either a mimic of a Condition, in which case it will be signalled directly, or it can be a mimic of a Condition with arguments, in which case it will first be mimicked and the arguments assigned in some way. finally, if the argument is a Text, a mimic of Condition Default will be signalled, with the provided text.", new JavaMethod("signal!") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> positionalArgs = new ArrayList<Object>();
                    Map<String, Object> keywordArgs = new HashMap<String, Object>();
                    DefaultArgumentsDefinition.getEvaluatedArguments(message, context, positionalArgs, keywordArgs);

                    Object datum = positionalArgs.get(0);
                    
                    return signal(datum, positionalArgs, keywordArgs, message, context);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("takes the same kind of arguments as 'signal!', and will signal a condition. the default condition used is Condition Error Default. if no rescue or restart is invoked error! will report the condition to System err and exit the currently running Ioke VM. this might be a problem when exceptions happen inside of running Java code, as callbacks and so on.. if 'System currentDebugger' is non-nil, it will be invoked before the exiting of the VM. the exit can only be avoided by invoking a restart. that means that error! will never return. ", new JavaMethod("error!") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> positionalArgs = new ArrayList<Object>();
                    Map<String, Object> keywordArgs = new HashMap<String, Object>();
                    DefaultArgumentsDefinition.getEvaluatedArguments(message, context, positionalArgs, keywordArgs);

                    Object datum = positionalArgs.get(0);

                    if(IokeObject.data(datum) instanceof Text) {
                        Object oldDatum = datum;
                        datum = IokeObject.as(IokeObject.as(context.runtime.condition.getCell(message, context, "Error")).getCell(message, context, "Default")).mimic(message, context);
                        IokeObject.setCell(datum, message, context, "text", oldDatum);
                    }

                    IokeObject condition = signal(datum, positionalArgs, keywordArgs, message, context);
                    IokeObject err = IokeObject.as(context.runtime.system.getCell(message, context, "err"));
                    
                    context.runtime.printMessage.sendTo(context, err, context.runtime.newText("*** - "));
                    context.runtime.printlnMessage.sendTo(context, err, context.runtime.reportMessage.sendTo(context, condition));
                    
                    IokeObject currentDebugger = IokeObject.as(context.runtime.currentDebuggerMessage.sendTo(context, context.runtime.system));

                    if(!currentDebugger.isNil()) {
                        context.runtime.invokeMessage.sendTo(context, currentDebugger, condition, context);
                    }

                    throw new ControlFlow.Exit(condition);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Takes one evaluated Text argument and returns either true or false if this object or one of it's mimics have the kind of the name specified", new JavaMethod("kind?") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    String kind = Text.getText(message.getEvaluatedArgument(0, context));
                    return IokeObject.isKind(on, kind) ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Takes one evaluated argument and returns either true or false if this object or one of it's mimics mimics that argument", new JavaMethod("mimics?") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    IokeObject arg = IokeObject.as(message.getEvaluatedArgument(0, context));
                    return IokeObject.isMimic(on, arg) ? context.runtime._true : context.runtime._false;
                }
            }));


        obj.registerMethod(runtime.newJavaMethod("Takes one evaluated argument and returns either true or false if this object or one of it's mimics mimics that argument. exactly the same as 'mimics?'", new JavaMethod("is?") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    IokeObject arg = IokeObject.as(message.getEvaluatedArgument(0, context));
                    return IokeObject.isMimic(on, arg) ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Takes one evaluated argument and adds it to the list of mimics for the receiver. the receiver will be returned.", new JavaMethod("mimic!") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    IokeObject newMimic = IokeObject.as(message.getEvaluatedArgument(0, context));
                    IokeObject.as(on).mimics(newMimic, message, context);
                    return on;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Takes two evaluated text or symbol arguments that name the method to alias, and the new name to give it. returns the receiver.", new JavaMethod("aliasMethod") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    String fromName = Text.getText(runtime.asText.sendTo(context, message.getEvaluatedArgument(0, context)));
                    String toName = Text.getText(runtime.asText.sendTo(context, message.getEvaluatedArgument(1, context)));
                    IokeObject.as(on).aliasMethod(fromName, toName);
                    return on;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Takes one evaluated argument and returns a new Pair of the receiver and the argument", new JavaMethod("=>") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    return context.runtime.newPair(on, arg);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Takes one evaluated argument that is expected to be a Text, and returns the symbol corresponding to that text", new JavaMethod(":") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    String sym = Text.getText(runtime.asText.sendTo(context, message.getEvaluatedArgument(0, context)));
                    return context.runtime.getSymbol(sym);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("creates a new Dict from the arguments provided. these arguments can be two different things - either a keyword argument, or a pair. if it's a keyword argument, the entry added to the dict for it will be a symbol with the name from the keyword, without the ending colon. if it's not a keyword, it is expected to be an evaluated pair, where the first part of the pair is the key, and the second part is the value.", new JavaMethod("dict") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> arguments = message.getArguments();
                    Map<Object, Object> moo = new HashMap<Object, Object>(arguments.size());

                    for(Object o : arguments) {
                        Object key, value;
                        if(Message.isKeyword(o)) {
                            String str = Message.name(o);
                            key = context.runtime.getSymbol(str.substring(0, str.length()-1));
                            if(Message.next(o) != null) {
                                value = Message.getEvaluatedArgument(Message.next(o), context);
                            } else {
                                value = context.runtime.nil;
                            }
                        } else {
                            Object result = Message.getEvaluatedArgument(o, context);
                            if((result instanceof IokeObject) && (IokeObject.data(result) instanceof Pair)) {
                                key = Pair.getFirst(result);
                                value = Pair.getSecond(result);
                            } else {
                                key = result;
                                value = context.runtime.nil;
                            }
                        }

                        moo.put(key, value);
                    }

                    return context.runtime.newDict(moo);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("creates a new Set from the result of evaluating all arguments provided.", new JavaMethod("set") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> positionalArgs = new ArrayList<Object>();
                    Map<String, Object> keywordArgs = new HashMap<String, Object>();
                    DefaultArgumentsDefinition.getEvaluatedArguments(message, context, positionalArgs, keywordArgs);

                    return context.runtime.newSet(positionalArgs);
                }
            }));
    }
}// DefaultBehavior
