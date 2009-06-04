/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.List;
import java.util.Map;
import java.util.IdentityHashMap;

import ioke.lang.exceptions.ControlFlow;

import com.google.common.collect.MapMaker;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class IokeRegistry {
    private static interface Creator {
        IokeObject create(Object javaObject);
    }
    
    public Runtime runtime;

    private final Map<Object, IokeObject> wrappedObjects = new MapMaker()
        .weakKeys()
        .weakValues()
        .makeMap();

    public IokeRegistry(final Runtime runtime) {
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

        if(!wrappedObjects.containsKey(on)) {
            IokeObject val = runtime.createJavaWrapper(on);
            wrappedObjects.put(on, val);
            return val;
        }

        return wrappedObjects.get(on);
    }

    public IokeObject integratedWrap(Class on) {
        if(on == null) {
            return runtime.nil;
        }
        
        if(!wrappedObjects.containsKey(on)) {
            IokeObject val = runtime.createIntegratedJavaWrapper(on);
            wrappedObjects.put(on, val);
            return val;
        }

        return wrappedObjects.get(on);
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
