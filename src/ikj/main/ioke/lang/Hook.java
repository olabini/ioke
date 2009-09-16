/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Hook extends IokeData {
    private List<IokeObject> connected;

    public Hook(List<IokeObject> connected) {
        this.connected = connected;
    }

    public static void init(final Runtime runtime) throws ControlFlow {
        final IokeObject obj = new IokeObject(runtime, "A hook allow you to observe what happens to a specific object. All hooks have Hook in their mimic chain.", new Hook(new ArrayList<IokeObject>()));
        obj.setKind("Hook");
        obj.mimicsWithoutCheck(runtime.origin);
        runtime.iokeGround.registerCell("Hook", obj);

        obj.registerMethod(runtime.newNativeMethod("Takes one or more arguments to hook into and returns a new Hook connected to them.", new NativeMethod("into") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("firstConnected")
                    .withRest("restConnected")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());
                    IokeObject hook = obj.allocateCopy(context, message);
                    hook.mimicsWithoutCheck(obj);

                    List<IokeObject> objs = new ArrayList<IokeObject>(args.size());
                    for(Object o : args) {
                        objs.add(IokeObject.as(o, context));
                    }

                    hook.setData(new Hook(objs));
                    return hook;
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("returns the objects this hook is connected to", new TypeCheckingNativeMethod.WithNoArguments("connectedObjects", obj) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    Hook h = (Hook) IokeObject.data(on);
                    List l = new ArrayList<Object>(h.connected);
                    return method.runtime.newList(l);
                }
            }));
    }

    public IokeData cloneData(IokeObject obj, IokeObject m, IokeObject context) {
        return new Hook(new ArrayList<IokeObject>(connected));
    }
}// Hook
