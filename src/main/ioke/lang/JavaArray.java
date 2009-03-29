/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.lang.reflect.Array;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class JavaArray {
    public static void init(IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;
        obj.setKind("JavaArray");

        obj.registerMethod(runtime.newJavaMethod("returns the length of the array", new JavaMethod.WithNoArguments("length") {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    if(on instanceof IokeObject) {
                        return runtime.newNumber(Array.getLength(JavaWrapper.getObject(on)));
                    } else {
                        return runtime.newNumber(Array.getLength(on));
                    }
                }
            }));
    }
}// JavaArray
