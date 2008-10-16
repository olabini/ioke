/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Origin extends IokeObject {
    public Origin(Runtime runtime, String documentation) {
        super(runtime, documentation);
    }

    @Override
    public IokeObject allocateCopy(Message m, IokeObject context) {
        return new Origin(runtime, documentation);
    }

    public void init() {
        // asText, asRepresentation
        registerMethod(new JavaMethod(runtime, "println", "Prints a text representation and a newline to standard output") {
                public IokeObject activate(IokeObject context, Message message, IokeObject on) throws ControlFlow {
                    runtime.getOut().println(runtime.asText.sendTo(context, on).toString());
                    runtime.getOut().flush();
                    return runtime.getNil();
                }
            });

        registerMethod(new JavaMethod(runtime, "print", "Prints a text representation to standard output") {
                public IokeObject activate(IokeObject context, Message message, IokeObject on) throws ControlFlow {
                    runtime.getOut().print(runtime.asText.sendTo(context, on).toString());
                    runtime.getOut().flush();
                    return runtime.getNil();
                }
            });
    }

    public String toString() {
        if(this == runtime.origin) {
            return "Origin";
        } else {
            return "#<Origin:" + System.identityHashCode(this) + ">";
        }
    }
}// Origin
