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
        origin.registerMethod(runtime.newJavaMethod("Prints a text representation and a newline to standard output", new JavaMethod("println") {
                @Override
                public IokeObject activate(IokeObject method, IokeObject context, IokeObject message, IokeObject on) throws ControlFlow {
                    runtime.getOut().println(runtime.asText.sendTo(context, on).toString());
                    runtime.getOut().flush();
                    return runtime.getNil();
                }
            }));

        origin.registerMethod(runtime.newJavaMethod("Prints a text representation to standard output", new JavaMethod("print") {
                @Override
                public IokeObject activate(IokeObject method, IokeObject context, IokeObject message, IokeObject on) throws ControlFlow {
                    runtime.getOut().print(runtime.asText.sendTo(context, on).toString());
                    runtime.getOut().flush();
                    return runtime.getNil();
                }
            }));
    }
}// Origin
