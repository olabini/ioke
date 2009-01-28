/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.List;
import java.util.Map;
import java.util.IdentityHashMap;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class IokeRegistry {
    public Runtime runtime;
    private Map<Object, IokeObject> wrappedObjects = new IdentityHashMap<Object, IokeObject>();

    public IokeRegistry(Runtime runtime) {
        this.runtime = runtime;
    }

    public IokeObject wrap(Object on) {
        if(on == null) {
            return runtime.nil;
        }

        if(on instanceof String) {
            return runtime.newText((String)on);
        }
        
        IokeObject obj = wrappedObjects.get(on);
        if(obj == null) {
            obj = runtime.createJavaWrapper(on);
            wrappedObjects.put(on, obj);
        }
        return obj;
    }

    public static IokeObject wrap(Object on, IokeObject context) {
        return context.runtime.registry.wrap(on);
    }
}
