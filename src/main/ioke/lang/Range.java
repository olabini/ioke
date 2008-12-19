/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Range extends IokeData {
    private IokeObject from;
    private IokeObject to;
    private boolean inclusive;

    public Range(IokeObject from, IokeObject to, boolean inclusive) {
        this.from = from;
        this.to = to;
        this.inclusive = inclusive;
    }

    public static IokeObject getFrom(Object range) {
        return ((Range)IokeObject.data(range)).getFrom();
    }

    public static IokeObject getTo(Object range) {
        return ((Range)IokeObject.data(range)).getTo();
    }

    public static boolean isInclusive(Object range) {
        return ((Range)IokeObject.data(range)).isInclusive();
    }
    
    public IokeObject getFrom() {
        return from;
    }

    public IokeObject getTo() {
        return to;
    }
    
    public boolean isInclusive() {
        return inclusive;
    }

    @Override
    public void init(IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;

        obj.setKind("Range");
        obj.mimics(IokeObject.as(runtime.mixins.getCell(null, null, "Enumerable")), runtime.nul, runtime.nul);

        obj.registerMethod(runtime.newJavaMethod("will return a new inclusive Range based on the two arguments", new JavaMethod("inclusive") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("from")
                    .withRequiredPositional("to")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    Object from = args.get(0);
                    Object to = args.get(1);
                    return runtime.newRange(IokeObject.as(from), IokeObject.as(to), true);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("will return a new exclusive Range based on the two arguments", new JavaMethod("exclusive") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("from")
                    .withRequiredPositional("to")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    Object from = args.get(0);
                    Object to = args.get(1);
                    return runtime.newRange(IokeObject.as(from), IokeObject.as(to), false);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns true if the receiver is an exclusive range, false otherwise", new JavaMethod.WithNoArguments("exclusive?") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return ((Range)IokeObject.data(on)).inclusive ? context.runtime._false : context.runtime._true;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns true if the receiver is an inclusive range, false otherwise", new JavaMethod.WithNoArguments("inclusive?") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return ((Range)IokeObject.data(on)).inclusive ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns the 'from' part of the range", new JavaMethod.WithNoArguments("from") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return ((Range)IokeObject.data(on)).from;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns the 'to' part of the range", new JavaMethod.WithNoArguments("to") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return ((Range)IokeObject.data(on)).to;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns true if the argument is within the confines of this range. how this comparison is done depends on if the object mimics Comparing. If it does, < and > will be used. If not, all the available entries in this range will be enumerated using 'succ' until either the end or the element we're looking for is found. in that case, comparison is done with '=='", new JavaMethod("===") {
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
                    Object other = args.get(0);

                    IokeObject from = IokeObject.as(((Range)IokeObject.data(on)).from);
                    IokeObject to = IokeObject.as(((Range)IokeObject.data(on)).to);
                    boolean comparing = IokeObject.isMimic(from, IokeObject.as(context.runtime.mixins.getCells().get("Comparing")));
                    boolean inclusive = ((Range)IokeObject.data(on)).inclusive;

                    if(comparing) {
                        if(IokeObject.isTrue(context.runtime.lteMessage.sendTo(context, from, other)) &&
                           ((inclusive &&
                             IokeObject.isTrue(context.runtime.gteMessage.sendTo(context, to, other))) ||
                            IokeObject.isTrue(context.runtime.gtMessage.sendTo(context, to, other)))) {
                            return context.runtime._true;
                        } else {
                            return context.runtime._false;
                        }
                    } else {
                        Object current = from;

                        while(!IokeObject.isTrue(context.runtime.eqMessage.sendTo(context, current, to))) {
                            if(IokeObject.isTrue(context.runtime.eqMessage.sendTo(context, current, other))) {
                                return context.runtime._true;
                            }
                            current = context.runtime.succ.sendTo(context, current);
                        }

                        if(inclusive && IokeObject.isTrue(context.runtime.eqMessage.sendTo(context, to, other))) {
                            return context.runtime._true;
                        }
                        return context.runtime._false;
                    }
                }
            }));
    }
    
    public IokeData cloneData(IokeObject obj, IokeObject m, IokeObject context) {
        return new Range(from, to, inclusive);
    }
}// Range
