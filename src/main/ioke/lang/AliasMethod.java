/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class AliasMethod extends IokeData {
    String name;
    Method realMethod;

    public AliasMethod(String name, Method realMethod) {
        this.name = name;
        this.realMethod = realMethod;
    }

    public String getName() {
        return name;
    }

    @Override
    public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
        return realMethod.activate(self, context, message, on);
    }

    @Override
    public String representation(IokeObject self) {
        return realMethod.representation(self);
    }
}// AliasMethod
