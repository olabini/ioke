/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class AssignmentBehavior {
    public static void init(IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;
        obj.setKind("DefaultBehavior Assignment");

        obj.registerMethod(runtime.newNativeMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. if that cell doesn't exist or the value it contains is not true, that cell will be set to the second argument, otherwise nothing will happen. the second argument will NOT be evaluated if the place is not assigned. the result of the expression is the value of the cell. it will use = for this assignment. this method also work together with forms such as []=.", new NativeMethod("||=") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositionalUnevaluated("place")
                    .withRequiredPositional("else")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    IokeObject m1 = IokeObject.as(Message.getArg1(message), context);
                    String name = m1.getName();

                    if(m1.getArgumentCount() == 0) {
                        Object val = IokeObject.findCell(on, message, context, name);
                        if(val == context.runtime.nul || !IokeObject.isTrue(val)) {
                            return ((Message)IokeObject.data(context.runtime.setValue)).sendTo(context.runtime.setValue, context, on, m1, Message.getArg2(message));
                        } else {
                            return val;
                        }
                    } else {
                        Object val = ((Message)IokeObject.data(m1)).sendTo(m1, context, on);
                        if(val == context.runtime.nul || !IokeObject.isTrue(val)) {
                            return ((Message)IokeObject.data(context.runtime.setValue)).sendTo(context.runtime.setValue, context, on, m1, Message.getArg2(message));
                        } else {
                            return val;
                        }
                    }
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. if that cell exist and the value it contains is a true one, that cell will be set to the second argument, otherwise nothing will happen. the second argument will NOT be evaluated if the place is not assigned. the result of the expression is the value of the cell. it will use = for this assignment. this method also work together with forms such as []=.", new NativeMethod("&&=") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositionalUnevaluated("place")
                    .withRequiredPositional("then")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    IokeObject m1 = IokeObject.as(Message.getArg1(message), context);
                    String name = m1.getName();

                    if(m1.getArgumentCount() == 0) {
                        Object val = IokeObject.findCell(on, message, context, name);
                        if(val == context.runtime.nul || !IokeObject.isTrue(val)) {
                            return val;
                        } else {
                            return ((Message)IokeObject.data(context.runtime.setValue)).sendTo(context.runtime.setValue, context, on, m1, Message.getArg2(message));
                        }
                    } else {
                        Object val = ((Message)IokeObject.data(m1)).sendTo(m1, context, on);
                        if(val == context.runtime.nul || !IokeObject.isTrue(val)) {
                            return val;
                        } else {
                            return ((Message)IokeObject.data(context.runtime.setValue)).sendTo(context.runtime.setValue, context, on, m1, Message.getArg2(message));
                        }
                    }
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the + method will be called on it. finally, the result of the call to + will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.", new NativeMethod("+=") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositionalUnevaluated("place")
                    .withRequiredPositional("addend")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    IokeObject m1 = IokeObject.as(Message.getArg1(message), context);
                    String name = m1.getName();
                    if(m1.getArgumentCount() == 0) {
                        Object val = IokeObject.getCell(on, message, context, name);
                        Object result = ((Message)IokeObject.data(context.runtime.plusMessage)).sendTo(context.runtime.plusMessage, context, val, Message.getArg2(message));
                        return ((Message)IokeObject.data(context.runtime.setValue)).sendTo(context.runtime.setValue, context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result, context))));
                    } else {
                        Object val = ((Message)IokeObject.data(m1)).sendTo(m1, context, on);
                        Object result = ((Message)IokeObject.data(context.runtime.plusMessage)).sendTo(context.runtime.plusMessage, context, val, Message.getArg2(message));
                        return ((Message)IokeObject.data(context.runtime.setValue)).sendTo(context.runtime.setValue, context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result, context))));
                    }
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the - method will be called on it. finally, the result of the call to - will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.", new NativeMethod("-=") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositionalUnevaluated("place")
                    .withRequiredPositional("subtrahend")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    IokeObject m1 = IokeObject.as(Message.getArg1(message), context);
                    String name = m1.getName();
                    if(m1.getArgumentCount() == 0) {
                        Object val = IokeObject.getCell(on, message, context, name);
                        Object result = ((Message)IokeObject.data(context.runtime.minusMessage)).sendTo(context.runtime.minusMessage, context, val, Message.getArg2(message));
                        return ((Message)IokeObject.data(context.runtime.setValue)).sendTo(context.runtime.setValue, context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result, context))));
                    } else {
                        Object val = ((Message)IokeObject.data(m1)).sendTo(m1, context, on);
                        Object result = ((Message)IokeObject.data(context.runtime.minusMessage)).sendTo(context.runtime.minusMessage, context, val, Message.getArg2(message));
                        return ((Message)IokeObject.data(context.runtime.setValue)).sendTo(context.runtime.setValue, context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result, context))));
                    }
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the * method will be called on it. finally, the result of the call to * will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.", new NativeMethod("*=") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositionalUnevaluated("place")
                    .withRequiredPositional("multiplier")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    IokeObject m1 = IokeObject.as(Message.getArg1(message), context);
                    String name = m1.getName();
                    if(m1.getArgumentCount() == 0) {
                        Object val = IokeObject.getCell(on, message, context, name);
                        Object result = ((Message)IokeObject.data(context.runtime.multMessage)).sendTo(context.runtime.multMessage, context, val, Message.getArg2(message));
                        return ((Message)IokeObject.data(context.runtime.setValue)).sendTo(context.runtime.setValue, context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result, context))));
                    } else {
                        Object val = ((Message)IokeObject.data(m1)).sendTo(m1, context, on);
                        Object result = ((Message)IokeObject.data(context.runtime.multMessage)).sendTo(context.runtime.multMessage, context, val, Message.getArg2(message));
                        return ((Message)IokeObject.data(context.runtime.setValue)).sendTo(context.runtime.setValue, context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result, context))));
                    }
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the / method will be called on it. finally, the result of the call to / will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.", new NativeMethod("/=") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositionalUnevaluated("place")
                    .withRequiredPositional("divisor")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    IokeObject m1 = IokeObject.as(Message.getArg1(message), context);
                    String name = m1.getName();
                    if(m1.getArgumentCount() == 0) {
                        Object val = IokeObject.getCell(on, message, context, name);
                        Object result = ((Message)IokeObject.data(context.runtime.divMessage)).sendTo(context.runtime.divMessage, context, val, Message.getArg2(message));
                        return ((Message)IokeObject.data(context.runtime.setValue)).sendTo(context.runtime.setValue, context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result, context))));
                    } else {
                        Object val = ((Message)IokeObject.data(m1)).sendTo(m1, context, on);
                        Object result = ((Message)IokeObject.data(context.runtime.divMessage)).sendTo(context.runtime.divMessage, context, val, Message.getArg2(message));
                        return ((Message)IokeObject.data(context.runtime.setValue)).sendTo(context.runtime.setValue, context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result, context))));
                    }
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the % method will be called on it. finally, the result of the call to % will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.", new NativeMethod("%=") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositionalUnevaluated("place")
                    .withRequiredPositional("divisor")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    IokeObject m1 = IokeObject.as(Message.getArg1(message), context);
                    String name = m1.getName();
                    if(m1.getArgumentCount() == 0) {
                        Object val = IokeObject.getCell(on, message, context, name);
                        Object result = ((Message)IokeObject.data(context.runtime.modMessage)).sendTo(context.runtime.modMessage, context, val, Message.getArg2(message));
                        return ((Message)IokeObject.data(context.runtime.setValue)).sendTo(context.runtime.setValue, context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result, context))));
                    } else {
                        Object val = ((Message)IokeObject.data(m1)).sendTo(m1, context, on);
                        Object result = ((Message)IokeObject.data(context.runtime.modMessage)).sendTo(context.runtime.modMessage, context, val, Message.getArg2(message));
                        return ((Message)IokeObject.data(context.runtime.setValue)).sendTo(context.runtime.setValue, context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result, context))));
                    }
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the ** method will be called on it. finally, the result of the call to ** will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.", new NativeMethod("**=") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositionalUnevaluated("place")
                    .withRequiredPositional("exponent")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    IokeObject m1 = IokeObject.as(Message.getArg1(message), context);
                    String name = m1.getName();
                    if(m1.getArgumentCount() == 0) {
                        Object val = IokeObject.getCell(on, message, context, name);
                        Object result = ((Message)IokeObject.data(context.runtime.expMessage)).sendTo(context.runtime.expMessage, context, val, Message.getArg2(message));
                        return ((Message)IokeObject.data(context.runtime.setValue)).sendTo(context.runtime.setValue, context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result, context))));
                    } else {
                        Object val = ((Message)IokeObject.data(m1)).sendTo(m1, context, on);
                        Object result = ((Message)IokeObject.data(context.runtime.expMessage)).sendTo(context.runtime.expMessage, context, val, Message.getArg2(message));
                        return ((Message)IokeObject.data(context.runtime.setValue)).sendTo(context.runtime.setValue, context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result, context))));
                    }
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the & method will be called on it. finally, the result of the call to & will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.", new NativeMethod("&=") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositionalUnevaluated("place")
                    .withRequiredPositional("other")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    IokeObject m1 = IokeObject.as(Message.getArg1(message), context);
                    String name = m1.getName();
                    if(m1.getArgumentCount() == 0) {
                        Object val = IokeObject.getCell(on, message, context, name);
                        Object result = ((Message)IokeObject.data(context.runtime.binAndMessage)).sendTo(context.runtime.binAndMessage, context, val, Message.getArg2(message));
                        return ((Message)IokeObject.data(context.runtime.setValue)).sendTo(context.runtime.setValue, context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result, context))));
                    } else {
                        Object val = ((Message)IokeObject.data(m1)).sendTo(m1, context, on);
                        Object result = ((Message)IokeObject.data(context.runtime.binAndMessage)).sendTo(context.runtime.binAndMessage, context, val, Message.getArg2(message));
                        return ((Message)IokeObject.data(context.runtime.setValue)).sendTo(context.runtime.setValue, context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result, context))));
                    }
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the | method will be called on it. finally, the result of the call to | will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.", new NativeMethod("|=") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositionalUnevaluated("place")
                    .withRequiredPositional("other")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    IokeObject m1 = IokeObject.as(Message.getArg1(message), context);
                    String name = m1.getName();
                    if(m1.getArgumentCount() == 0) {
                        Object val = IokeObject.getCell(on, message, context, name);
                        Object result = ((Message)IokeObject.data(context.runtime.binOrMessage)).sendTo(context.runtime.binOrMessage, context, val, Message.getArg2(message));
                        return ((Message)IokeObject.data(context.runtime.setValue)).sendTo(context.runtime.setValue, context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result, context))));
                    } else {
                        Object val = ((Message)IokeObject.data(m1)).sendTo(m1, context, on);
                        Object result = ((Message)IokeObject.data(context.runtime.binOrMessage)).sendTo(context.runtime.binOrMessage, context, val, Message.getArg2(message));
                        return ((Message)IokeObject.data(context.runtime.setValue)).sendTo(context.runtime.setValue, context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result, context))));
                    }
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the ^ method will be called on it. finally, the result of the call to ^ will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.", new NativeMethod("^=") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositionalUnevaluated("place")
                    .withRequiredPositional("other")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    IokeObject m1 = IokeObject.as(Message.getArg1(message), context);
                    String name = m1.getName();
                    if(m1.getArgumentCount() == 0) {
                        Object val = IokeObject.getCell(on, message, context, name);
                        Object result = ((Message)IokeObject.data(context.runtime.binXorMessage)).sendTo(context.runtime.binXorMessage, context, val, Message.getArg2(message));
                        return ((Message)IokeObject.data(context.runtime.setValue)).sendTo(context.runtime.setValue, context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result, context))));
                    } else {
                        Object val = ((Message)IokeObject.data(m1)).sendTo(m1, context, on);
                        Object result = ((Message)IokeObject.data(context.runtime.binXorMessage)).sendTo(context.runtime.binXorMessage, context, val, Message.getArg2(message));
                        return ((Message)IokeObject.data(context.runtime.setValue)).sendTo(context.runtime.setValue, context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result, context))));
                    }
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the << method will be called on it. finally, the result of the call to << will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.", new NativeMethod("<<=") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositionalUnevaluated("place")
                    .withRequiredPositional("other")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    IokeObject m1 = IokeObject.as(Message.getArg1(message), context);
                    String name = m1.getName();
                    if(m1.getArgumentCount() == 0) {
                        Object val = IokeObject.getCell(on, message, context, name);
                        Object result = ((Message)IokeObject.data(context.runtime.lshMessage)).sendTo(context.runtime.lshMessage, context, val, Message.getArg2(message));
                        return ((Message)IokeObject.data(context.runtime.setValue)).sendTo(context.runtime.setValue, context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result, context))));
                    } else {
                        Object val = ((Message)IokeObject.data(m1)).sendTo(m1, context, on);
                        Object result = ((Message)IokeObject.data(context.runtime.lshMessage)).sendTo(context.runtime.lshMessage, context, val, Message.getArg2(message));
                        return ((Message)IokeObject.data(context.runtime.setValue)).sendTo(context.runtime.setValue, context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result, context))));
                    }
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the >> method will be called on it. finally, the result of the call to >> will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.", new NativeMethod(">>=") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositionalUnevaluated("place")
                    .withRequiredPositional("other")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    IokeObject m1 = IokeObject.as(Message.getArg1(message), context);
                    String name = m1.getName();
                    if(m1.getArgumentCount() == 0) {
                        Object val = IokeObject.getCell(on, message, context, name);
                        Object result = ((Message)IokeObject.data(context.runtime.rshMessage)).sendTo(context.runtime.rshMessage, context, val, Message.getArg2(message));
                        return ((Message)IokeObject.data(context.runtime.setValue)).sendTo(context.runtime.setValue, context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result, context))));
                    } else {
                        Object val = ((Message)IokeObject.data(m1)).sendTo(m1, context, on);
                        Object result = ((Message)IokeObject.data(context.runtime.rshMessage)).sendTo(context.runtime.rshMessage, context, val, Message.getArg2(message));
                        return ((Message)IokeObject.data(context.runtime.setValue)).sendTo(context.runtime.setValue, context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result, context))));
                    }
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("expects one argument, which is the unevaluated name of the cell to work on. will retrieve the current value of this cell, call 'succ' to that value and then send = to the current receiver with the name and the resulting value.", new NativeMethod("++") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositionalUnevaluated("place")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);
                    IokeObject nameMessage = (IokeObject)Message.getArg1(message);
                    String name = nameMessage.getName();
                    Object current = IokeObject.as(on, context).perform(context, message, name);
                    Object value = ((Message)IokeObject.data(runtime.succ)).sendTo(runtime.succ, context, current);
                    return ((Message)IokeObject.data(runtime.setValue)).sendTo(runtime.setValue, context, on, nameMessage, value);
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("expects one argument, which is the unevaluated name of the cell to work on. will retrieve the current value of this cell, call 'pred' to that value and then send = to the current receiver with the name and the resulting value.", new NativeMethod("--") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositionalUnevaluated("place")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    IokeObject nameMessage = (IokeObject)Message.getArg1(message);
                    String name = nameMessage.getName();
                    Object current = IokeObject.as(on, context).perform(context, message, name);
                    Object value = ((Message)IokeObject.data(runtime.pred)).sendTo(runtime.pred, context, current);
                    return ((Message)IokeObject.data(runtime.setValue)).sendTo(runtime.setValue, context, on, nameMessage, value);
                }
            }));
    }
}// AssignmentBehavior
