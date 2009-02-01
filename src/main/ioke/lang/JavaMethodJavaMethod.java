/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.lang.reflect.Method;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class JavaMethodJavaMethod extends ioke.lang.Method {
    private Method method;

    public JavaMethodJavaMethod(Method method) {
        super(method.getName());
        this.method = method;
    }

    public String getArgumentsCode() {
        return "...";
    }

    @Override
    public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
        List<Object> args = new ArrayList<Object>();
        Map<String, Object> keywords = new HashMap<String, Object>();
        //        getArguments().getEvaluatedArguments(context, message, on, args, keywords);
        return activate(self, on, args, keywords, context, message);
    }

    public Object activate(IokeObject self, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
        try {
            if((on instanceof IokeObject) && (IokeObject.data(on) instanceof JavaWrapper)) {
                               System.err.println("Invoking " + method.getName() + " on " + ((JavaWrapper)IokeObject.data(on)).getObject() + "[" + ((JavaWrapper)IokeObject.data(on)).getObject().getClass().getName() + "]");
                return method.invoke(((JavaWrapper)IokeObject.data(on)).getObject());
            } else {
                               System.err.println("Invoking " + method.getName() + " on " + on + "[" + on.getClass().getName() + "]");
                return method.invoke(on);
            }
        } catch(Exception e) {
            System.err.print("woops: ");
            e.printStackTrace();
            return context.runtime.nil;
        }
    }
    
    @Override
    public String inspect(Object self) {
        return "method(" + method.getDeclaringClass().getName() + "_" + method.getName() + ")";
    }
}
