/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.lang.reflect.Constructor;
import java.lang.reflect.Method;
import java.lang.reflect.Field;
import java.lang.reflect.Modifier;

import java.util.ArrayList;
import java.util.List;
import java.util.LinkedList;
import java.util.HashSet;
import java.util.Map;
import java.util.HashMap;

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

    public static Object getObject(Object wrapped) {
        return ((JavaWrapper)IokeObject.data(wrapped)).object;
    }

    public static void setObject(Object wrapped, Object obj) {
        JavaWrapper jw = ((JavaWrapper)IokeObject.data(wrapped));
        jw.object = obj;
        jw.clazz = jw.object.getClass();
        jw.kind = jw.clazz.getName().replaceAll("\\.", ":");
    }

    public static JavaWrapper wrapWithMethods(Class<?> clz, IokeObject obj, Runtime runtime) {
        return wrapWithMethods(clz, obj, runtime, false);
    }

    public IokeData cloneData(IokeObject obj, IokeObject m, IokeObject context) {
        return object == null ? new JavaWrapper() : new JavaWrapper(object);
    }

    public static JavaWrapper wrapWithMethods(Class<?> clz, IokeObject obj, Runtime runtime, boolean special) {
        try {
            String prefix = "";
            if(clz == Class.class) {
                prefix = "class:";
            }

            Map<String, List<Method>> ms = new HashMap<String, List<Method>>();
            for(Method m : clz.getDeclaredMethods()) {
                String name = m.getName();
                List<Method> lm = null;
                if(!ms.containsKey(name)) {
                    lm = new LinkedList<Method>();
                    ms.put(name, lm);
                } else {
                    lm = ms.get(name);
                }
                lm.add(m);
                try {
                    m.setAccessible(true);
                } catch(Exception e) {}
            }

            for(Map.Entry<String, List<Method>> mesl : ms.entrySet()) {
//                 System.err.println("creating method: " + mesl.getKey() + " on: " + clz);
                Object method = runtime.createJavaMethod(mesl.getValue().toArray(new Method[0]));
                String key = mesl.getKey();
                obj.setCell(prefix + key, method);
                if(key.startsWith("get") && key.length() > 3) {
                    char first = Character.toLowerCase(key.charAt(3));
                    obj.setCell(prefix+first+key.substring(4), method);
                } else if(key.startsWith("set") && key.length() > 3) {
                    char first = Character.toLowerCase(key.charAt(3));
                    obj.setCell(prefix+first+key.substring(4) + "=", method);
                } else if(key.startsWith("is") && key.length() > 2) {
                    char first = Character.toLowerCase(key.charAt(2));
                    obj.setCell(prefix+first+key.substring(3) + "?", method);
                }
            }

            for(Field f : clz.getDeclaredFields()) {
                try {
                    f.setAccessible(true);
                } catch(Exception e) {}

                Object getter = runtime.createJavaFieldGetter(f);
                obj.setCell("field:" + f.getName(), getter);

                if(!Modifier.isFinal(f.getModifiers())) {
                    obj.setCell("field:" + f.getName() + "=", runtime.createJavaFieldSetter(f));
                }
            }

            obj.setCell("new", runtime.createJavaMethod(clz.getDeclaredConstructors(), special));
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

        obj.registerMethod(runtime.newJavaMethod("returns the true if the receiver is a class object, false otherwise.", new JavaMethod.WithNoArguments("class?") {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    if(on instanceof IokeObject) {
                        return (((JavaWrapper)IokeObject.data(on)).clazz == Class.class) ? context.runtime._true : context.runtime._false;
                    } else {
                        return (on instanceof Class) ? context.runtime._true : context.runtime._false;
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("calls toString on the receiver and returns it.", new JavaMethod.WithNoArguments("class:toString") {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    if(on instanceof IokeObject) {
                        return ((JavaWrapper)IokeObject.data(on)).object.toString();
                    } else {
                        return on.toString();
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns true if the left hand side is equal to the right hand side. this will use the Java equals method - after unwrapping both the left hand and right hand side.", new JavaMethod("==") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("other")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    Object left = on;
                    Object right = args.get(0);
                    if(left instanceof IokeObject && IokeObject.data(left) instanceof JavaWrapper) {
                        left = getObject(left);
                    }

                    if(right instanceof IokeObject && IokeObject.data(right) instanceof JavaWrapper) {
                        right = getObject(right);
                    }

                    if(left == null) {
                        return right == null ? context.runtime._true : context.runtime._false;
                    }
                    return left.equals(right) ? context.runtime._true : context.runtime._false;
                }
            }));


        obj.registerMethod(runtime.newJavaMethod("returns true if the left hand side is the same instance as the right hand side", new JavaMethod("same?") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("other")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    Object left = on;
                    Object right = args.get(0);
                    if(left instanceof IokeObject && IokeObject.data(left) instanceof JavaWrapper) {
                        left = getObject(left);
                    }

                    if(right instanceof IokeObject && IokeObject.data(right) instanceof JavaWrapper) {
                        right = getObject(right);
                    }

                    return left == right ? context.runtime._true : context.runtime._false;
                }
            }));
    }
}
