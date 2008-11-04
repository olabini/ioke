/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class DefaultMacro extends IokeData implements Named {
    String name;
    private IokeObject context;
    private IokeObject code;

    public DefaultMacro(String name) {
        this.name = name;
    }

    public DefaultMacro(IokeObject context, IokeObject code) {
        this((String)null);

        this.context = context;
        this.code = code;
    }
    
    @Override
    public void init(IokeObject macro) {
        macro.setKind("DefaultMacro");
        macro.registerCell("activatable", macro.runtime._true);

        macro.registerMethod(macro.runtime.newJavaMethod("returns the name of the macro", new JavaMethod("name") {
                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) {
                    return context.runtime.newText(((DefaultMacro)IokeObject.data(on)).name);
                }
            }));
        macro.registerMethod(macro.runtime.newJavaMethod("activates this macro with the arguments given to call", new JavaMethod("call") {
                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    return IokeObject.as(on).activate(context, message, context.getRealContext());
                }
            }));
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    @Override
    public String representation(IokeObject self) {
        return "method(...)";
    }

    @Override
    public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
        MacroContext c = new MacroContext(self.runtime, on, "Macro activation context for " + message.getName(), message, context);

        return code.evaluateCompleteWith(c, on);
    }
}// DefaultMacro
