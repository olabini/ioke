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

    @Override
    public void init(IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;
        obj.setKind("Tuple");
        obj.mimicsWithoutCheck(runtime.origin);
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
    }
}
