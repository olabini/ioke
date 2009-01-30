/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.lang.reflect.Constructor;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class JavaConstructorJavaMethod extends ioke.lang.Method {
    private Constructor ctor;

    public JavaConstructorJavaMethod(Constructor ctor) {
        super("new");
        this.ctor = ctor;
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
            return ctor.newInstance();
        } catch(Exception e) {
            System.err.print("woops: ");
            e.printStackTrace();
            return context.runtime.nil;
        }
    }
    
    @Override
    public String inspect(Object self) {
        return "method(" + ctor.getDeclaringClass().getName() + "_new)";
    }
}
