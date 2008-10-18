/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.mixins;

import ioke.lang.Runtime;
import ioke.lang.IokeObject;
import ioke.lang.JavaMethod;
import ioke.lang.Context;
import ioke.lang.Number;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Comparing {
    public static void init(IokeObject comparing) {
        Runtime runtime = comparing.runtime;
        comparing.setKind("Comparing");
        comparing.registerMethod(runtime.newJavaMethod("return true if the receiver is less than the argument, otherwise false", new JavaMethod("<") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    Number num = (Number)IokeObject.convertToNumber(context.runtime.spaceShip.sendTo(context, on, arg), message, context).data;
                    return (num.asJavaInteger() < 0 ? context.runtime._true : context.runtime._false);
                }
            }));

        comparing.registerMethod(runtime.newJavaMethod("return true if the receiver is less than or equal to the argument, otherwise false", new JavaMethod("<=") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    Number num = (Number)IokeObject.convertToNumber(context.runtime.spaceShip.sendTo(context, on, arg), message, context).data;
                    return (num.asJavaInteger() <= 0 ? context.runtime._true : context.runtime._false);
                }
            }));

        comparing.registerMethod(runtime.newJavaMethod("return true if the receiver is greater than the argument, otherwise false", new JavaMethod(">") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    Number num = (Number)IokeObject.convertToNumber(context.runtime.spaceShip.sendTo(context, on, arg), message, context).data;
                    return (num.asJavaInteger() > 0 ? context.runtime._true : context.runtime._false);
                }
            }));

        comparing.registerMethod(runtime.newJavaMethod("return true if the receiver is greater than or equal to the argument, otherwise false", new JavaMethod(">=") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    Number num = (Number)IokeObject.convertToNumber(context.runtime.spaceShip.sendTo(context, on, arg), message, context).data;
                    return (num.asJavaInteger() >= 0 ? context.runtime._true : context.runtime._false);
                }
            }));

        comparing.registerMethod(runtime.newJavaMethod("return true if the receiver is equal to the argument, otherwise false", new JavaMethod("==") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    Number num = (Number)IokeObject.convertToNumber(context.runtime.spaceShip.sendTo(context, on, arg), message, context).data;
                    return (num.asJavaInteger() == 0 ? context.runtime._true : context.runtime._false);
                }
            }));

        comparing.registerMethod(runtime.newJavaMethod("return true if the receiver is not equal to the argument, otherwise false", new JavaMethod("!=") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    Number num = (Number)IokeObject.convertToNumber(context.runtime.spaceShip.sendTo(context, on, arg), message, context).data;
                    return (num.asJavaInteger() != 0 ? context.runtime._true : context.runtime._false);
                }
            }));
    }
}// Comparing
