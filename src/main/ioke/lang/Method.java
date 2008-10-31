/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.List;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Method extends IokeData {
    String name;
    private IokeObject context;

    public Method(String name) {
        this.name = name;
    }

    public Method(IokeObject context) {
        this((String)null);

        this.context = context;
    }
    
    @Override
    public void init(IokeObject method) {
        method.setKind("Method");
        method.registerCell("activatable", method.runtime._true);

        method.registerMethod(method.runtime.newJavaMethod("returns the name of the method", new JavaMethod("name") {
                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) {
                    return context.runtime.newText(((Method)IokeObject.data(on)).name);
                }
            }));
        method.registerMethod(method.runtime.newJavaMethod("activates this method with the arguments given to call", new JavaMethod("call") {
                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    return IokeObject.as(on).activate(context, message, context.getRealContext());
                }
            }));
    }

    public String getName() {
        return name;
    }

    @Override
    public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
        return self.runtime.nil;
    }

    @Override
    public String representation(IokeObject self) {
        return "method(...)";
    }
}// Method
