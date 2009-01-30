/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.lang.reflect.Constructor;
import java.lang.reflect.Method;

import java.util.List;
import java.util.HashSet;
import java.util.Map;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class JavaWrapper extends IokeData {
    private Object object;
    private String kind;
    private Class clazz;

    public JavaWrapper() {
        this.object = null;
    }

    public JavaWrapper(Object object) {
        this.object = object;
        this.clazz = this.object.getClass();
        this.kind = clazz.getName().replaceAll("\\.", ":");
    }

    public static JavaWrapper wrapWithMethods(Class<?> clz, IokeObject obj, Runtime runtime) {
        try {
            for(Method m : clz.getDeclaredMethods()) {
                if(m.getParameterTypes().length == 0) {
                    //                System.err.println("creating method: " + m.getName() + " on: " + clz);
                    obj.setCell(m.getName(), runtime.createJavaMethod(m));
                }
            }
            for(Constructor c : clz.getDeclaredConstructors()) {
                if(c.getParameterTypes().length == 0) {
                    //                System.err.println("creating method: " + m.getName() + " on: " + clz);
                    obj.setCell("new", runtime.createJavaMethod(c));
                    break;
                }
            }
        } catch(Throwable e) {
            System.err.print("woopsie: ");
            e.printStackTrace();
        }

        return new JavaWrapper(clz);
    }

    public Object getObject() {
        return object;
    }

    @Override
    public void init(final IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;

        obj.registerMethod(runtime.newJavaMethod("returns the kind of this Java object.", new JavaMethod.WithNoArguments("kind") {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    if(on instanceof IokeObject) {
                        return context.runtime.newText(((JavaWrapper)IokeObject.data(on)).kind);
                    } else {
                        return context.runtime.newText(on.getClass().getName().replaceAll("\\.", ":"));
                    }
                }
            }));
    }
}
