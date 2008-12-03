/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.List;

import gnu.math.BitOps;
import gnu.math.IntNum;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Number extends IokeData {
    private final IntNum value;

    public Number(String textRepresentation) {
        if(textRepresentation.startsWith("0x") || textRepresentation.startsWith("0X")) {
            value = IntNum.valueOf(textRepresentation.substring(2), 16);
        } else {
            value = IntNum.valueOf(textRepresentation);
        }
    }

    public Number(int javaNumber) {
        value = IntNum.make(javaNumber);
    }

    public Number(IntNum value) {
        this.value = value;
    }
    
    public String asJavaString() {
        return value.toString();
    }

    public int asJavaInteger() {
        return value.intValue();
    }

    public long asJavaLong() {
        return value.longValue();
    }

    @Override
    public IokeObject negate(IokeObject obj) {
        return obj.runtime.newNumber(IntNum.sub(IntNum.zero(), Number.value(obj)));
    }

    @Override
    public String toString() {
        return asJavaString();
    }

    @Override
    public String toString(IokeObject obj) {
        return asJavaString();
    }

    public static String getInspect(Object on) {
        return ((Number)(IokeObject.data(on))).inspect(on);
    }

    public String inspect(Object obj) {
        return asJavaString();
    }

    @Override
    public IokeObject convertToNumber(IokeObject self, IokeObject m, IokeObject context) {
        return self;
    }

    public static IntNum value(Object number) {
        return ((Number)IokeObject.data(number)).value;
    }

    public static int extractInt(Object number, IokeObject m, IokeObject context) throws ControlFlow {
        if(!(IokeObject.data(number) instanceof Number)) {
            number = IokeObject.convertToNumber(number, m, context);
        }
        
        return value(number).intValue();
    }

    @Override
    public boolean isEqualTo(IokeObject self, Object other) {
        return ((other instanceof IokeObject) && 
                (IokeObject.data(other) instanceof Number) 
                && this.value.equals(((Number)IokeObject.data(other)).value));
    }

    @Override
    public int hashCode(IokeObject self) {
        return this.value.hashCode();
    }

    @Override
    public void init(IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;

        obj.setKind("Number");
        obj.mimics(IokeObject.as(runtime.mixins.getCell(null, null, "Comparing")), runtime.nul, runtime.nul);
        
        obj.registerMethod(runtime.newJavaMethod("compares this number against the argument, returning -1, 0 or 1 based on which one is larger", new JavaMethod("<=>") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    if(!(IokeObject.data(arg) instanceof Number)) {
                        arg = IokeObject.convertToNumber(arg, message, context);
                    }
                    return runtime.newNumber(IntNum.compare(Number.value(on),Number.value(arg)));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("compares this number against the argument, true if this number is the same, otherwise false", new JavaMethod("==") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    if(!(IokeObject.data(arg) instanceof Number)) {
                        arg = IokeObject.convertToNumber(arg, message, context);
                    }
                    return (IntNum.compare(Number.value(on),Number.value(arg)) == 0) ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns the difference between this number and the argument", new JavaMethod("-") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    if(!(IokeObject.data(arg) instanceof Number)) {
                        arg = IokeObject.convertToNumber(arg, message, context);
                    }
                    return runtime.newNumber(IntNum.sub(Number.value(on),Number.value(arg)));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns the addition of this number and the argument", new JavaMethod("+") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    if(!(IokeObject.data(arg) instanceof Number)) {
                        arg = IokeObject.convertToNumber(arg, message, context);
                    }
                    return runtime.newNumber(IntNum.add(Number.value(on),Number.value(arg)));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns the product of this number and the argument", new JavaMethod("*") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    if(!(IokeObject.data(arg) instanceof Number)) {
                        arg = IokeObject.convertToNumber(arg, message, context);
                    }
                    return runtime.newNumber(IntNum.times(Number.value(on),Number.value(arg)));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns the quotient of this number and the argument", new JavaMethod("/") {
                @Override
                public Object activate(IokeObject method, final IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    if(!(IokeObject.data(arg) instanceof Number)) {
                        arg = IokeObject.convertToNumber(arg, message, context);
                    }
                    IntNum result = new IntNum();
                    boolean retry = false;
                    do {
                        retry = false;
                        try {
                            IntNum.divide(Number.value(on),Number.value(arg),result,null,IntNum.FLOOR);
                        } catch(ArithmeticException e) {
                            final IokeObject condition = IokeObject.as(IokeObject.getCellChain(context.runtime.condition, 
                                                                                               message, 
                                                                                               context, 
                                                                                               "Error", 
                                                                                               "Arithmetic",
                                                                                               "DivisionByZero")).mimic(message, context);
                            condition.setCell("message", message);
                            condition.setCell("context", context);
                            condition.setCell("receiver", on);

                            final Object[] newCell = new Object[]{arg};

                            context.runtime.withRestartReturningArguments(new RunnableWithControlFlow() {
                                    public void run() throws ControlFlow {
                                        context.runtime.errorCondition(condition);
                                    }}, 
                                context,
                                new Restart.ArgumentGivingRestart("useValue") { 
                                    public IokeObject invoke(IokeObject c2, List<Object> arguments) throws ControlFlow {
                                        newCell[0] = arguments.get(0);
                                        return c2.runtime.nil;
                                    }
                                }
                                );

                            retry = true;
                            arg = newCell[0];
                        }
                    } while(retry);

                    return runtime.newNumber(result);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns the modulo of this number and the argument", new JavaMethod("%") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    if(!(IokeObject.data(arg) instanceof Number)) {
                        arg = IokeObject.convertToNumber(arg, message, context);
                    }
                    return runtime.newNumber(IntNum.modulo(Number.value(on),Number.value(arg)));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns this number to the power of the argument", new JavaMethod("**") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    if(!(IokeObject.data(arg) instanceof Number)) {
                        arg = IokeObject.convertToNumber(arg, message, context);
                    }
                    return runtime.newNumber(IntNum.power(Number.value(on), Number.value(arg).intValue()));
                }
            }));


        obj.registerMethod(runtime.newJavaMethod("returns this number bitwise and the argument", new JavaMethod("&") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    if(!(IokeObject.data(arg) instanceof Number)) {
                        arg = IokeObject.convertToNumber(arg, message, context);
                    }
                    return runtime.newNumber(BitOps.and(Number.value(on), Number.value(arg)));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns this number bitwise or the argument", new JavaMethod("|") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    if(!(IokeObject.data(arg) instanceof Number)) {
                        arg = IokeObject.convertToNumber(arg, message, context);
                    }
                    return runtime.newNumber(BitOps.ior(Number.value(on), Number.value(arg)));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns this number bitwise xor the argument", new JavaMethod("^") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    if(!(IokeObject.data(arg) instanceof Number)) {
                        arg = IokeObject.convertToNumber(arg, message, context);
                    }
                    return runtime.newNumber(BitOps.xor(Number.value(on), Number.value(arg)));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns this number left shifted by the argument", new JavaMethod("<<") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    if(!(IokeObject.data(arg) instanceof Number)) {
                        arg = IokeObject.convertToNumber(arg, message, context);
                    }
                    return runtime.newNumber(IntNum.shift(Number.value(on), Number.value(arg).intValue()));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns this number right shifted by the argument", new JavaMethod(">>") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    if(!(IokeObject.data(arg) instanceof Number)) {
                        arg = IokeObject.convertToNumber(arg, message, context);
                    }
                    return runtime.newNumber(IntNum.shift(Number.value(on), -Number.value(arg).intValue()));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Returns a text representation of the object", new JavaMethod("asText") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    return runtime.newText(on.toString());
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("Returns a text inspection of the object", new JavaMethod("inspect") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    return method.runtime.newText(Number.getInspect(on));
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("Returns a brief text inspection of the object", new JavaMethod("notice") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    return method.runtime.newText(Number.getInspect(on));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Returns the successor of this number", new JavaMethod("succ") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    return runtime.newNumber(IntNum.add(Number.value(on),IntNum.one()));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Returns the predecessor of this number", new JavaMethod("pred") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    return runtime.newNumber(IntNum.sub(Number.value(on),IntNum.one()));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Expects one or two arguments. If one argument is given, executes it as many times as the value of the receiving number. If two arguments are given, the first will be an unevaluated name that will receive the current loop value on each repitition. the iteration length is limited to the positive maximum of a Java int", new JavaMethod("times") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    int num = Number.value(on).intValue();
                    switch(message.getArgumentCount()) {
                    case 0:
                        return runtime.nil;
                    case 1: {
                        Object result = runtime.nil;
                        while(num > 0) {
                            result = message.getEvaluatedArgument(0, context);
                            num--;
                        }
                        return result;
                    }
                    default:
                        int ix = 0;
                        String name = ((IokeObject)Message.getArg1(message)).getName();
                        Object result = runtime.nil;
                        while(ix<num) {
                            context.setCell(name, runtime.newNumber(IntNum.make(ix)));
                            result = message.getEvaluatedArgument(1, context);
                            ix++;
                        }
                        return result;
                    }
                }
            }));
    }
}// Number
