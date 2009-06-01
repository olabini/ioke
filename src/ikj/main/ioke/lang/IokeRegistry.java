/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.List;
import java.util.Map;
import java.util.IdentityHashMap;

import ioke.lang.exceptions.ControlFlow;
import ioke.lang.util.ObjectProxyCache;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class IokeRegistry {
    private static interface Creator {
        IokeObject create(Object javaObject);
    }
    
    public Runtime runtime;
    private Creator regularCreator;
    private Creator integratedCreator;

    private final ObjectProxyCache<IokeObject, Creator> wrappedObjects = 
        new ObjectProxyCache<IokeObject, Creator>(ObjectProxyCache.ReferenceType.WEAK) {

        public IokeObject allocateProxy(Object javaObject, Creator creator) {
            return creator.create(javaObject);
        }
    };

    public IokeRegistry(final Runtime runtime) {
        this.runtime = runtime;
        this.regularCreator = new Creator() {
                public IokeObject create(Object javaObject) {
                    return runtime.createJavaWrapper(javaObject);
                }
            };
        this.integratedCreator = new Creator() {
                public IokeObject create(Object javaObject) {
                    return runtime.createIntegratedJavaWrapper((Class)javaObject);
                }
            };
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
        
        return wrappedObjects.getOrCreate(on, regularCreator);
    }

    public IokeObject integratedWrap(Class on) {
        if(on == null) {
            return runtime.nil;
        }
        
        return wrappedObjects.getOrCreate(on, integratedCreator);
    }

    public boolean isWrapped(Object on) {
        return wrappedObjects.get(on) != null;
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
