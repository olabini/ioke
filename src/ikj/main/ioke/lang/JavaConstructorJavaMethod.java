/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.lang.reflect.Constructor;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.LinkedList;
import java.util.Map;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class JavaConstructorJavaMethod extends ioke.lang.Method implements JavaImplementedMethod { 
    private Constructor[] ctors;
    private JavaArgumentsDefinition arguments;
    private boolean special;

    public JavaConstructorJavaMethod(Constructor[] ctors, boolean special) {
        super("new");
        this.ctors = ctors;
        this.special = special;
        this.arguments = JavaArgumentsDefinition.createFrom(ctors, special);
    }

    public String getArgumentsCode() {
        return "...";
    }

    @Override
    public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
        List<Object> args = new LinkedList<Object>();
        Constructor ctor = (Constructor)arguments.getJavaArguments(context, message, on, args);
        return activate(self, on, args, ctor, context, message);
    }

    public Object activate(IokeObject self, Object on, List<Object> args, Constructor ctor, IokeObject context, IokeObject message) throws ControlFlow {
        try {
            if(!special) {
                //             System.err.println("invoking: " + ctor);
                return ctor.newInstance(args.toArray());
            } else {
                IokeObject other = IokeObject.mimic(on, message, context);
                Object[] aa = args.toArray();
                aa[0] = other;
                Object ret = ctor.newInstance(aa);
                JavaWrapper.setObject(other, ret);
                IokeRegistry.makeWrapped(ret, other, context);
                return other;
            }
        } catch(Exception e) {
            System.err.print("woops: ");
            e.printStackTrace();
            return context.runtime.nil;
        }
    }
    
    @Override
    public String inspect(Object self) {
        return "method(" + ctors[0].getDeclaringClass().getName() + "_new)";
    }
}
