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
        method.registerMethod(method.runtime.newJavaMethod("returns the name of the method", new JavaMethod("name") {
                public IokeObject activate(IokeObject context, IokeObject message, IokeObject on) {
                    return on.runtime.newText(((Method)on.data).name);
                }
            }));
        method.registerMethod(method.runtime.newJavaMethod("activates this method with the arguments given to call", new JavaMethod("call") {
                public IokeObject activate(IokeObject context, IokeObject message, IokeObject on) throws ControlFlow {
                    return on.activate(context, message, context.getRealContext());
                }
            }));
    }

    public String getName() {
        return name;
    }

    public boolean isActivatable() {
        return true;
    }

    @Override
    public IokeObject activate(IokeObject self, IokeObject context, IokeObject message, IokeObject on) throws ControlFlow {
        return self.runtime.nil;
    }
}// Method
