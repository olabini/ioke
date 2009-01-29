/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class LexicalMacro extends IokeData implements AssociatedCode, Named, Inspectable {
    String name;
    private IokeObject context;
    private IokeObject code;

    public LexicalMacro(IokeObject context, IokeObject code) {
        this.context = context;
        this.code = code;
    }

    public LexicalMacro(String name) {
        this.name = name;
    }

    public IokeObject getCode() {
        return code;
    }

    public String getCodeString(Object self) throws ControlFlow {
        if(IokeObject.as(self, null).isActivatable()) {
            return "lecro(" + Message.code(code) + ")";
        } else {
            return "lecrox(" + Message.code(code) + ")";
        }
    }

    public String getFormattedCode(Object self) throws ControlFlow {
        if(IokeObject.as(self, null).isActivatable()) {
            return "lecro(\n  " + Message.formattedCode(code, 2) + ")";
        } else {
            return "lecrox(\n  " + Message.formattedCode(code, 2) + ")";
        }
    }

    @Override
    public void init(IokeObject obj) throws ControlFlow {
        obj.setKind("LexicalMacro");
        obj.registerCell("activatable", obj.runtime._true);

        obj.registerMethod(obj.runtime.newJavaMethod("returns the name of the lecro", new JavaMethod.WithNoArguments("name") {
                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());

                    return context.runtime.newText(((LexicalMacro)IokeObject.data(on)).name);
                }
            }));
        obj.registerMethod(obj.runtime.newJavaMethod("activates this lecro with the arguments given to call", new JavaMethod("call") {
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
                    return IokeObject.as(on, context).activate(context, message, context.getRealContext());
                }
            }));
        obj.registerMethod(obj.runtime.newJavaMethod("returns the message chain for this lecro", new JavaMethod.WithNoArguments("message") {
                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());

                    return ((AssociatedCode)IokeObject.data(on)).getCode();
                }
            }));
        obj.registerMethod(obj.runtime.newJavaMethod("returns the code for the argument definition", new JavaMethod.WithNoArguments("argumentsCode") {
                @Override
                public Object activate(IokeObject self, IokeObject dynamicContext, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(dynamicContext, message, on, new ArrayList<Object>(), new HashMap<String, Object>());

                    return dynamicContext.runtime.newText(((AssociatedCode)IokeObject.data(on)).getArgumentsCode());
                }
            }));
        obj.registerMethod(obj.runtime.newJavaMethod("Returns a text inspection of the object", new JavaMethod.WithNoArguments("inspect") {
                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());

                    return context.runtime.newText(LexicalMacro.getInspect(on));
                }
            }));
        obj.registerMethod(obj.runtime.newJavaMethod("Returns a brief text inspection of the object", new JavaMethod.WithNoArguments("notice") {
                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());

                    return context.runtime.newText(LexicalMacro.getNotice(on));
                }
            }));
        obj.registerMethod(obj.runtime.newJavaMethod("returns the full code of this lecro, as a Text", new JavaMethod.WithNoArguments("code") {
                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());

                    IokeData data = IokeObject.data(on);
                    if(data instanceof LexicalMacro) {
                        return context.runtime.newText(((LexicalMacro)data).getCodeString(on));
                    } else {
                        return context.runtime.newText(((AliasMethod)data).getCodeString());
                    }
                }
            }));
        obj.registerMethod(obj.runtime.newJavaMethod("returns idiomatically formatted code for this lecro", new JavaMethod.WithNoArguments("formattedCode") {
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
        String type = "lecro";
        if(!IokeObject.as(self, null).isActivatable()) {
            type = "lecrox";
        }

        if(name == null) {
            return type + "(" + Message.code(code) + ")";
        } else {
            return name + ":" + type + "(" + Message.code(code) + ")";
        }
    }

    public String notice(Object self) {
        String type = "lecro";
        if(!IokeObject.as(self, null).isActivatable()) {
            type = "lecrox";
        }

        if(name == null) {
            return type + "(...)";
        } else {
            return name + ":" + type + "(...)";
        }
    }

    @Override
    public Object activateWithCallAndData(final IokeObject self, IokeObject dynamicContext, IokeObject message, Object on, Object call, Map<String, Object> data) throws ControlFlow {
        if(code == null) {
            IokeObject condition = IokeObject.as(IokeObject.getCellChain(dynamicContext.runtime.condition, 
                                                                         message, 
                                                                         dynamicContext, 
                                                                         "Error", 
                                                                         "Invocation",
                                                                         "NotActivatable"), dynamicContext).mimic(message, dynamicContext);
            condition.setCell("message", message);
            condition.setCell("context", dynamicContext);
            condition.setCell("receiver", on);
            condition.setCell("method", self);
            condition.setCell("report", dynamicContext.runtime.newText("You tried to activate a method without any code - did you by any chance activate the LexicalMacro kind by referring to it without wrapping it inside a call to cell?"));
            dynamicContext.runtime.errorCondition(condition);
            return null;
        }

        LexicalContext c = new LexicalContext(self.runtime, on, "Lexical macro activation context", message, this.context);

        c.setCell("outerScope", context);
        c.setCell("call", call);
        for(Map.Entry<String, Object> d : data.entrySet()) {
            String s = d.getKey();
            c.setCell(s.substring(0, s.length()-1), d.getValue());
        }

        return this.code.evaluateCompleteWith(c, on);
    }

    @Override
    public Object activateWithCall(IokeObject self, IokeObject dynamicContext, IokeObject message, Object on, Object call) throws ControlFlow {
        if(code == null) {
            IokeObject condition = IokeObject.as(IokeObject.getCellChain(dynamicContext.runtime.condition, 
                                                                         message, 
                                                                         dynamicContext, 
                                                                         "Error", 
                                                                         "Invocation",
                                                                         "NotActivatable"), dynamicContext).mimic(message, dynamicContext);
            condition.setCell("message", message);
            condition.setCell("context", dynamicContext);
            condition.setCell("receiver", on);
            condition.setCell("method", self);
            condition.setCell("report", dynamicContext.runtime.newText("You tried to activate a method without any code - did you by any chance activate the LexicalMacro kind by referring to it without wrapping it inside a call to cell?"));
            dynamicContext.runtime.errorCondition(condition);
            return null;
        }

        LexicalContext c = new LexicalContext(self.runtime, on, "Lexical macro activation context", message, this.context);

        c.setCell("outerScope", context);
        c.setCell("call", call);

        return this.code.evaluateCompleteWith(c, on);
    }

    @Override
    public Object activate(IokeObject self, IokeObject dynamicContext, IokeObject message, Object on) throws ControlFlow {
        if(code == null) {
            IokeObject condition = IokeObject.as(IokeObject.getCellChain(dynamicContext.runtime.condition, 
                                                                         message, 
                                                                         dynamicContext, 
                                                                         "Error", 
                                                                         "Invocation",
                                                                         "NotActivatable"), dynamicContext).mimic(message, dynamicContext);
            condition.setCell("message", message);
            condition.setCell("context", dynamicContext);
            condition.setCell("receiver", on);
            condition.setCell("method", self);
            condition.setCell("report", dynamicContext.runtime.newText("You tried to activate a method without any code - did you by any chance activate the LexicalMacro kind by referring to it without wrapping it inside a call to cell?"));
            dynamicContext.runtime.errorCondition(condition);
            return null;
        }

        LexicalContext c = new LexicalContext(self.runtime, on, "Lexical macro activation context", message, this.context);

        c.setCell("outerScope", context);
        c.setCell("call", dynamicContext.runtime.newCallFrom(c, message, dynamicContext, IokeObject.as(on, dynamicContext)));

        return this.code.evaluateCompleteWith(c, on);
    }

    @Override
    public Object activateWithData(IokeObject self, IokeObject dynamicContext, IokeObject message, Object on, Map<String, Object> data) throws ControlFlow {
        if(code == null) {
            IokeObject condition = IokeObject.as(IokeObject.getCellChain(dynamicContext.runtime.condition, 
                                                                         message, 
                                                                         dynamicContext, 
                                                                         "Error", 
                                                                         "Invocation",
                                                                         "NotActivatable"), dynamicContext).mimic(message, dynamicContext);
            condition.setCell("message", message);
            condition.setCell("context", dynamicContext);
            condition.setCell("receiver", on);
            condition.setCell("method", self);
            condition.setCell("report", dynamicContext.runtime.newText("You tried to activate a method without any code - did you by any chance activate the LexicalMacro kind by referring to it without wrapping it inside a call to cell?"));
            dynamicContext.runtime.errorCondition(condition);
            return null;
        }

        LexicalContext c = new LexicalContext(self.runtime, on, "Lexical macro activation context", message, this.context);

        c.setCell("outerScope", context);
        c.setCell("call", dynamicContext.runtime.newCallFrom(c, message, dynamicContext, IokeObject.as(on, dynamicContext)));
        for(Map.Entry<String, Object> d : data.entrySet()) {
            String s = d.getKey();
            c.setCell(s.substring(0, s.length()-1), d.getValue());
        }

        return this.code.evaluateCompleteWith(c, on);
    }
}// LexicalMacro
