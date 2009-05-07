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
public class Reflector {
    public static void init(final Runtime runtime) throws ControlFlow {
        IokeObject obj = new IokeObject(runtime, "Allows access to the internals of any object without actually using methods on that object");
        obj.setKind("Reflector");
        obj.mimicsWithoutCheck(runtime.origin);
        runtime.iokeGround.registerCell("Reflector", obj);

        obj.registerMethod(runtime.newNativeMethod("returns the documentation text of the object given as argument. anything can have a documentation text - this text will initially be nil.", new TypeCheckingNativeMethod("other:documentation") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .withRequiredPositional("other")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return Base.documentation(context, message, args.get(0));
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("sets the documentation string for a specific object.", new TypeCheckingNativeMethod("other:documentation=") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .withRequiredPositional("other")
                    .withRequiredPositional("text").whichMustMimic(runtime.text).orBeNil()
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return Base.setDocumentation(context, message, args.get(0), args.get(1));
                }
            }));
    }
}
