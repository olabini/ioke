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
    public static class AssignmentOp extends NativeMethod {
        private final String argName;
        private final IokeObject opmsg;
        private final DefaultArgumentsDefinition ARGUMENTS;
        public AssignmentOp(String name, String argName, IokeObject opmsg) {
            super(name);
            this.argName = argName;
            this.opmsg = opmsg;
            this.ARGUMENTS = DefaultArgumentsDefinition
                .builder()
                .withRequiredPositionalUnevaluated("place")
                .withRequiredPositional(argName)
                .getArguments();
        }

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
                Object result = Interpreter.send(opmsg, context, val, Message.getArg2(message));
                return Interpreter.send(context.runtime.setValue, context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result, context))));
            } else {
                Object val = Interpreter.send(m1, context, on);
                Object result = Interpreter.send(opmsg, context, val, Message.getArg2(message));
                return Interpreter.send(context.runtime.setValue, context, on, m1, context.runtime.createMessage(Message.wrap(IokeObject.as(result, context))));
            }
        }
    }
    
    private static void registerAssignmentOp(IokeObject obj, String name, String argName, IokeObject opmsg, String dok) throws ControlFlow {
        obj.registerMethod(opmsg.runtime.newNativeMethod(dok, new AssignmentOp(name, argName, opmsg)));
    }

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
                        Object val = IokeObject.findCell(IokeObject.as(on, context), name);
                        if(val == context.runtime.nul || !IokeObject.isTrue(val)) {
                            return Interpreter.send(context.runtime.setValue, context, on, m1, Message.getArg2(message));
                        } else {
                            return val;
                        }
                    } else {
                        Object val = Interpreter.send(m1, context, on);
                        if(val == context.runtime.nul || !IokeObject.isTrue(val)) {
                            return Interpreter.send(context.runtime.setValue, context, on, m1, Message.getArg2(message));
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
                        Object val = IokeObject.findCell(IokeObject.as(on, context), name);
                        if(val == context.runtime.nul || !IokeObject.isTrue(val)) {
                            return val;
                        } else {
                            return Interpreter.send(context.runtime.setValue, context, on, m1, Message.getArg2(message));
                        }
                    } else {
                        Object val = Interpreter.send(m1, context, on);
                        if(val == context.runtime.nul || !IokeObject.isTrue(val)) {
                            return val;
                        } else {
                            return Interpreter.send(context.runtime.setValue, context, on, m1, Message.getArg2(message));
                        }
                    }
                }
            }));


        registerAssignmentOp(obj, "+=", "addend", runtime.plusMessage, "expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the + method will be called on it. finally, the result of the call to + will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.");

        registerAssignmentOp(obj, "-=", "subtrahend", runtime.minusMessage, "expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the - method will be called on it. finally, the result of the call to - will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.");

        registerAssignmentOp(obj, "*=", "multiplier", runtime.multMessage, "expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the * method will be called on it. finally, the result of the call to * will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.");

        registerAssignmentOp(obj, "/=", "divisor", runtime.divMessage, "expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the / method will be called on it. finally, the result of the call to / will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.");

        registerAssignmentOp(obj, "%=", "divisor", runtime.modMessage, "expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the % method will be called on it. finally, the result of the call to % will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.");

        registerAssignmentOp(obj, "**=", "exponent", runtime.expMessage, "expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the ** method will be called on it. finally, the result of the call to ** will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.");

        registerAssignmentOp(obj, "&=", "other", runtime.binAndMessage, "expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the & method will be called on it. finally, the result of the call to & will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.");

        registerAssignmentOp(obj, "|=", "other", runtime.binOrMessage, "expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the | method will be called on it. finally, the result of the call to | will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.");

        registerAssignmentOp(obj, "^=", "other", runtime.binXorMessage, "expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the ^ method will be called on it. finally, the result of the call to ^ will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.");

        registerAssignmentOp(obj, "<<=", "other", runtime.lshMessage, "expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the << method will be called on it. finally, the result of the call to << will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.");

        registerAssignmentOp(obj, ">>=", "other", runtime.rshMessage, "expects two arguments, the first unevaluated, the second evaluated. the first argument should be the name of a cell. the value of that cell will be retreived and then the >> method will be called on it. finally, the result of the call to >> will be assigned to the same name in the current scope. it will use = for this assignment. the result of the expression is the same as the result of the assignment. this method also work together with forms such as []=.");

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
                    Object current = Interpreter.perform(on, IokeObject.as(on, context), context, message, name);
                    Object value = Interpreter.send(runtime.succ, context, current);
                    return Interpreter.send(runtime.setValue, context, on, nameMessage, value);
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
                    Object current = Interpreter.perform(on, IokeObject.as(on, context), context, message, name);
                    Object value = Interpreter.send(runtime.pred, context, current);
                    return Interpreter.send(runtime.setValue, context, on, nameMessage, value);
                }
            }));
    }
}// AssignmentBehavior
