/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.java;

import ioke.lang.IokeObject;
import ioke.lang.JavaImplementedMethod;
import ioke.lang.JavaWrapper;
import ioke.lang.Runtime;
import ioke.lang.Message;
import ioke.lang.Text;
import ioke.lang.Symbol;
import ioke.lang.Number;
import ioke.lang.Decimal;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class JavaInvocationHelper {
    public static boolean hasProxyMethod(IokeJavaIntegrated object, String name) {
        IokeObject pr = object.__get_IokeProxy();
        Runtime runtime = object.__get_IokeRuntime();

        Object cell = IokeObject.findCell(pr, null, null, name);
        if(cell != null && cell != runtime.nul && cell instanceof IokeObject) {
            return !(IokeObject.data(cell) instanceof JavaImplementedMethod);
        }

        return false;
    }

    public static void voidInvocation(IokeJavaIntegrated object, Object[] args, String name) {
        IokeObject pr = object.__get_IokeProxy();
        Runtime runtime = object.__get_IokeRuntime();
        Message newMessage = new Message(runtime, name);
        for(Object arg : args) {
            newMessage.getArguments(null).add(runtime.createMessage(Message.wrap(arg, runtime)));
        }

        try {
            runtime.createMessage(newMessage).sendTo(runtime.ground, pr);
        } catch(Throwable e) {
        }
    }

    public static byte byteInvocation(IokeJavaIntegrated object, Object[] args, String name) {
        IokeObject pr = object.__get_IokeProxy();
        Runtime runtime = object.__get_IokeRuntime();
        Message newMessage = new Message(runtime, name);
        for(Object arg : args) {
            newMessage.getArguments(null).add(runtime.createMessage(Message.wrap(arg, runtime)));
        }

        try {
            Object result = runtime.createMessage(newMessage).sendTo(runtime.ground, pr);
            if(result instanceof Byte) {
                return Byte.valueOf((Byte)result);
            } else if(result instanceof IokeObject && IokeObject.data(result) instanceof JavaWrapper && JavaWrapper.getObject(result) instanceof Byte) {
                return Byte.valueOf((Byte)JavaWrapper.getObject(result));
            } else if(result instanceof IokeObject && IokeObject.data(result) instanceof Number) {
                return Byte.valueOf((byte)Number.intValue(result).intValue());
            }
        } catch(Throwable e) {
            return 0;
        }
        return 0;
    }

    public static int intInvocation(IokeJavaIntegrated object, Object[] args, String name) {
        IokeObject pr = object.__get_IokeProxy();
        Runtime runtime = object.__get_IokeRuntime();
        Message newMessage = new Message(runtime, name);
        for(Object arg : args) {
            newMessage.getArguments(null).add(runtime.createMessage(Message.wrap(arg, runtime)));
        }

        try {
            Object result = runtime.createMessage(newMessage).sendTo(runtime.ground, pr);
            if(result instanceof Integer) {
                return Integer.valueOf((Integer)result);
            } else if(result instanceof IokeObject && IokeObject.data(result) instanceof JavaWrapper && JavaWrapper.getObject(result) instanceof Integer) {
                return Integer.valueOf((Integer)JavaWrapper.getObject(result));
            } else if(result instanceof IokeObject && IokeObject.data(result) instanceof Number) {
                return Integer.valueOf(Number.intValue(result).intValue());
            }
        } catch(Throwable e) {
            return 0;
        }
        return 0;
    }

    public static short shortInvocation(IokeJavaIntegrated object, Object[] args, String name) {
        IokeObject pr = object.__get_IokeProxy();
        Runtime runtime = object.__get_IokeRuntime();
        Message newMessage = new Message(runtime, name);
        for(Object arg : args) {
            newMessage.getArguments(null).add(runtime.createMessage(Message.wrap(arg, runtime)));
        }

        try {
            Object result = runtime.createMessage(newMessage).sendTo(runtime.ground, pr);
            if(result instanceof Short) {
                return Short.valueOf((Short)result);
            } else if(result instanceof IokeObject && IokeObject.data(result) instanceof JavaWrapper && JavaWrapper.getObject(result) instanceof Short) {
                return Short.valueOf((Short)JavaWrapper.getObject(result));
            } else if(result instanceof IokeObject && IokeObject.data(result) instanceof Number) {
                return Short.valueOf((short)Number.intValue(result).intValue());
            }
        } catch(Throwable e) {
            return 0;
        }
        return 0;
    }

    public static char charInvocation(IokeJavaIntegrated object, Object[] args, String name) {
        IokeObject pr = object.__get_IokeProxy();
        Runtime runtime = object.__get_IokeRuntime();
        Message newMessage = new Message(runtime, name);
        for(Object arg : args) {
            newMessage.getArguments(null).add(runtime.createMessage(Message.wrap(arg, runtime)));
        }

        try {
            Object result = runtime.createMessage(newMessage).sendTo(runtime.ground, pr);
            if(result instanceof Character) {
                return Character.valueOf((Character)result);
            } else if(result instanceof IokeObject && IokeObject.data(result) instanceof JavaWrapper && JavaWrapper.getObject(result) instanceof Character) {
                return Character.valueOf((Character)JavaWrapper.getObject(result));
            } else if(result instanceof IokeObject && IokeObject.data(result) instanceof Number) {
                return Character.valueOf((char)Number.intValue(result).intValue());
            }
        } catch(Throwable e) {
            return 0;
        }
        return 0;
    }

    public static boolean booleanInvocation(IokeJavaIntegrated object, Object[] args, String name) {
        IokeObject pr = object.__get_IokeProxy();
        Runtime runtime = object.__get_IokeRuntime();
        Message newMessage = new Message(runtime, name);
        for(Object arg : args) {
            newMessage.getArguments(null).add(runtime.createMessage(Message.wrap(arg, runtime)));
        }

        try {
            Object result = runtime.createMessage(newMessage).sendTo(runtime.ground, pr);
            if(result instanceof Boolean) {
                return Boolean.valueOf((Boolean)result);
            } else if(result instanceof IokeObject && IokeObject.data(result) instanceof JavaWrapper && JavaWrapper.getObject(result) instanceof Boolean) {
                return Boolean.valueOf((Boolean)JavaWrapper.getObject(result));
            } else if(result == runtime._true) {
                return true;
            } else if(result == runtime._false) {
                return false;
            }
        } catch(Throwable e) {
            return false;
        }
        return false;
    }

    public static long longInvocation(IokeJavaIntegrated object, Object[] args, String name) {
        IokeObject pr = object.__get_IokeProxy();
        Runtime runtime = object.__get_IokeRuntime();
        Message newMessage = new Message(runtime, name);
        for(Object arg : args) {
            newMessage.getArguments(null).add(runtime.createMessage(Message.wrap(arg, runtime)));
        }

        try {
            Object result = runtime.createMessage(newMessage).sendTo(runtime.ground, pr);
            if(result instanceof Long) {
                return Long.valueOf((Long)result);
            } else if(result instanceof IokeObject && IokeObject.data(result) instanceof JavaWrapper && JavaWrapper.getObject(result) instanceof Long) {
                return Long.valueOf((Integer)JavaWrapper.getObject(result));
            } else if(result instanceof IokeObject && IokeObject.data(result) instanceof Number) {
                return Long.valueOf(Number.value(result).longValue());
            }
        } catch(Throwable e) {
            return 0;
        }
        return 0;
    }

    public static float floatInvocation(IokeJavaIntegrated object, Object[] args, String name) {
        IokeObject pr = object.__get_IokeProxy();
        Runtime runtime = object.__get_IokeRuntime();
        Message newMessage = new Message(runtime, name);
        for(Object arg : args) {
            newMessage.getArguments(null).add(runtime.createMessage(Message.wrap(arg, runtime)));
        }

        try {
            Object result = runtime.createMessage(newMessage).sendTo(runtime.ground, pr);

            if(result instanceof Float) {
                return Float.valueOf((Float)result);
            } else if(result instanceof IokeObject && IokeObject.data(result) instanceof JavaWrapper && JavaWrapper.getObject(result) instanceof Float) {
                return Float.valueOf((Float)JavaWrapper.getObject(result));
            } else if(result instanceof IokeObject && IokeObject.data(result) instanceof Decimal) {
                return Float.valueOf(Decimal.value(result).floatValue());
            }
        } catch(Throwable e) {
            return 0F;
        }
        return 0F;
    }

    public static double doubleInvocation(IokeJavaIntegrated object, Object[] args, String name) {
        IokeObject pr = object.__get_IokeProxy();
        Runtime runtime = object.__get_IokeRuntime();
        Message newMessage = new Message(runtime, name);
        for(Object arg : args) {
            newMessage.getArguments(null).add(runtime.createMessage(Message.wrap(arg, runtime)));
        }

        try {
            Object result = runtime.createMessage(newMessage).sendTo(runtime.ground, pr);

            if(result instanceof Double) {
                return Double.valueOf((Double)result);
            } else if(result instanceof IokeObject && IokeObject.data(result) instanceof JavaWrapper && JavaWrapper.getObject(result) instanceof Double) {
                return Double.valueOf((Double)JavaWrapper.getObject(result));
            } else if(result instanceof IokeObject && IokeObject.data(result) instanceof Decimal) {
                return Double.valueOf(Decimal.value(result).doubleValue());
            }
        } catch(Throwable e) {
            return 0D;
        }
        return 0D;
    }

    public static Object objectInvocation(IokeJavaIntegrated object, Object[] args, String name, Class expectedType) {
        IokeObject pr = object.__get_IokeProxy();
        Runtime runtime = object.__get_IokeRuntime();
        
        Message newMessage = new Message(runtime, name);
        for(Object arg : args) {
            newMessage.getArguments(null).add(runtime.createMessage(Message.wrap(arg, runtime)));
        }

        try {
            return tryConvertTo(runtime.createMessage(newMessage).sendTo(runtime.ground, pr), expectedType, runtime);
        } catch(Throwable e) {
            return null;
        }
    }

    public static Object tryConvertTo(Object obj, Class expectedType, Runtime runtime) throws ioke.lang.exceptions.ControlFlow {
        Class clz = expectedType;
        boolean isIokeObject = obj instanceof IokeObject;
        boolean isWrapper = isIokeObject && IokeObject.data(obj) instanceof JavaWrapper;
        if(obj == runtime.nil) {
            return null;
        }

        if(clz == String.class) {
            if(obj instanceof String) {
                return obj;
            } else if(isWrapper && JavaWrapper.getObject(obj) instanceof String) {
                return JavaWrapper.getObject(obj);
            } else if(isIokeObject && IokeObject.data(obj) instanceof Text) {
                return Text.getText(obj);
            } else if(isIokeObject &&  IokeObject.data(obj) instanceof Symbol) {
                return Symbol.getText(obj);
            }
        } else if(clz == Character.class) {
            if(obj instanceof Character) {
                return obj;
            } else if(isWrapper && JavaWrapper.getObject(obj) instanceof Character) {
                return JavaWrapper.getObject(obj);
            } else if(isIokeObject && IokeObject.data(obj) instanceof Number) {
                return new Character((char)Number.intValue(obj).intValue());
            }
        } else if(clz == Integer.class) {
            if(obj instanceof Integer) {
                return obj;
            } else if(isWrapper && JavaWrapper.getObject(obj) instanceof Integer) {
                return JavaWrapper.getObject(obj);
            } else if(isIokeObject && IokeObject.data(obj) instanceof Number) {
                return Integer.valueOf(Number.intValue(obj).intValue());
            }
        } else if(clz == Short.class) {
            if(obj instanceof Short) {
                return obj;
            } else if(isWrapper && JavaWrapper.getObject(obj) instanceof Short) {
                return JavaWrapper.getObject(obj);
            } else if(isIokeObject && IokeObject.data(obj) instanceof Number) {
                return Short.valueOf((short)Number.intValue(obj).intValue());
            }
        } else if(clz == Long.class) {
            if(obj instanceof Long) {
                return obj;
            } else if(isWrapper && JavaWrapper.getObject(obj) instanceof Long) {
                return JavaWrapper.getObject(obj);
            } else if(isIokeObject && IokeObject.data(obj) instanceof Number) {
                return Long.valueOf(Number.value(obj).longValue());
            }
        } else if(clz == Float.class) {
            if(obj instanceof Float) {
                return obj;
            } else if(isWrapper && JavaWrapper.getObject(obj) instanceof Float) {
                return JavaWrapper.getObject(obj);
            } else if(isIokeObject && IokeObject.data(obj) instanceof Decimal) {
                return Float.valueOf(Decimal.value(obj).floatValue());
            }
        } else if(clz == Double.class) {
            if(obj instanceof Double) {
                return obj;
            } else if(isWrapper && JavaWrapper.getObject(obj) instanceof Double) {
                return JavaWrapper.getObject(obj);
            } else if(isIokeObject && IokeObject.data(obj) instanceof Decimal) {
                return Double.valueOf(Decimal.value(obj).doubleValue());
            }
        } else if(clz == Boolean.class) {
            if(obj instanceof Boolean) {
                return obj;
            } else if(isWrapper && JavaWrapper.getObject(obj) instanceof Boolean) {
                return JavaWrapper.getObject(obj);
            } else if(obj == runtime._true) {
                return Boolean.TRUE;
            } else if(obj == runtime._false) {
                return Boolean.FALSE;
            }
        } else if(clz == Object.class) {
            // Accept anything
            if(isWrapper) {
                return JavaWrapper.getObject(obj);
            } else {
                return obj;
            }
        } else {
            if(!isIokeObject) {
                return obj;
            } else if(isWrapper) {
                return JavaWrapper.getObject(obj);
            }
        }
        return obj;
    }
}// JavaInvocationHelper
