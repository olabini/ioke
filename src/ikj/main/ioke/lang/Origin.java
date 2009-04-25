/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.ArrayList;
import java.util.HashMap;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Origin {
    public static void init(IokeObject origin) throws ControlFlow {
        final Runtime runtime = origin.runtime;

        origin.setKind("Origin");

        // asText, asRepresentation
        origin.registerMethod(runtime.newNativeMethod("Prints a text representation and a newline to standard output", new NativeMethod.WithNoArguments("println") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    ((Message)IokeObject.data(runtime.printlnMessage)).sendTo(runtime.printlnMessage, context, ((Message)IokeObject.data(runtime.outMessage)).sendTo(runtime.outMessage, context, runtime.system), on);
                    return runtime.getNil();
                }
            }));

        origin.registerMethod(runtime.newNativeMethod("Prints a text representation to standard output", new NativeMethod.WithNoArguments("print") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    ((Message)IokeObject.data(runtime.printMessage)).sendTo(runtime.printMessage, context, ((Message)IokeObject.data(runtime.outMessage)).sendTo(runtime.outMessage, context, runtime.system), on);
                    return runtime.getNil();
                }
            }));
    }
}// Origin
