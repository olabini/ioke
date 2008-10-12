/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.mixins;

import ioke.lang.Runtime;
import ioke.lang.IokeObject;
import ioke.lang.JavaMethod;
import ioke.lang.Context;
import ioke.lang.Message;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Comparing extends IokeObject {
    public Comparing(Runtime runtime, String documentation) {
        super(runtime, documentation);
    }

    public void init() {
        registerMethod(new JavaMethod(runtime, "<", "return true if the receiver is less than the argument, otherwise false") {
                public IokeObject activate(Context context, Message message, IokeObject on) {
                    IokeObject arg = ((Message)message).getEvaluatedArgument(0, context);
                    return runtime.spaceShip.sendTo(context, on, arg);
                }
            });
    }

    public String toString() {
        return "DefaultBehavior";
    }
}// Comparing
