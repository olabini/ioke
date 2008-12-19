/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Origin {
    public static void init(IokeObject origin) {
        final Runtime runtime = origin.runtime;

        origin.setKind("Origin");

        // asText, asRepresentation
        origin.registerMethod(runtime.newJavaMethod("Prints a text representation and a newline to standard output", new JavaMethod.WithNoArguments("println") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);
                    runtime.printlnMessage.sendTo(context, runtime.outMessage.sendTo(context, runtime.system), on);
                    return runtime.getNil();
                }
            }));

        origin.registerMethod(runtime.newJavaMethod("Prints a text representation to standard output", new JavaMethod.WithNoArguments("print") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);
                    runtime.printMessage.sendTo(context, runtime.outMessage.sendTo(context, runtime.system), on);
                    return runtime.getNil();
                }
            }));
    }
}// Origin
