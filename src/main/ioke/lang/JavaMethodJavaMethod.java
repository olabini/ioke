/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.lang.reflect.Method;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class JavaMethodJavaMethod extends ioke.lang.Method {
    private Method[] methods;
    private JavaArgumentsDefinition arguments;

    public JavaMethodJavaMethod(Method[] methods) {
        super(methods[0].getName());
        this.methods = methods;
        this.arguments = JavaArgumentsDefinition.createFrom(methods);
    }

    public String getArgumentsCode() {
        return "...";
    }

    @Override
    public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
        List<Object> args = new LinkedList<Object>();
        Method method = (Method)arguments.getJavaArguments(context, message, on, args);
        return activate(self, on, args, method, context, message);
    }

    public Object activate(IokeObject self, Object on, List<Object> args, Method method, IokeObject context, IokeObject message) throws ControlFlow {
        try {
            if((on instanceof IokeObject) && (IokeObject.data(on) instanceof JavaWrapper)) {
//                  System.err.println("Invoking " + method.getName() + " on " + ((JavaWrapper)IokeObject.data(on)).getObject() + "[" + ((JavaWrapper)IokeObject.data(on)).getObject().getClass().getName() + "]");
                return method.invoke(((JavaWrapper)IokeObject.data(on)).getObject(), args.toArray());
            } else {
//                  System.err.println("Invoking " + method.getName() + " on " + on + "[" + on.getClass().getName() + "]");
                return method.invoke(on, args.toArray());
            }
        } catch(Exception e) {
            context.runtime.reportJavaException(e, message, context);
            return context.runtime.nil;
        }
    }
    
    @Override
    public String inspect(Object self) {
        return "method(" + methods[0].getDeclaringClass().getName() + "_" + methods[0].getName() + ")";
    }
}
