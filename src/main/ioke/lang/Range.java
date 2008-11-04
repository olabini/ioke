/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

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
    public void init(IokeObject obj) {
        final Runtime runtime = obj.runtime;

        obj.setKind("Range");
        obj.mimics(IokeObject.as(runtime.mixins.getCell(null, null, "Enumerable")), runtime.nul, runtime.nul);

        obj.registerMethod(runtime.newJavaMethod("will return a new inclusive Range based on the two arguments", new JavaMethod("inclusive") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object from = message.getEvaluatedArgument(0, context);
                    Object to = message.getEvaluatedArgument(1, context);
                    return runtime.newRange(IokeObject.as(from), IokeObject.as(to), true);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("will return a new exclusive Range based on the two arguments", new JavaMethod("exclusive") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object from = message.getEvaluatedArgument(0, context);
                    Object to = message.getEvaluatedArgument(1, context);
                    return runtime.newRange(IokeObject.as(from), IokeObject.as(to), false);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns true if the receiver is an exclusive range, false otherwise", new JavaMethod("exclusive?") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    return ((Range)IokeObject.data(on)).inclusive ? context.runtime._false : context.runtime._true;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns true if the receiver is an inclusive range, false otherwise", new JavaMethod("inclusive?") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    return ((Range)IokeObject.data(on)).inclusive ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns the 'from' part of the range", new JavaMethod("from") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    return ((Range)IokeObject.data(on)).from;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns the 'to' part of the range", new JavaMethod("to") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    return ((Range)IokeObject.data(on)).to;
                }
            }));
    }
    
    public IokeData cloneData(IokeObject obj, IokeObject m, IokeObject context) {
        return new Range(from, to, inclusive);
    }
}// Range
