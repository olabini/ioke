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
public class Method extends IokeData implements Named {
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

        method.registerMethod(method.runtime.newJavaMethod("returns the full code of this method, as a Text", new JavaMethod("code") {
                @Override
                public Object activate(IokeObject self, IokeObject dynamicContext, IokeObject message, Object on) throws ControlFlow {
                    return dynamicContext.runtime.newText(((Method)IokeObject.data(on)).getCode());
                }
            }));
    }

    public String getName() {
        return name;
    }

    public String getCode() {
        return "method(nil)";
    }

    public void setName(String name) {
        this.name = name;
    }

    @Override
    public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
        return self.runtime.nil;
    }

//     @Override
//     public String inspect(IokeObject self) {
//         return "method(...)";
//     }
}// Method
