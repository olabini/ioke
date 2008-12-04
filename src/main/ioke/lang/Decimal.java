/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.math.BigDecimal;

import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;

import java.util.Locale;
import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;

import ioke.lang.exceptions.ControlFlow;

import gnu.math.RatNum;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Decimal extends IokeData {
    private final static DecimalFormatSymbols SYMBOLS = new DecimalFormatSymbols(Locale.US);
    private final BigDecimal value;

    public Decimal(String textRepresentation) {
        this.value = new BigDecimal(textRepresentation).stripTrailingZeros();
    }

    public Decimal(BigDecimal value) {
        this.value = value;
    }

    public static Decimal decimal(String val) {
        return new Decimal(val);
    }

    public static Decimal decimal(RatNum val) {
        return new Decimal(val.asBigDecimal());
    }

    public static Decimal decimal(BigDecimal val) {
        return new Decimal(val);
    }

    public static BigDecimal value(Object number) {
        return ((Decimal)IokeObject.data(number)).value;
    }

    public String asJavaString() {
        DecimalFormat format = new DecimalFormat("0.0", SYMBOLS);
        format.setMaximumFractionDigits(340);
        return format.format(value);
    }

    @Override
    public String toString() {
        return asJavaString();
    }

    @Override
    public String toString(IokeObject obj) {
        return asJavaString();
    }

    @Override
    public IokeObject convertToDecimal(IokeObject self, IokeObject m, final IokeObject context, boolean signalCondition) throws ControlFlow {
        return self;
    }

    public static String getInspect(Object on) {
        return ((Decimal)(IokeObject.data(on))).inspect(on);
    }

    public String inspect(Object obj) {
        return asJavaString();
    }

    @Override
    public void init(IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;
        final IokeObject decimal = obj;

        decimal.setKind("Number Decimal");
        runtime.decimal = decimal;

        decimal.registerMethod(runtime.newJavaMethod("Returns a text representation of the object", new JavaMethod("asText") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    return runtime.newText(on.toString());
                }
            }));

        decimal.registerMethod(obj.runtime.newJavaMethod("Returns a text inspection of the object", new JavaMethod("inspect") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    return method.runtime.newText(Decimal.getInspect(on));
                }
            }));

        decimal.registerMethod(obj.runtime.newJavaMethod("Returns a brief text inspection of the object", new JavaMethod("notice") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    return method.runtime.newText(Decimal.getInspect(on));
                }
            }));

        decimal.registerMethod(runtime.newJavaMethod("compares this number against the argument, true if this number is the same, otherwise false", new JavaMethod("==") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    DefaultArgumentsDefinition.getEvaluatedArguments(message, context, args, new HashMap<String, Object>());
                    Object arg = args.get(0);
                    if(IokeObject.data(arg) instanceof Number) {
                        return (Decimal.value(on).compareTo(Number.value(arg).asBigDecimal()) == 0) ? context.runtime._true : context.runtime._false;
                    } else if(IokeObject.data(arg) instanceof Decimal) {
                        return (Decimal.value(on).compareTo(Decimal.value(arg)) == 0) ? context.runtime._true : context.runtime._false;
                    } else {
                        return context.runtime._false;
                    }
                }
            }));

        decimal.registerMethod(runtime.newJavaMethod("returns the difference between this number and the argument. if the argument is a rational, it will be converted into a form suitable for subtracting against a decimal, and then subtracted. if the argument is neither a Rational nor a Decimal, it tries to call asDecimal, and if that fails it signals a condition.", new JavaMethod("-") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    DefaultArgumentsDefinition.getEvaluatedArguments(message, context, args, new HashMap<String, Object>());
                    Object arg = args.get(0);

                    IokeData data = IokeObject.data(arg);
                    
                    if(data instanceof Number) {
                        return context.runtime.newDecimal(Decimal.value(on).subtract(Number.value(arg).asBigDecimal()));
                    } else {
                        if(!(data instanceof Decimal)) {
                            arg = IokeObject.convertToDecimal(arg, message, context, true);
                        }

                        return context.runtime.newDecimal(Decimal.value(on).subtract(Decimal.value(arg)));
                    }
                }
            }));

        decimal.registerMethod(runtime.newJavaMethod("returns the sum of this number and the argument. if the argument is a rational, it will be converted into a form suitable for addition against a decimal, and then added. if the argument is neither a Rational nor a Decimal, it tries to call asDecimal, and if that fails it signals a condition.", new JavaMethod("+") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    DefaultArgumentsDefinition.getEvaluatedArguments(message, context, args, new HashMap<String, Object>());
                    Object arg = args.get(0);

                    IokeData data = IokeObject.data(arg);
                    
                    if(data instanceof Number) {
                        return context.runtime.newDecimal(Decimal.value(on).add(Number.value(arg).asBigDecimal()));
                    } else {
                        if(!(data instanceof Decimal)) {
                            arg = IokeObject.convertToDecimal(arg, message, context, true);
                        }

                        return context.runtime.newDecimal(Decimal.value(on).add(Decimal.value(arg)));
                    }
                }
            }));

        decimal.registerMethod(runtime.newJavaMethod("returns the product of this number and the argument. if the argument is a rational, the receiver will be converted into a form suitable for multiplying against a decimal, and then multiplied. if the argument is neither a Rational nor a Decimal, it tries to call asDecimal, and if that fails it signals a condition.", new JavaMethod("*") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    DefaultArgumentsDefinition.getEvaluatedArguments(message, context, args, new HashMap<String, Object>());
                    Object arg = args.get(0);

                    IokeData data = IokeObject.data(arg);
                    
                    if(data instanceof Number) {
                        return context.runtime.newDecimal(Decimal.value(on).multiply(Number.value(arg).asBigDecimal()));
                    } else {
                        if(!(data instanceof Decimal)) {
                            arg = IokeObject.convertToDecimal(arg, message, context, true);
                        }

                        return context.runtime.newDecimal(Decimal.value(on).multiply(Decimal.value(arg)));
                    }
                }
            }));
    }
}// Decimal
