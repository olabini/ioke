/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.math.BigDecimal;

import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;

import gnu.math.BitOps;
import gnu.math.IntNum;
import gnu.math.RatNum;
import gnu.math.IntFraction;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Number extends IokeData {
    private final RatNum value;

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

    public Number(RatNum value) {
        this.value = value;
    }
    
    public static Number integer(String val) {
        return new Number(val);
    }

    public static Number integer(int val) {
        return new Number(val);
    }

    public static Number integer(IntNum val) {
        return new Number(val);
    }

    public static Number ratio(IntFraction val) {
        return new Number(val);
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
        return obj.runtime.newNumber((RatNum)RatNum.neg(Number.value(obj)));
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

    @Override
    public IokeObject convertToRational(IokeObject self, IokeObject m, final IokeObject context, boolean signalCondition) throws ControlFlow {
        return self;
    }

    public static RatNum value(Object number) {
        return ((Number)IokeObject.data(number)).value;
    }

    public static IntNum intValue(Object number) {
        return (IntNum)((Number)IokeObject.data(number)).value;
    }

    public static int extractInt(Object number, IokeObject m, IokeObject context) throws ControlFlow {
        if(!(IokeObject.data(number) instanceof Number)) {
            number = IokeObject.convertToNumber(number, m, context);
        }
        
        return intValue(number).intValue();
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
        final IokeObject number = obj;
        
        obj.setKind("Number");
        obj.mimics(IokeObject.as(runtime.mixins.getCell(null, null, "Comparing")), runtime.nul, runtime.nul);

        IokeObject real = new IokeObject(runtime, "A real number can be either a rational number or a decimal number");
        real.mimicsWithoutCheck(number);
        real.setKind("Number Real");
        number.registerCell("Real", real);

        IokeObject rational = new IokeObject(runtime, "A rational number is either an integer or a ratio");
        rational.mimicsWithoutCheck(real);
        rational.setKind("Number Rational");
        number.registerCell("Rational", rational);

        IokeObject integer = new IokeObject(runtime, "An integral number");
        integer.mimicsWithoutCheck(rational);
        integer.setKind("Number Integer");
        number.registerCell("Integer", integer);
        runtime.integer = integer;

        IokeObject ratio = new IokeObject(runtime, "A ratio of two integral numbers");
        ratio.mimicsWithoutCheck(rational);
        ratio.setKind("Number Ratio");
        number.registerCell("Ratio", ratio);
        runtime.ratio = ratio;

        IokeObject decimal = new IokeObject(runtime, "An exact, unlimited representation of a decimal number", new Decimal(BigDecimal.ZERO));
        decimal.mimicsWithoutCheck(real);
        decimal.init();
        number.registerCell("Decimal", decimal);
        
        rational.registerMethod(runtime.newJavaMethod("compares this number against the argument, returning -1, 0 or 1 based on which one is larger. if the argument is a decimal, the receiver will be converted into a form suitable for comparing against a decimal, and then compared - it's not specified whether this will actually call Decimal#<=> or not. if the argument is neither a Rational nor a Decimal, it tries to call asRational, and if that doesn't work it returns nil.", new JavaMethod("<=>") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    DefaultArgumentsDefinition.getEvaluatedArguments(message, context, args, new HashMap<String, Object>());
                    Object arg = args.get(0);

                    IokeData data = IokeObject.data(arg);
                    
                    if(data instanceof Decimal) {
                        return context.runtime.newNumber(Number.value(on).asBigDecimal().compareTo(Decimal.value(arg)));
                    } else {
                        if(!(data instanceof Number)) {
                            arg = IokeObject.convertToRational(arg, message, context, false);
                            if(!(IokeObject.data(arg) instanceof Number)) {
                                // Can't compare, so bail out
                                return context.runtime.nil;
                            }
                        }

                        return context.runtime.newNumber(IntNum.compare(Number.value(on),Number.value(arg)));
                    }
                }
            }));

        rational.registerMethod(runtime.newJavaMethod("compares this number against the argument, true if this number is the same, otherwise false", new JavaMethod("==") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    if(!(IokeObject.data(arg) instanceof Number)) {
                        arg = IokeObject.convertToNumber(arg, message, context);
                    }
                    return (IntNum.compare(Number.value(on),Number.value(arg)) == 0) ? context.runtime._true : context.runtime._false;
                }
            }));

        rational.registerMethod(runtime.newJavaMethod("returns the difference between this number and the argument", new JavaMethod("-") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    if(!(IokeObject.data(arg) instanceof Number)) {
                        arg = IokeObject.convertToNumber(arg, message, context);
                    }
                    return runtime.newNumber((RatNum)Number.value(on).sub(Number.value(arg)));
                }
            }));

        rational.registerMethod(runtime.newJavaMethod("returns the addition of this number and the argument", new JavaMethod("+") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    if(!(IokeObject.data(arg) instanceof Number)) {
                        arg = IokeObject.convertToNumber(arg, message, context);
                    }
                    return runtime.newNumber(RatNum.add(Number.value(on),Number.value(arg),1));
                }
            }));

        rational.registerMethod(runtime.newJavaMethod("returns the product of this number and the argument", new JavaMethod("*") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    if(!(IokeObject.data(arg) instanceof Number)) {
                        arg = IokeObject.convertToNumber(arg, message, context);
                    }
                    return runtime.newNumber(RatNum.times(Number.value(on),Number.value(arg)));
                }
            }));

        rational.registerMethod(runtime.newJavaMethod("returns the quotient of this number and the argument. if the division is not exact, it will return a Ratio.", new JavaMethod("/") {
                @Override
                public Object activate(IokeObject method, final IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    if(!(IokeObject.data(arg) instanceof Number)) {
                        arg = IokeObject.convertToNumber(arg, message, context);
                    }
                    
                    while(Number.value(arg).isZero()) {
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
                        
                        arg = newCell[0];
                    }

                    return runtime.newNumber(RatNum.divide(Number.value(on),Number.value(arg)));
                }
            }));

        integer.registerMethod(runtime.newJavaMethod("returns the modulo of this number and the argument", new JavaMethod("%") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    if(!(IokeObject.data(arg) instanceof Number)) {
                        arg = IokeObject.convertToNumber(arg, message, context);
                    }
                    return runtime.newNumber(IntNum.modulo(Number.intValue(on),Number.intValue(arg)));
                }
            }));

        rational.registerMethod(runtime.newJavaMethod("returns this number to the power of the argument", new JavaMethod("**") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    if(!(IokeObject.data(arg) instanceof Number)) {
                        arg = IokeObject.convertToNumber(arg, message, context);
                    }
                    return runtime.newNumber((RatNum)Number.value(on).power(Number.intValue(arg)));
                }
            }));


        integer.registerMethod(runtime.newJavaMethod("returns this number bitwise and the argument", new JavaMethod("&") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    if(!(IokeObject.data(arg) instanceof Number)) {
                        arg = IokeObject.convertToNumber(arg, message, context);
                    }
                    return runtime.newNumber(BitOps.and(Number.intValue(on), Number.intValue(arg)));
                }
            }));

        integer.registerMethod(runtime.newJavaMethod("returns this number bitwise or the argument", new JavaMethod("|") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    if(!(IokeObject.data(arg) instanceof Number)) {
                        arg = IokeObject.convertToNumber(arg, message, context);
                    }
                    return runtime.newNumber(BitOps.ior(Number.intValue(on), Number.intValue(arg)));
                }
            }));

        integer.registerMethod(runtime.newJavaMethod("returns this number bitwise xor the argument", new JavaMethod("^") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    if(!(IokeObject.data(arg) instanceof Number)) {
                        arg = IokeObject.convertToNumber(arg, message, context);
                    }
                    return runtime.newNumber(BitOps.xor(Number.intValue(on), Number.intValue(arg)));
                }
            }));

        integer.registerMethod(runtime.newJavaMethod("returns this number left shifted by the argument", new JavaMethod("<<") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    if(!(IokeObject.data(arg) instanceof Number)) {
                        arg = IokeObject.convertToNumber(arg, message, context);
                    }
                    return runtime.newNumber(IntNum.shift(Number.intValue(on), Number.intValue(arg).intValue()));
                }
            }));

        integer.registerMethod(runtime.newJavaMethod("returns this number right shifted by the argument", new JavaMethod(">>") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    if(!(IokeObject.data(arg) instanceof Number)) {
                        arg = IokeObject.convertToNumber(arg, message, context);
                    }
                    return runtime.newNumber(IntNum.shift(Number.intValue(on), -Number.intValue(arg).intValue()));
                }
            }));

        rational.registerMethod(runtime.newJavaMethod("Returns a text representation of the object", new JavaMethod("asText") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    return runtime.newText(on.toString());
                }
            }));

        rational.registerMethod(obj.runtime.newJavaMethod("Returns a text inspection of the object", new JavaMethod("inspect") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    return method.runtime.newText(Number.getInspect(on));
                }
            }));

        rational.registerMethod(obj.runtime.newJavaMethod("Returns a brief text inspection of the object", new JavaMethod("notice") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    return method.runtime.newText(Number.getInspect(on));
                }
            }));

        integer.registerMethod(runtime.newJavaMethod("Returns the successor of this number", new JavaMethod("succ") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    return runtime.newNumber(IntNum.add(Number.intValue(on),IntNum.one()));
                }
            }));

        integer.registerMethod(runtime.newJavaMethod("Returns the predecessor of this number", new JavaMethod("pred") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    return runtime.newNumber(IntNum.sub(Number.intValue(on),IntNum.one()));
                }
            }));

        integer.registerMethod(runtime.newJavaMethod("Expects one or two arguments. If one argument is given, executes it as many times as the value of the receiving number. If two arguments are given, the first will be an unevaluated name that will receive the current loop value on each repitition. the iteration length is limited to the positive maximum of a Java int", new JavaMethod("times") {
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
