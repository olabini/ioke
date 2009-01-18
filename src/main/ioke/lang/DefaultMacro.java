/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class DefaultMacro extends IokeData implements Named, Inspectable, AssociatedCode {
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

    public IokeObject getCode() {
        return code;
    }

    public String getCodeString() {
        return "macro(" + Message.code(code) + ")";

    }

    public String getFormattedCode(Object self) throws ControlFlow {
        return "macro(\n  " + Message.formattedCode(code, 2) + ")";
    }
    
    @Override
    public void init(IokeObject macro) throws ControlFlow {
        macro.setKind("DefaultMacro");
        macro.registerCell("activatable", macro.runtime._true);

        macro.registerMethod(macro.runtime.newJavaMethod("returns the name of the macro", new JavaMethod.WithNoArguments("name") {
                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return context.runtime.newText(((DefaultMacro)IokeObject.data(on)).name);
                }
            }));
        macro.registerMethod(macro.runtime.newJavaMethod("activates this macro with the arguments given to call", new JavaMethod("call") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRestUnevaluated("arguments")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    return IokeObject.as(on).activate(context, message, context.getRealContext());
                }
            }));
        macro.registerMethod(macro.runtime.newJavaMethod("returns the message chain for this macro", new JavaMethod.WithNoArguments("message") {
                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return ((AssociatedCode)IokeObject.data(on)).getCode();
                }
            }));
        macro.registerMethod(macro.runtime.newJavaMethod("returns the code for the argument definition", new JavaMethod.WithNoArguments("argumentsCode") {
                @Override
                public Object activate(IokeObject self, IokeObject dynamicContext, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(dynamicContext, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return dynamicContext.runtime.newText(((AssociatedCode)IokeObject.data(on)).getArgumentsCode());
                }
            }));
        macro.registerMethod(macro.runtime.newJavaMethod("Returns a text inspection of the object", new JavaMethod.WithNoArguments("inspect") {
                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return context.runtime.newText(DefaultMacro.getInspect(on));
                }
            }));
        macro.registerMethod(macro.runtime.newJavaMethod("Returns a brief text inspection of the object", new JavaMethod.WithNoArguments("notice") {
                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return context.runtime.newText(DefaultMacro.getNotice(on));
                }
            }));
        macro.registerMethod(macro.runtime.newJavaMethod("returns the full code of this macro, as a Text", new JavaMethod.WithNoArguments("code") {
                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    IokeData data = IokeObject.data(on);
                    if(data instanceof DefaultMacro) {
                        return context.runtime.newText(((DefaultMacro)data).getCodeString());
                    } else {
                        return context.runtime.newText(((AliasMethod)data).getCodeString());
                    }
                }
            }));
        macro.registerMethod(macro.runtime.newJavaMethod("returns idiomatically formatted code for this macro", new JavaMethod.WithNoArguments("formattedCode") {
                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return context.runtime.newText(((AssociatedCode)IokeObject.data(on)).getFormattedCode(self));
                }
            }));
    }

    public String getArgumentsCode() {
        return "...";
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public static String getInspect(Object on) {
        return ((Inspectable)(IokeObject.data(on))).inspect(on);
    }

    public static String getNotice(Object on) {
        return ((Inspectable)(IokeObject.data(on))).notice(on);
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
    public Object activateWithCallAndData(final IokeObject self, IokeObject context, IokeObject message, Object on, Object call, Map<String, Object> data) throws ControlFlow {
        return activateWithCall(self, context, message, on, call);
    }

    @Override
    public Object activateWithCall(final IokeObject self, IokeObject context, IokeObject message, Object on, Object call) throws ControlFlow {
        if(code == null) {
            IokeObject condition = IokeObject.as(IokeObject.getCellChain(context.runtime.condition, 
                                                                         message, 
                                                                         context, 
                                                                         "Error", 
                                                                         "Invocation",
                                                                         "NotActivatable")).mimic(message, context);
            condition.setCell("message", message);
            condition.setCell("context", context);
            condition.setCell("receiver", on);
            condition.setCell("method", self);
            condition.setCell("report", context.runtime.newText("You tried to activate a method without any code - did you by any chance activate the DefaultMacro kind by referring to it without wrapping it inside a call to cell?"));
            context.runtime.errorCondition(condition);
            return null;
        }

        IokeObject c = context.runtime.locals.mimic(message, context);
        c.setCell("self", on);
        c.setCell("@", on);
        c.registerMethod(c.runtime.newJavaMethod("will return the currently executing macro receiver", new JavaMethod.WithNoArguments("@@") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return self;
                }
            }));
        c.setCell("currentMessage", message);
        c.setCell("surroundingContext", context);
        c.setCell("call", call);

        try {
            return code.evaluateCompleteWith(c, on);
        } catch(ControlFlow.Return e) {
            if(e.context == c) {
                return e.getValue();
            } else {
                throw e;
            }
        }
    }

    @Override
    public Object activate(final IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
        if(code == null) {
            IokeObject condition = IokeObject.as(IokeObject.getCellChain(context.runtime.condition, 
                                                                         message, 
                                                                         context, 
                                                                         "Error", 
                                                                         "Invocation",
                                                                         "NotActivatable")).mimic(message, context);
            condition.setCell("message", message);
            condition.setCell("context", context);
            condition.setCell("receiver", on);
            condition.setCell("method", self);
            condition.setCell("report", context.runtime.newText("You tried to activate a method without any code - did you by any chance activate the DefaultMacro kind by referring to it without wrapping it inside a call to cell?"));
            context.runtime.errorCondition(condition);
            return null;
        }

        IokeObject c = context.runtime.locals.mimic(message, context);
        c.setCell("self", on);
        c.setCell("@", on);
        c.registerMethod(c.runtime.newJavaMethod("will return the currently executing macro receiver", new JavaMethod.WithNoArguments("@@") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return self;
                }
            }));
        c.setCell("currentMessage", message);
        c.setCell("surroundingContext", context);
        c.setCell("call", context.runtime.newCallFrom(c, message, context, IokeObject.as(on)));

        try {
            return code.evaluateCompleteWith(c, on);
        } catch(ControlFlow.Return e) {
            if(e.context == c) {
                return e.getValue();
            } else {
                throw e;
            }
        }
    }
}// DefaultMacro
