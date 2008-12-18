/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class AliasMethod extends IokeData implements Named, Inspectable, AssociatedCode {
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

    public IokeObject getCode() {
        return ((AssociatedCode)realMethod).getCode();
    }

    public String getCodeString() {
        if(realMethod instanceof Method) {
            return ((Method)realMethod).getCodeString();
        } else if(realMethod instanceof DefaultMacro) {
            return ((DefaultMacro)realMethod).getCodeString();
        } else {
            return ((AliasMethod)realMethod).getCodeString();
        }
    }
    
    public String getArgumentsCode() {
        if(realMethod instanceof AssociatedCode) {
            return ((AssociatedCode)realMethod).getArgumentsCode();
        }
        return "...";
    }

    public String getFormattedCode(Object self) throws ControlFlow {
        if(realMethod instanceof AssociatedCode) {
            return ((AssociatedCode)realMethod).getFormattedCode(self);
        }
        return "";
    }

    @Override
    public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
        return realMethod.activate(realSelf, context, message, on);
    }
}// AliasMethod
