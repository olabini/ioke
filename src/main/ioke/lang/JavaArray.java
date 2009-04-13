/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.lang.reflect.Array;
import java.lang.reflect.Modifier;

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
        obj.setCell("=", runtime.base.getCells().get("="));
        obj.mimics(IokeObject.as(runtime.mixins.getCell(null, null, "Enumerable"), null), runtime.nul, runtime.nul);

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

        obj.registerMethod(runtime.newJavaMethod("returns the value in the array at the index provided.", new TypeCheckingJavaMethod("[]") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .withRequiredPositional("index")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    Object arg = args.get(0);
                    Object arr = on;

                    if(!(IokeObject.data(arg) instanceof Number)) {
                        arg = IokeObject.convertToNumber(arg, message, context);
                    }
                    int index = ((Number)IokeObject.data(arg)).asJavaInteger();

                    if(arr instanceof IokeObject) {
                        arr = JavaWrapper.getObject(arr);
                    }

                    int size = Array.getLength(arr);

                    if(index < 0) {
                        index = size + index;
                    }

                    if(index >= 0 && index < size) {
                        Object obj = Array.get(arr, index);
                        if(obj == null) {
                            return context.runtime.nil;
                        } else if(obj instanceof Boolean) {
                            return ((Boolean)obj).booleanValue() ? context.runtime._true : context.runtime._false;
                        } else {
                            return obj;
                        }
                    } else {
                        return context.runtime.nil;
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("takes an Ioke list and returns a newly created native array based on the content of that list", new TypeCheckingJavaMethod("from") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .withRequiredPositional("values").whichMustMimic(runtime.list)
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    final Runtime runtime = context.runtime;
                    Class<?> arrClass = (Class<?>)JavaWrapper.getObject(on);
                    Class<?> ctype = arrClass.getComponentType();
                    List<Object> content = IokeList.getList(args.get(0));
                    Object result = Array.newInstance(ctype, content.size());
                    int ix = 0;
                    for(Object obj : content) {
                        setOnArray(runtime, context, message, result, ctype, obj, ix++);
                    }
                    return result;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("takes two arguments, the index of the element to set, and the value to set. the index can be negative and will in that case set indexed from the end of the list.", new TypeCheckingJavaMethod("[]=") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .withRequiredPositional("index")
                    .withRequiredPositional("value")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, final IokeObject context, final IokeObject message) throws ControlFlow {
                    final Runtime runtime = context.runtime;
                    Object arg = args.get(0);
                    Object obj = args.get(1);
                    Object arr = on;
                    if(!(IokeObject.data(arg) instanceof Number)) {
                        arg = IokeObject.convertToNumber(arg, message, context);
                    }
                    int index = ((Number)IokeObject.data(arg)).asJavaInteger();

                    if(arr instanceof IokeObject) {
                        arr = JavaWrapper.getObject(arr);
                    }

                    int size = Array.getLength(arr);

                    if(index < 0) {
                        index = size + index;
                    }

                    Class<?> clz = arr.getClass().getComponentType();
                    setOnArray(runtime, context, message, arr, clz, obj, index);
                    return obj;
                }
            }));
    }

    private static void setOnArray(Runtime runtime, final IokeObject context, final IokeObject message, Object arr, Class<?> clz, Object obj, int index) {
        boolean isIokeObject = obj instanceof IokeObject;
        boolean isWrapper = isIokeObject && IokeObject.data(obj) instanceof JavaWrapper;
        boolean clzIsAbstract = Modifier.isAbstract(clz.getModifiers()) || clz.isInterface();
        //                     System.err.println("called []=(" + index + ", " + obj + ")"); 
        //                     System.err.println("clz: " + clz);
        //                     System.err.println("isIokeObject: " + isIokeObject);
        //                     System.err.println("isWrapper: " + isWrapper);
        //                     System.err.println("clzIsAbstract: " + clzIsAbstract);
        if(clz == String.class) {
            if(obj instanceof String) {
                Array.set(arr, index, obj);
            } else if(isWrapper && JavaWrapper.getObject(obj) instanceof String) {
                Array.set(arr, index, JavaWrapper.getObject(obj));
            } else if(isIokeObject && IokeObject.data(obj) instanceof Text) {
                Array.set(arr, index, Text.getText(obj));
            } else if(isIokeObject &&  IokeObject.data(obj) instanceof Symbol) {
                Array.set(arr, index, Symbol.getText(obj));
            } else if(obj == runtime.nil) {
                Array.set(arr, index, null);
            }
        } else if(clz == Character.class || clz == Character.TYPE) {
            if(obj instanceof Character) {
                Array.set(arr, index, obj);
            } else if(isWrapper && JavaWrapper.getObject(obj) instanceof Character) {
                Array.set(arr, index, JavaWrapper.getObject(obj));
            } else if(isIokeObject && IokeObject.data(obj) instanceof Number) {
                Array.set(arr, index, new Character((char)Number.intValue(obj).intValue()));
            } else if(!clz.isPrimitive() && obj == runtime.nil) {
                Array.set(arr, index, null);
            }
        } else if(clz == Integer.class || clz == Integer.TYPE) {
            if(obj instanceof Integer) {
                Array.set(arr, index, obj);
            } else if(isWrapper && JavaWrapper.getObject(obj) instanceof Integer) {
                Array.set(arr, index, JavaWrapper.getObject(obj));
            } else if(isIokeObject && IokeObject.data(obj) instanceof Number) {
                Array.set(arr, index, Integer.valueOf(Number.intValue(obj).intValue()));
            } else if(!clz.isPrimitive() && obj == runtime.nil) {
                Array.set(arr, index, null);
            }
        } else if(clz == Short.class || clz == Short.TYPE) {
            if(obj instanceof Short) {
                Array.set(arr, index, obj);
            } else if(isWrapper && JavaWrapper.getObject(obj) instanceof Short) {
                Array.set(arr, index, JavaWrapper.getObject(obj));
            } else if(isIokeObject && IokeObject.data(obj) instanceof Number) {
                Array.set(arr, index, Short.valueOf((short)Number.intValue(obj).intValue()));
            } else if(!clz.isPrimitive() && obj == runtime.nil) {
                Array.set(arr, index, null);
            }
        } else if(clz == Byte.class || clz == Byte.TYPE) {
            if(obj instanceof Byte) {
                Array.set(arr, index, obj);
            } else if(isWrapper && JavaWrapper.getObject(obj) instanceof Byte) {
                Array.set(arr, index, JavaWrapper.getObject(obj));
            } else if(isIokeObject && IokeObject.data(obj) instanceof Number) {
                Array.set(arr, index, Byte.valueOf((byte)Number.intValue(obj).intValue()));
            } else if(!clz.isPrimitive() && obj == runtime.nil) {
                Array.set(arr, index, null);
            }
        } else if(clz == Long.class || clz == Long.TYPE) {
            if(obj instanceof Long) {
                Array.set(arr, index, obj);
            } else if(isWrapper && JavaWrapper.getObject(obj) instanceof Long) {
                Array.set(arr, index, JavaWrapper.getObject(obj));
            } else if(isIokeObject && IokeObject.data(obj) instanceof Number) {
                Array.set(arr, index, Long.valueOf(Number.value(obj).longValue()));
            } else if(!clz.isPrimitive() && obj == runtime.nil) {
                Array.set(arr, index, null);
            }
        } else if(clz == Float.class || clz == Float.TYPE) {
            if(obj instanceof Float) {
                Array.set(arr, index, obj);
            } else if(isWrapper && JavaWrapper.getObject(obj) instanceof Float) {
                Array.set(arr, index, JavaWrapper.getObject(obj));
            } else if(isIokeObject && IokeObject.data(obj) instanceof Decimal) {
                Array.set(arr, index, Float.valueOf(Decimal.value(obj).floatValue()));
            } else if(!clz.isPrimitive() && obj == runtime.nil) {
                Array.set(arr, index, null);
            }
        } else if(clz == Double.class || clz == Double.TYPE) {
            if(obj instanceof Double) {
                Array.set(arr, index, obj);
            } else if(isWrapper && JavaWrapper.getObject(obj) instanceof Double) {
                Array.set(arr, index, JavaWrapper.getObject(obj));
            } else if(isIokeObject && IokeObject.data(obj) instanceof Decimal) {
                Array.set(arr, index, Double.valueOf(Decimal.value(obj).doubleValue()));
            } else if(!clz.isPrimitive() && obj == runtime.nil) {
                Array.set(arr, index, null);
            }
        } else if(clz == Boolean.class || clz == Boolean.TYPE) {
            if(obj instanceof Boolean) {
                Array.set(arr, index, obj);
            } else if(isWrapper && JavaWrapper.getObject(obj) instanceof Boolean) {
                Array.set(arr, index, JavaWrapper.getObject(obj));
            } else if(obj == runtime._true) {
                Array.set(arr, index, Boolean.TRUE);
            } else if(obj == runtime._false) {
                Array.set(arr, index, Boolean.FALSE);
            } else if(!clz.isPrimitive() && obj == runtime.nil) {
                Array.set(arr, index, null);
            }
        } else if(clz == Object.class) {
            if(obj == runtime.nil) {
                Array.set(arr, index, null);
            } else {
                if(isWrapper) {
                    Array.set(arr, index, JavaWrapper.getObject(obj));
                } else {
                    Array.set(arr, index, obj);
                }
            }
        } else {
            if(obj == runtime.nil) {
                Array.set(arr, index, null);
            } else if(!isIokeObject) {
                Array.set(arr, index, obj);
            } else if(isWrapper) {
                Array.set(arr, index, JavaWrapper.getObject(obj));
            } else if((obj instanceof IokeObject) && (IokeObject.data(obj) instanceof AssociatedCode) && clzIsAbstract) {
                try {
                    Object obj2 = ((Message)IokeObject.data(runtime.coerceIntoJavaCodeMessage)).sendTo(runtime.coerceIntoJavaCodeMessage, context, obj, runtime.registry.wrap(clz), JavaArgumentsDefinition.findAbstractMethodNames(clz, context));
                    if(obj2 instanceof IokeObject && IokeObject.data(obj2) instanceof JavaWrapper) {
                        obj2 = JavaWrapper.getObject(obj2);
                    }
                    Array.set(arr, index, obj2);
                } catch(ControlFlow e) {
                }
            }
        }
        
    }
}// JavaArray
