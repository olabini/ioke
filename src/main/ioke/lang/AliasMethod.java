/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class AliasMethod extends IokeData implements Named, Inspectable {
    String name;
    IokeData realMethod;
    IokeObject realSelf;

    public AliasMethod(String name, IokeData realMethod, IokeObject realSelf) {
        this.name = name;
        this.realMethod = realMethod;
        this.realSelf = realSelf;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String inspect(Object self) {
        return ((Inspectable)realMethod).inspect(realSelf);
    }

    public String notice(Object self) {
        return ((Inspectable)realMethod).notice(realSelf);
    }

    @Override
    public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
        return realMethod.activate(realSelf, context, message, on);
    }
}// AliasMethod
