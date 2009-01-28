/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.List;
import java.util.HashSet;
import java.util.Map;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class JavaWrapper extends IokeData {
    private Object object;
    private String kind;
    private Class clazz;

    public JavaWrapper() {
        this(null);
    }

    public JavaWrapper(Object object) {
        this.object = object;
        if(object != null) {
            clazz = this.object.getClass();
            kind = clazz.getName().replaceAll("\\.", ":");
        }
    }

    @Override
    public void init(final IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;

        obj.registerMethod(runtime.newJavaMethod("returns the kind of this Java object.", new TypeCheckingJavaMethod.WithNoArguments("kind", obj) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return context.runtime.newText(((JavaWrapper)IokeObject.data(on)).kind);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("will pass along the call to the real Java object of this wrapper.", 
                                                       new TypeCheckingJavaMethod("pass") {
                                                           private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                                                               .builder()
                                                               .receiverMustMimic(obj)
                                                               .withRestUnevaluated("arguments")
                                                               .getArguments();

                                                           @Override
                                                           public TypeCheckingArgumentsDefinition getArguments() {
                                                               return ARGUMENTS;
                                                           }

                                                           @Override
                                                           public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                                                               return ((JavaWrapper)IokeObject.data(on)).invokeJavaMethod(on, context, message);
                                                           }}));
    }

    public Object invokeJavaMethod(Object self, IokeObject context, IokeObject message) throws ControlFlow {
        String name = message.getName();
        try {
            return clazz.getMethod(name).invoke(object);
        } catch(Exception e) {
            System.err.println("PROBLEM: " + e);
            return context.runtime.nil;
        }
    }
}
