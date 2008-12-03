/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.math.BigDecimal;

import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;

import java.util.Locale;

import ioke.lang.exceptions.ControlFlow;

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
                    Object arg = message.getEvaluatedArgument(0, context);
                    return (Decimal.value(on).compareTo(Decimal.value(arg)) == 0) ? context.runtime._true : context.runtime._false;
                }
            }));
    }
}// Decimal
