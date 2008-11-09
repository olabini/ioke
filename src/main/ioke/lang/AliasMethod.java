/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class AliasMethod extends IokeData implements Named {
    String name;
    IokeData realMethod;

    public AliasMethod(String name, IokeData realMethod) {
        this.name = name;
        this.realMethod = realMethod;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    @Override
    public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
        return realMethod.activate(self, context, message, on);
    }

    @Override
    public String inspect(IokeObject self) {
        return realMethod.inspect(self);
    }
}// AliasMethod
