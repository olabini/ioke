/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.Arrays;
import java.util.Comparator;
import java.util.List;
import java.util.ArrayList;

import java.lang.reflect.Array;
import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.lang.reflect.Member;
import java.lang.reflect.Modifier;

import ioke.lang.exceptions.ControlFlow;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class JavaArgumentsDefinition {
    private Class[][] parameterTypes;
    private Member[] members;
    private int min;
    private int max;
    private boolean special;

    public JavaArgumentsDefinition(Member[] members, Class[][] parameterTypes, int min, int max) {
        this(members, parameterTypes, min, max, false);
    }

    public JavaArgumentsDefinition(Member[] members, Class[][] parameterTypes, int min, int max, boolean special) {
//         System.err.println("creating a new arguments definition: " + Arrays.asList((Object[])members) + "(" + Arrays.asList((Object[])parameterTypes[0]) + ") min=" + min + ", max=" + max);
        this.members = members;
        this.parameterTypes = parameterTypes;
        this.min = min;
        this.max = max;
        this.special = special;
    }

    private static class FullOrdering {
        protected int ordering(Class a, Class b) {
            // There are three choices. The first is when one argument is strictly more specific than the other
            // The second is when the second argument is more specific than the first
            // Third is when there is no real ordering between them

            // Primitive linearization:
            //  rationals:  int < character < long < short < byte
            //  reals:      double < float
            if(a == b) {
                // if they are the same we don't care.
                return 0;
            } else if(a.isPrimitive() && b.isPrimitive()) {
                if(a == Integer.TYPE) {
                    if(b == Short.TYPE || b == Character.TYPE || b == Long.TYPE || b == Byte.TYPE) {
                        return -1;
                    }
                } else if(a == Short.TYPE) {
                    if(b == Long.TYPE || b == Integer.TYPE || b == Character.TYPE) {
                        return 1;
                    } else if(b == Byte.TYPE) {
                        return -1;
                    }
                } else if(a == Byte.TYPE) {
                    if(b == Short.TYPE || b == Long.TYPE || b == Integer.TYPE || b == Character.TYPE) {
                        return 1;
                    }
                } else if(a == Character.TYPE) {
                    if(b == Long.TYPE || b == Short.TYPE || b == Byte.TYPE) {
                        return -1;
                    } else if(b == Integer.TYPE) {
                        return 1;
                    }
                } else if(a == Long.TYPE) {
                    if(b == Short.TYPE || b == Byte.TYPE) {
                        return -1;
                    } else if(b == Integer.TYPE || b == Character.TYPE) {
                        return 1;
                    }
                } else if(a == Float.TYPE) {
                    if(b == Double.TYPE) {
                        return 1;
                    }
                } else if(a == Double.TYPE) {
                    if(b == Float.TYPE) {
                        return -1;
                    }
                }
            } else if(b.isAssignableFrom(a)) {
                return -1;
            } else if(a.isAssignableFrom(b)) {
                return 1;
            } else if(a.isPrimitive()) {
                return -1;
            } else if(b.isPrimitive()) {
                return 1;
            }
            return 0;
        }
    }

    private static class MethodComparator extends FullOrdering implements Comparator<Method> {
        public int compare(Method a, Method b) {
            Class<?>[] aTypes = a.getParameterTypes();
            Class<?>[] bTypes = b.getParameterTypes();
            // Shorter argument lists should be tried first
            if(aTypes.length != bTypes.length) {
                return aTypes.length - bTypes.length;
            }

            // Comparison of each parameter in turn. The first one to be different will decide the full ordering

            for(int i=0,j=aTypes.length; i<j; i++) {
                int ret = ordering(aTypes[i], bTypes[i]);
                if(ret != 0) {
                    return ret;
                }
            }
            return 0;
        }
    }

    private static class ConstructorComparator extends FullOrdering implements Comparator<Constructor> {
        public int compare(Constructor a, Constructor b) {
            Class<?>[] aTypes = a.getParameterTypes();
            Class<?>[] bTypes = b.getParameterTypes();
            // Shorter argument lists should be tried first
            if(aTypes.length != bTypes.length) {
                return aTypes.length - bTypes.length;
            }

            // Comparison of each parameter in turn. The first one to be different will decide the full ordering

            for(int i=0,j=aTypes.length; i<j; i++) {
                int ret = ordering(aTypes[i], bTypes[i]);
                if(ret != 0) {
                    return ret;
                }
            }
            return 0;
        }
    }

    private static void sortByParameterOrdering(Method[] m) {
//         System.err.println("Before sort: ");
//         for(Method mex : m) {
//             System.err.println(" - " + mex);
//         }
        Arrays.sort(m, new MethodComparator());
//         System.err.println("After sort: ");
//         for(Method mex : m) {
//             System.err.println(" - " + mex);
//         }
    }

    private static void sortByParameterOrdering(Constructor[] m) {
//         System.err.println("Before sort: ");
//         for(Constructor mex : m) {
//             System.err.println(" - " + mex);
//         }
        Arrays.sort(m, new ConstructorComparator());
//         System.err.println("After sort: ");
//         for(Constructor mex : m) {
//             System.err.println(" - " + mex);
//         }
    }

    public static JavaArgumentsDefinition createFrom(Method[] m) {
        sortByParameterOrdering(m);
        Class[][] params = new Class[m.length][];
        int ix = 0;
        int min = -1;
        int max = -1;
        for(Method ms : m) {
            params[ix++] = ms.getParameterTypes();
            int num = params[ix-1].length;
            if(min == -1 || num < min) {
                min = num;
            }
            if(max == -1 || num > max) {
                max = num;
            }
        }

        return new JavaArgumentsDefinition(m, params, min, max);
    }

    public static JavaArgumentsDefinition createFrom(Constructor[] m, boolean special) {
        sortByParameterOrdering(m);
        Class[][] params = new Class[m.length][];
        int ix = 0;
        int min = -1;
        int max = -1;
        for(Constructor ms : m) {
            params[ix++] = ms.getParameterTypes();
            int num = params[ix-1].length;
            if(min == -1 || num < min) {
                min = num;
            }
            if(max == -1 || num > max) {
                max = num;
            }
        }

        return new JavaArgumentsDefinition(m, params, min, max, special);
    }

    public static JavaArgumentsDefinition createFrom(Field f) {
        Class[][] params = new Class[1][0];
        params[0] = new Class[]{f.getType()};

        return new JavaArgumentsDefinition(new Field[]{f}, params, 1, 1);
    }

    private static class JavaArgumentDefinition {
        public final Class type;
        public final Class altType;
        public final Object obj;
        public final boolean associatedCode;

        public JavaArgumentDefinition(Class type, Class altType, Object obj) {
            this(type, altType, obj, false);
        }

        public JavaArgumentDefinition(Class type, Class altType, Object obj, boolean associatedCode) {
            this.type = type;
            this.altType = altType;
            this.obj = obj;
            this.associatedCode = associatedCode;
        }

        @Override
        public String toString() {
            return "<JavaArgument type=" + type + ", alt=" + altType + ">";
        }
    }


    public Member getJavaArguments(IokeObject context, IokeObject message, Object on, List<Object> args) throws ControlFlow {
        final Runtime runtime = context.runtime;
        final List<Object> arguments = message.getArguments();
        final List<JavaArgumentDefinition> resultArguments = new ArrayList<JavaArgumentDefinition>(arguments.size());
        int argCount = 0;

        for(Object o : arguments) {
            if(Message.isKeyword(o)) {
                // ignore for now
            } else if(Message.hasName(o, "*") && IokeObject.as(o, context).getArguments().size() == 1) { // Splat
                Object result = Message.getEvaluatedArgument(IokeObject.as(o, context).getArguments().get(0), context);
                if(IokeObject.data(result) instanceof IokeList) {
                    List<Object> elements = IokeList.getList(result);
                    for(Object oe : elements) {
                        resultArguments.add(new JavaArgumentDefinition(null, null, oe));
                    }
                    argCount += elements.size();
                } else if(IokeObject.data(result) instanceof Dict) {
                    // Ignore for now
                } else {
                    final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition,
                                                                                       message,
                                                                                       context,
                                                                                       "Error",
                                                                                       "Invocation",
                                                                                       "NotSpreadable"), context).mimic(message, context);
                    condition.setCell("message", message);
                    condition.setCell("context", context);
                    condition.setCell("receiver", on);
                    condition.setCell("given", result);

                    List<Object> outp = IokeList.getList(runtime.withRestartReturningArguments(new RunnableWithControlFlow() {
                            public void run() throws ControlFlow {
                                runtime.errorCondition(condition);
                            }},
                            context,
                            new Restart.DefaultValuesGivingRestart("ignoreArgument", runtime.nil, 0),
                            new Restart.DefaultValuesGivingRestart("takeArgumentAsIs", IokeObject.as(result, context), 1)
                            ));

                    for(Object oe : outp) {
                        resultArguments.add(new JavaArgumentDefinition(null, null, oe));
                    }
                    argCount += outp.size();
                }
            } else if(Message.hasName(o, "") && IokeObject.as(o, context).getArguments().size() == 1) {
                Object m = IokeObject.as(o, context).getArguments().get(0);
                String name = Message.name(m).intern();
                Object result = Message.getEvaluatedArgument(Message.next(o), context);
                Class into = null;
                Class alt = null;
                // TODO: make these handle native arrays too
                if(name == "Object") {
                    into = Object.class;
                } else if(name == "String") {
                    into = String.class;
                } else if(name == "Class") {
                    into = Class.class;
                } else if(name == "int" || name == "integer") {
                    into = Integer.TYPE;
                    alt = Integer.class;
                } else if(name == "short") {
                    into = Short.TYPE;
                    alt = Short.class;
                } else if(name == "byte") {
                    into = Byte.TYPE;
                    alt = Byte.class;
                } else if(name == "boolean") {
                    into = Boolean.TYPE;
                    alt = Boolean.class;
                } else if(name == "char" || name == "character") {
                    into = Character.TYPE;
                    alt = Character.class;
                } else if(name == "long") {
                    into = Long.TYPE;
                    alt = Long.class;
                } else if(name == "float") {
                    into = Float.TYPE;
                    alt = Float.class;
                } else if(name == "double") {
                    into = Double.TYPE;
                    alt = Double.class;
                } else {
                    String s = name.replaceAll(":", ".");
                    try {
                        into = Class.forName(s, true, context.runtime.classRegistry.getClassLoader());
                    } catch(Exception e) {
                        into = null;
                    }
                }

                if(into != null) {
                    int dimensions = 0;
                    IokeObject next = Message.next(m);
                    while(next != null && next.getName().equals("[]")) {
                        dimensions++;
                        next = Message.next(next);
                    }
                    if(dimensions > 0) {
                        int[] ds = new int[dimensions];
                        into = Array.newInstance(into, ds).getClass();
                        alt = null;
                    }
                }

                resultArguments.add(new JavaArgumentDefinition(into, alt, result));
                argCount++;
            } else {
                Object val = Message.getEvaluatedArgument(o, context);
                JavaArgumentDefinition jarg = new JavaArgumentDefinition(null, null, val, val instanceof IokeObject && IokeObject.data(val) instanceof AssociatedCode);
                resultArguments.add(jarg);
                argCount++;
            }
        }

        int i = 0;
        if(special) {
            argCount++;
        }

        nextMethod: for(int j=parameterTypes.length; i<j; i++) {
            // Totally ignore varargs for now, right...
            if(parameterTypes[i].length == argCount) {
                Class[] current = parameterTypes[i];
                //                System.err.println("checking: " + members[i]);
                for(int kpar = (special ? 1 : 0), karg = 0; kpar<argCount; kpar++, karg++) {
                    Class clz = current[kpar];
                    JavaArgumentDefinition jad = resultArguments.get(karg);
                    Object obj = jad.obj;
                    boolean isIokeObject = obj instanceof IokeObject;
                    boolean isWrapper = isIokeObject && IokeObject.data(obj) instanceof JavaWrapper;
                    boolean isExplicitCast = jad.type != null;
                    boolean clzIsAbstract = Modifier.isAbstract(clz.getModifiers()) || clz.isInterface();
                    if(isExplicitCast && !(clz == jad.type || clz == jad.altType)) {
                        args.clear();
                        continue nextMethod;
                    }
                    if(clz == String.class) {
                        if(obj instanceof String) {
                            args.add(obj);
                        } else if(isWrapper && JavaWrapper.getObject(obj) instanceof String) {
                            args.add(JavaWrapper.getObject(obj));
                        } else if(isIokeObject && IokeObject.data(obj) instanceof Text) {
                            args.add(Text.getText(obj));
                        } else if(isIokeObject &&  IokeObject.data(obj) instanceof Symbol) {
                            args.add(Symbol.getText(obj));
                        } else if(obj == runtime.nil) {
                            args.add(null);
                        } else {
                            args.clear();
                            continue nextMethod;
                        }
                    } else if(clz == Character.class || clz == Character.TYPE) {
                        if(obj instanceof Character) {
                            args.add(obj);
                        } else if(isWrapper && JavaWrapper.getObject(obj) instanceof Character) {
                            args.add(JavaWrapper.getObject(obj));
                        } else if(isIokeObject && IokeObject.data(obj) instanceof Number) {
                            args.add(new Character((char)Number.intValue(obj).intValue()));
                        } else if(isIokeObject && IokeObject.data(obj) instanceof Text && Text.getText(obj).length() == 1) {
                            args.add(new Character(Text.getText(obj).charAt(0)));
                        } else if(!clz.isPrimitive() && obj == runtime.nil) {
                            args.add(null);
                        } else {
                            args.clear();
                            continue nextMethod;
                        }
                    } else if(clz == Integer.class || clz == Integer.TYPE) {
                        // This should take into account widening and stuff like that later
                        if(obj instanceof Integer) {
                            args.add(obj);
                        } else if(isWrapper && JavaWrapper.getObject(obj) instanceof Integer) {
                            args.add(JavaWrapper.getObject(obj));
                        } else if(isIokeObject && IokeObject.data(obj) instanceof Number) {
                            args.add(Integer.valueOf(Number.intValue(obj).intValue()));
                        } else if(!clz.isPrimitive() && obj == runtime.nil) {
                            args.add(null);
                        } else {
                            args.clear();
                            continue nextMethod;
                        }
                    } else if(clz == Short.class || clz == Short.TYPE) {
                        // This should take into account widening and stuff like that later
                        if(obj instanceof Short) {
                            args.add(obj);
                        } else if(isWrapper && JavaWrapper.getObject(obj) instanceof Short) {
                            args.add(JavaWrapper.getObject(obj));
                        } else if(isIokeObject && IokeObject.data(obj) instanceof Number) {
                            args.add(Short.valueOf((short)Number.intValue(obj).intValue()));
                        } else if(!clz.isPrimitive() && obj == runtime.nil) {
                            args.add(null);
                        } else {
                            args.clear();
                            continue nextMethod;
                        }
                    } else if(clz == Byte.class || clz == Byte.TYPE) {
                        // This should take into account widening and stuff like that later
                        if(obj instanceof Byte) {
                            args.add(obj);
                        } else if(isWrapper && JavaWrapper.getObject(obj) instanceof Byte) {
                            args.add(JavaWrapper.getObject(obj));
                        } else if(isIokeObject && IokeObject.data(obj) instanceof Number) {
                            args.add(Byte.valueOf((byte)Number.intValue(obj).intValue()));
                        } else if(!clz.isPrimitive() && obj == runtime.nil) {
                            args.add(null);
                        } else {
                            args.clear();
                            continue nextMethod;
                        }
                    } else if(clz == Long.class || clz == Long.TYPE) {
                        // This should take into account widening and stuff like that later
                        if(obj instanceof Long) {
                            args.add(obj);
                        } else if(isWrapper && JavaWrapper.getObject(obj) instanceof Long) {
                            args.add(JavaWrapper.getObject(obj));
                        } else if(isIokeObject && IokeObject.data(obj) instanceof Number) {
                            args.add(Long.valueOf(Number.value(obj).longValue()));
                        } else if(!clz.isPrimitive() && obj == runtime.nil) {
                            args.add(null);
                        } else {
                            args.clear();
                            continue nextMethod;
                        }
                    } else if(clz == Float.class || clz == Float.TYPE) {
                        // This should take into account widening and stuff like that later
                        if(obj instanceof Float) {
                            args.add(obj);
                        } else if(isWrapper && JavaWrapper.getObject(obj) instanceof Float) {
                            args.add(JavaWrapper.getObject(obj));
                        } else if(isIokeObject && IokeObject.data(obj) instanceof Decimal) {
                            args.add(Float.valueOf(Decimal.value(obj).floatValue()));
                        } else if(isExplicitCast && IokeObject.data(obj) instanceof Number) {
                            args.add(Float.valueOf(Number.value(obj).intValue()));
                        } else if(!clz.isPrimitive() && obj == runtime.nil) {
                            args.add(null);
                        } else {
                            args.clear();
                            continue nextMethod;
                        }
                    } else if(clz == Double.class || clz == Double.TYPE) {
                        // This should take into account widening and stuff like that later
                        if(obj instanceof Double) {
                            args.add(obj);
                        } else if(isWrapper && JavaWrapper.getObject(obj) instanceof Double) {
                            args.add(JavaWrapper.getObject(obj));
                        } else if(isIokeObject && IokeObject.data(obj) instanceof Decimal) {
                            args.add(Double.valueOf(Decimal.value(obj).doubleValue()));
                        } else if(isExplicitCast && IokeObject.data(obj) instanceof Number) {
                            args.add(Double.valueOf(Number.value(obj).longValue()));
                        } else if(!clz.isPrimitive() && obj == runtime.nil) {
                            args.add(null);
                        } else {
                            args.clear();
                            continue nextMethod;
                        }
                    } else if(clz == Boolean.class || clz == Boolean.TYPE) {
                        if(obj instanceof Boolean) {
                            args.add(obj);
                        } else if(isWrapper && JavaWrapper.getObject(obj) instanceof Boolean) {
                            args.add(JavaWrapper.getObject(obj));
                        } else if(obj == runtime._true) {
                            args.add(Boolean.TRUE);
                        } else if(obj == runtime._false) {
                            args.add(Boolean.FALSE);
                        } else if(!clz.isPrimitive() && obj == runtime.nil) {
                            args.add(null);
                        } else {
                            args.clear();
                            continue nextMethod;
                        }
                    } else if(clz == IokeObject.class) {
                        if(obj instanceof IokeObject) {
                            args.add(obj);
                        }
                    } else if(clz == Object.class) {
                        // Accept anything
                        if(obj == runtime.nil) {
                            args.add(null);
                        } else {
                            if(isWrapper) {
                                args.add(JavaWrapper.getObject(obj));
                            } else {
                                args.add(obj);
                            }
                        }
                    } else if(clz.isArray()) {
//                         System.err.println(" -- adding the object for: " + members[i]);
//                         System.err.println("  :" + clz);
//                         System.err.println("   " + clz + ".isAssignableFrom(" + obj.getClass() + "): " + clz.isAssignableFrom(obj.getClass()));
//                         System.err.println("   " + obj.getClass() + ".isAssignableFrom(" + clz + "): " + obj.getClass().isAssignableFrom(clz));

                        if(obj == runtime.nil) {
                            args.add(null);
                        } else if(!isIokeObject && (clz.isAssignableFrom(obj.getClass()) || isExplicitCast)) {
                            args.add(obj);
                        } else if(isWrapper && (clz.isAssignableFrom(JavaWrapper.getObject(obj).getClass()) || isExplicitCast)) {
                            args.add(JavaWrapper.getObject(obj));
                        } else {
                            args.clear();
                            continue nextMethod;
                        }
                    } else {
                        // here should probably be more advanced matching later on
                        if(obj == runtime.nil) {
                            args.add(null);
                        } else if(!isIokeObject) {
                            args.add(obj);
                        } else if(isWrapper) {
                            args.add(JavaWrapper.getObject(obj));
                        } else if(jad.associatedCode && clzIsAbstract) {
                            try {
                                Object obj2 = ((Message)IokeObject.data(runtime.coerceIntoJavaCodeMessage)).sendTo(runtime.coerceIntoJavaCodeMessage, context, obj, runtime.registry.wrap(clz), findAbstractMethodNames(clz, context));
                                if(obj2 instanceof IokeObject && IokeObject.data(obj2) instanceof JavaWrapper) {
                                    obj2 = JavaWrapper.getObject(obj2);
                                }
                                args.add(obj2);
                            } catch(ControlFlow e) {
                                args.clear();
                                continue nextMethod;
                            }
                        } else {
                            args.clear();
                            continue nextMethod;
                        }
                    }
                }
                break nextMethod;
            }
        }

        if(i == members.length) {
            final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition,
                                                                               message,
                                                                               context,
                                                                               "Error",
                                                                               "Java",
                                                                               "NoMatch"), context).mimic(message, context);
            condition.setCell("message", message);
            condition.setCell("context", context);
            condition.setCell("receiver", on);

            List<Object> tries = new ArrayList<Object>(members.length);
            for(Object o : members) {
                tries.add(runtime.newText(o.toString()));
            }

            condition.setCell("alternatives", runtime.newList(tries));

            List<Object> argsGiven = new ArrayList<Object>();
            for(JavaArgumentDefinition jad : resultArguments) {
                argsGiven.add(jad.obj);
            }

            condition.setCell("given", runtime.newList(argsGiven));

            runtime.errorCondition(condition);
        }

        if(special) {
            args.add(0, on);
        }

        return members[i];
    }

    public static IokeObject findAbstractMethodNames(Class<?> type, IokeObject context) throws ControlFlow {
        List<Object> names = new ArrayList<Object>();
        for(java.lang.reflect.Method m : type.getMethods()) {
            if(Modifier.isAbstract(m.getModifiers())) {
                names.add(context.runtime.newText(m.getName()));
            }
        }

        return context.runtime.newList(names);
    }
}// JavaArgumentsDefinition
