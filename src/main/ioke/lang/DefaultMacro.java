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
        macro.registerMethod(macro.runtime.newJavaMethod("Returns a text inspection of the object", new JavaMethod("inspect") {
                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) {
                    return context.runtime.newText(DefaultMacro.getInspect(on));
                }
            }));
        macro.registerMethod(macro.runtime.newJavaMethod("Returns a brief text inspection of the object", new JavaMethod("notice") {
                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) {
                    return context.runtime.newText(DefaultMacro.getNotice(on));
                }
            }));
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public static String getInspect(Object on) {
        return ((DefaultMacro)(IokeObject.data(on))).inspect(on);
    }

    public static String getNotice(Object on) {
        return ((DefaultMacro)(IokeObject.data(on))).notice(on);
    }

    public String inspect(Object self) {
        if(name == null) {
            return "macro(" + Message.code(code) + ")";
        } else {
            return name + ":macro(" + Message.code(code) + ")";
        }
    }

    public String notice(Object self) {
        if(name == null) {
            return "macro(...)";
        } else {
            return name + ":macro(...)";
        }
    }

    @Override
    public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
        IokeObject c = context.runtime.locals.mimic(message, context);
        c.setCell("self", on);
        c.setCell("@", on);
        c.setCell("currentMessage", message);
        c.setCell("surroundingContext", context);
        c.setCell("call", context.runtime.newCallFrom(c, message, context, IokeObject.as(on)));

        return code.evaluateCompleteWith(c, on);
    }
}// DefaultMacro
