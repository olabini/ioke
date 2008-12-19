/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.ArrayList;
import java.util.List;
import java.util.Collections;
import java.util.HashMap;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class DateTime extends IokeData {
    private org.joda.time.DateTime dateTime;

    public DateTime() {
        this(new org.joda.time.DateTime());
    }

    public DateTime(org.joda.time.DateTime val) {
        this.dateTime = val;
    }

    public DateTime(long instant) {
        this(new org.joda.time.DateTime(instant));
    }

    public static org.joda.time.DateTime getDateTime(Object on) {
        return ((DateTime)IokeObject.data(on)).dateTime;
    }

    @Override
    public void init(IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;

        obj.setKind("DateTime");
        //        obj.mimics(IokeObject.as(runtime.mixins.getCell(null, null, "Comparing")), runtime.nul, runtime.nul);

        obj.registerMethod(runtime.newJavaMethod("Returns a new DateTime representing the current instant in time in the default TimeZone.", new JavaMethod.WithNoArguments("now") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    return method.runtime.newDateTime(new org.joda.time.DateTime());
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Expects to get one DateTime as argument, and returns the difference between this instant and that instant, in milliseconds.", new JavaMethod("-") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("subtrahend")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    long diff = getDateTime(on).getMillis() - getDateTime(args.get(0)).getMillis();
                    return context.runtime.newNumber(diff);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Returns a text inspection of the object", new JavaMethod.WithNoArguments("inspect") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    return method.runtime.newText(DateTime.getInspect(on));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Returns a brief text inspection of the object", new JavaMethod.WithNoArguments("notice") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    return method.runtime.newText(DateTime.getNotice(on));
                }
            }));
    }

    public IokeData cloneData(IokeObject obj, IokeObject m, IokeObject context) {
        return this;
    }

    public static String getInspect(Object on) throws ControlFlow {
        return ((DateTime)(IokeObject.data(on))).inspect(on);
    }

    public static String getNotice(Object on) throws ControlFlow {
        return ((DateTime)(IokeObject.data(on))).notice(on);
    }

    @Override
    public boolean isEqualTo(IokeObject self, Object other) {
        return ((other instanceof IokeObject) && 
                (IokeObject.data(other) instanceof DateTime) 
                && this.dateTime.equals(((DateTime)IokeObject.data(other)).dateTime));
    }

    @Override
    public String toString() {
        return this.dateTime.toString();
    }

    @Override
    public String toString(IokeObject obj) {
        return this.dateTime.toString();
    }

    public String inspect(Object obj) throws ControlFlow {
        return this.dateTime.toString();
    }

    public String notice(Object obj) throws ControlFlow {
        return this.dateTime.toString();
    }
}// DateTime
