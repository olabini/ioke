/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.Arrays;
import java.util.List;
import java.util.ArrayList;

import java.lang.reflect.Constructor;
import java.lang.reflect.Method;
import java.lang.reflect.Member;

import ioke.lang.exceptions.ControlFlow;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class JavaArgumentsDefinition {
    private Class[][] parameterTypes;
    private Member[] members;
    private int min;
    private int max;
    
    public JavaArgumentsDefinition(Member[] members, Class[][] parameterTypes, int min, int max) {
//         System.err.println("creating a new arguments definition: " + Arrays.asList((Object[])members) + "(" + Arrays.asList((Object[])parameterTypes[0]) + ") min=" + min + ", max=" + max);
        this.members = members;
        this.parameterTypes = parameterTypes;
        this.min = min;
        this.max = max;
    }

    public static JavaArgumentsDefinition createFrom(Method[] m) {
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

    public static JavaArgumentsDefinition createFrom(Constructor[] m) {
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

        return new JavaArgumentsDefinition(m, params, min, max);
    }

    public Member getJavaArguments(IokeObject context, IokeObject message, Object on, List<Object> args) throws ControlFlow {
        final Runtime runtime = context.runtime;
        final List<Object> arguments = message.getArguments();
        final List<Object> resultArguments = new ArrayList(arguments.size());
        int argCount = 0;

        for(Object o : arguments) {
            if(Message.isKeyword(o)) {
                // ignore for now
            } else if(Message.hasName(o, "*") && IokeObject.as(o, context).getArguments().size() == 1) { // Splat
                Object result = Message.getEvaluatedArgument(IokeObject.as(o, context).getArguments().get(0), context);
                if(IokeObject.data(result) instanceof IokeList) {
                    List<Object> elements = IokeList.getList(result);
                    resultArguments.addAll(elements);
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

                    resultArguments.addAll(outp);
                    argCount += outp.size();
                }
            } else {
                resultArguments.add(Message.getEvaluatedArgument(o, context));
                argCount++;
            }
        }

        int i = 0;
        nextMethod: for(int j=parameterTypes.length; i<j; i++) {
            // Totally ignore varargs for now, right...
            if(parameterTypes[i].length == argCount) {
                Class[] current = parameterTypes[i];
//                 System.err.println("checking: " + members[i]);
                for(int k=0; k<argCount; k++) {
                    Class clz = current[k];
                    Object obj = resultArguments.get(k);
                    boolean isIokeObject = obj instanceof IokeObject;
                    boolean isWrapper = isIokeObject && IokeObject.data(obj) instanceof JavaWrapper;

                    if(clz == String.class) {
                        if(obj instanceof String) {
                            args.add(obj);
                        } else if(isWrapper && JavaWrapper.getObject(obj) instanceof String) {
                            args.add(JavaWrapper.getObject(obj));
                        } else if(isIokeObject && IokeObject.data(obj) instanceof Text) {
                            args.add(Text.getText(obj));
                        } else if(isIokeObject &&  IokeObject.data(obj) instanceof Symbol) {
                            args.add(Symbol.getText(obj));
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
                        } else {
                            args.clear();
                            continue nextMethod;
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
                    } else {
                        // here should probably be more advanced matching later on
                        if(obj == runtime.nil) {
                            args.add(null);
                        } else if(!isIokeObject) {
                            args.add(obj);
                        } else if(isWrapper) {
                            args.add(JavaWrapper.getObject(obj));
                        } else {
                            args.clear();
                            continue nextMethod;
                        }
                    }
                }
                break nextMethod;
            }
        }

        // error that no matching method could be found here. wait for specs for this, of course
//         System.err.println("- Running with: " + members[i]);
        return members[i];
    }
}// JavaArgumentsDefinition
