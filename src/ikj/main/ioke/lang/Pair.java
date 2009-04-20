/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.List;
import java.util.Map;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Pair extends IokeData {
    private Object first;
    private Object second;

    public Pair(Object first, Object second) {
        this.first = first;
        this.second = second;
    }

    public static Object getFirst(Object pair) {
        return ((Pair)IokeObject.data(pair)).getFirst();
    }

    public static Object getSecond(Object pair) {
        return ((Pair)IokeObject.data(pair)).getSecond();
    }

    public Object getFirst() {
        return first;
    }

    public Object getSecond() {
        return second;
    }

    @Override
    public void init(IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;

        obj.setKind("Pair");
        obj.mimics(IokeObject.as(runtime.mixins.getCell(null, null, "Enumerable"), null), runtime.nul, runtime.nul);
        obj.mimics(IokeObject.as(runtime.mixins.getCell(null, null, "Comparing"), null), runtime.nul, runtime.nul);

        obj.registerMethod(runtime.newJavaMethod("Returns the first value", new TypeCheckingJavaMethod.WithNoArguments("first", runtime.pair) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return ((Pair)IokeObject.data(on)).first;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Returns the first value", new TypeCheckingJavaMethod.WithNoArguments("key", runtime.pair) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return ((Pair)IokeObject.data(on)).first;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Returns the second value", new TypeCheckingJavaMethod.WithNoArguments("second", runtime.pair) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return ((Pair)IokeObject.data(on)).second;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Returns the second value", new TypeCheckingJavaMethod.WithNoArguments("value", runtime.pair) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return ((Pair)IokeObject.data(on)).second;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Returns a text inspection of the object", new TypeCheckingJavaMethod.WithNoArguments("inspect", runtime.pair) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return method.runtime.newText(Pair.getInspect(on));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Returns a brief text inspection of the object", new TypeCheckingJavaMethod.WithNoArguments("notice", runtime.pair) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return method.runtime.newText(Pair.getNotice(on));
                }
            }));
    }

    public IokeData cloneData(IokeObject obj, IokeObject m, IokeObject context) {
        return new Pair(first, second);
    }


    public static String getInspect(Object on) throws ControlFlow {
        return ((Pair)(IokeObject.data(on))).inspect(on);
    }

    public static String getNotice(Object on) throws ControlFlow {
        return ((Pair)(IokeObject.data(on))).notice(on);
    }

    @Override
    public boolean isEqualTo(IokeObject self, Object other) {
        return ((other instanceof IokeObject) && 
                (IokeObject.data(other) instanceof Pair) 
                && this.first.equals(((Pair)IokeObject.data(other)).first)
                && this.second.equals(((Pair)IokeObject.data(other)).second));
    }

    @Override
    public String toString() {
        return "" + first + " => " + second;
    }

    @Override
    public String toString(IokeObject obj) {
        return "" + first + " => " + second;
    }

    public String inspect(Object obj) throws ControlFlow {
        StringBuilder sb = new StringBuilder();

        sb.append(IokeObject.inspect(first));
        sb.append(" => ");
        sb.append(IokeObject.inspect(second));

        return sb.toString();
    }

    public String notice(Object obj) throws ControlFlow {
        StringBuilder sb = new StringBuilder();

        sb.append(IokeObject.notice(first));
        sb.append(" => ");
        sb.append(IokeObject.notice(second));

        return sb.toString();
    }
}// Pair
