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
public class JavaGround {
    public static void init(IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;
        obj.setKind("JavaGround");
        obj.mimicsWithoutCheck(IokeObject.as(runtime.defaultBehavior.getCells().get("BaseBehavior"), null));


        obj.registerMethod(runtime.newJavaMethod("takes an internal name for a Java type and returns that object.", new TypeCheckingJavaMethod("primitiveJavaClass!") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .withRequiredPositional("name").whichMustMimic(runtime.text)
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    Object arg = args.get(0);
                    String name = Text.getText(arg);
                    Class<?> c = null;
                    try {
                        c = Class.forName(name);
                    } catch(Exception e) {
                        System.err.println("Ouchie...: " + e);
                        c = null;
                    }
                    return c;
                }
            }));
        
    }
}
