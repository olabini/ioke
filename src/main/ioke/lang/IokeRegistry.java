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
    
    public static void makeWrapped(Object on, IokeObject wrapped, IokeObject context) {
        context.runtime.registry.makeWrapped(on, wrapped);
    }

    private void makeWrapped(Object on, IokeObject wrapped) {
        if(on != null && !(on instanceof Boolean)) {
            wrappedObjects.put(on, wrapped);
        }
    }
    
    public IokeObject wrap(Object on) {
        if(on == null) {
            return runtime.nil;
        } else if(on instanceof Boolean) {
            return ((Boolean)on).booleanValue() ? runtime._true : runtime._false;
        }
        
        IokeObject obj = wrappedObjects.get(on);
        if(obj == null) {
            obj = runtime.createJavaWrapper(on);
            wrappedObjects.put(on, obj);
        }
        return obj;
    }

    public IokeObject integratedWrap(Class on) {
        if(on == null) {
            return runtime.nil;
        }
        
        IokeObject obj = wrappedObjects.get(on);
        if(obj == null) {
            obj = runtime.createIntegratedJavaWrapper(on);
            wrappedObjects.put(on, obj);
        }
        return obj;
    }

    public boolean isWrapped(Object on) {
        return wrappedObjects.containsKey(on);
    }

    public static boolean isWrapped(Object on, IokeObject context) {
        return context.runtime.registry.isWrapped(on);
    }

    public static IokeObject wrap(Object on, IokeObject context) {
        return context.runtime.registry.wrap(on);
    }

    public static IokeObject integratedWrap(Class on, IokeObject context) {
        return context.runtime.registry.integratedWrap(on);
    }
}
