/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Call extends IokeData {
    private IokeObject message;

    public Call() {
    }

    public Call(IokeObject message) {
        this.message = message;
    }

    @Override
    public void init(IokeObject obj) {
        final Runtime runtime = obj.runtime;

        obj.setKind("Call");

        obj.registerMethod(runtime.newJavaMethod("returns a list of all the unevaluated arguments", new JavaMethod("arguments") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    return context.runtime.newList(((Call)IokeObject.data(on)).message.getArguments());
                }
            }));

    }

    public IokeData cloneData(IokeObject obj, IokeObject m, IokeObject context) {
        return new Call(this.message);
    }
}// Call
