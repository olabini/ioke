/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Tuple extends IokeData {
    private final Object[] elements;

    public Tuple(Object[] elements) {
        this.elements = elements;
    }

    public static Object[] getElements(Object o) {
        return ((Tuple)IokeObject.data(o)).elements;
    }

    @Override
    public void init(IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;
        obj.setKind("Tuple");
        obj.singleMimicsWithoutCheck(runtime.origin);
        runtime.iokeGround.registerCell("Tuple", obj);

        obj.registerMethod(runtime.newNativeMethod("will modify the tuple, initializing it to contain the specified arguments", new NativeMethod("private:initializeWith") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRest("values")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    Object[] o = new Object[args.size()];
                    IokeObject.as(on, context).setData(new Tuple(args.toArray(o)));

                    return on;
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("returns a new method that can be used to access an element of a tuple based on the index", new NativeMethod("private:accessor") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("index")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());
                    final int index = Number.extractInt(args.get(0), message, context);
                    return runtime.newNativeMethod("Returns the object at index " + index + " in the receiving tuple", new NativeMethod.WithNoArguments("_" + index) {
                            @Override
                            public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                                getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                                return ((Tuple)IokeObject.data(on)).elements[index];
                            }
                        });
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("returns true if the left hand side tuple is equal to the right hand side tuple.", new TypeCheckingNativeMethod("==") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(runtime.tuple)
                    .withRequiredPositional("other")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject self, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());
                    Tuple d = (Tuple)IokeObject.data(on);
                    Object other = args.get(0);
                    boolean notResult = false;
                    if((other instanceof IokeObject) &&
                       (IokeObject.data(other) instanceof Tuple)) {
                        Tuple d2 = (Tuple)IokeObject.data(other);
                        int len = d.elements.length;
                        if(len == d2.elements.length) {
                            for(int i=0; i<len; i++) {
                                if(!d.elements[i].equals(d2.elements[i])) {
                                    notResult = true;
                                    break;
                                }
                            }
                        } else {
                            notResult = true;
                        }
                    } else {
                        notResult = true;
                    }

                    return !notResult ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("Compares this object against the argument. The comparison is only based on the elements inside the tuple, which are in turn compared using <=>.", new TypeCheckingNativeMethod("<=>") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(runtime.tuple)
                    .withRequiredPositional("other")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject self, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    Object arg = args.get(0);
                    Object[] one = ((Tuple)IokeObject.data(on)).elements;
                    Object[] two = ((Tuple)IokeObject.data(arg)).elements;

                    int len = Math.min(one.length, two.length);
                    SpaceshipComparator sc = new SpaceshipComparator(context, message);

                    for(int i = 0; i < len; i++) {
                        int v = sc.compare(one[i], two[i]);
                        if(v != 0) {
                            return context.runtime.newNumber(v);
                        }
                    }

                    len = one.length - two.length;

                    if(len == 0) return context.runtime.newNumber(0);
                    if(len > 0) return context.runtime.newNumber(1);
                    return context.runtime.newNumber(-1);
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("Returns a text inspection of the object", new TypeCheckingNativeMethod.WithNoArguments("inspect", runtime.tuple) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                  return method.runtime.newText(Tuple.getInspect(on));
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("Returns a brief text inspection of the object", new TypeCheckingNativeMethod.WithNoArguments("notice", runtime.tuple) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return method.runtime.newText(Tuple.getNotice(on));
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("Returns the arity of this tuple", new TypeCheckingNativeMethod.WithNoArguments("arity", runtime.tuple) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return method.runtime.newNumber(((Tuple)IokeObject.data(on)).elements.length);
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("Returns the a list representation of this tuple", new TypeCheckingNativeMethod.WithNoArguments("asList", runtime.tuple) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return method.runtime.newList(new ArrayList<Object>(java.util.Arrays.asList(((Tuple)IokeObject.data(on)).elements)));
                }
            }));
    }

    public static String getInspect(Object on) throws ControlFlow {
        return ((Tuple)(IokeObject.data(on))).inspect(on);
    }

    public static String getNotice(Object on) throws ControlFlow {
        return ((Tuple)(IokeObject.data(on))).notice(on);
    }

    public String inspect(Object obj) throws ControlFlow {
        StringBuilder sb = new StringBuilder();
        sb.append("(");
        String sep = "";
        for(Object o : elements) {
            sb.append(sep).append(IokeObject.inspect(o));
            sep = ", ";
        }
        sb.append(")");
        return sb.toString();
    }

    public String notice(Object obj) throws ControlFlow {
        StringBuilder sb = new StringBuilder();
        sb.append("(");
        String sep = "";
        for(Object o : elements) {
            sb.append(sep).append(IokeObject.notice(o));
            sep = ", ";
        }
        sb.append(")");
        return sb.toString();
    }
}
