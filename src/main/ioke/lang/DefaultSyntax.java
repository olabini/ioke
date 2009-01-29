/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class DefaultSyntax extends IokeData implements Named, Inspectable, AssociatedCode {
    String name;
    private IokeObject context;
    private IokeObject code;

    public DefaultSyntax(String name) {
        this.name = name;
    }

    public DefaultSyntax(IokeObject context, IokeObject code) {
        this((String)null);

        this.context = context;
        this.code = code;
    }

    public IokeObject getCode() {
        return code;
    }

    public String getCodeString() {
        return "syntax(" + Message.code(code) + ")";

    }

    public String getFormattedCode(Object self) throws ControlFlow {
        return "syntax(\n  " + Message.formattedCode(code, 2) + ")";
    }
    
    @Override
    public void init(final IokeObject syntax) throws ControlFlow {
        syntax.setKind("DefaultSyntax");
        syntax.registerCell("activatable", syntax.runtime._true);

        syntax.registerMethod(syntax.runtime.newJavaMethod("returns the name of the syntax", new TypeCheckingJavaMethod.WithNoArguments("name", syntax) {
                @Override
                public Object activate(IokeObject self, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return context.runtime.newText(((DefaultSyntax)IokeObject.data(on)).name);
                }
            }));
        
        syntax.registerMethod(syntax.runtime.newJavaMethod("activates this syntax with the arguments given to call", new JavaMethod("call") {
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
        
        syntax.registerMethod(syntax.runtime.newJavaMethod("returns the result of activating this syntax without actually doing the replacement or execution part.", new JavaMethod("expand") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .withRestUnevaluated("arguments")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object onAsSyntax = context.runtime.defaultSyntax.convertToThis(on, message, context);
                    return ((DefaultSyntax)IokeObject.data(onAsSyntax)).expand(IokeObject.as(onAsSyntax, context), context, message, context.getRealContext(), null);
                }
            }));
        
        syntax.registerMethod(syntax.runtime.newJavaMethod("returns the message chain for this syntax", new JavaMethod.WithNoArguments("message") {
                @Override
                public Object activate(IokeObject self, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return ((AssociatedCode)IokeObject.data(IokeObject.ensureTypeIs(AssociatedCode.class, self, on, context, message))).getCode();
                }
            }));
        
        syntax.registerMethod(syntax.runtime.newJavaMethod("returns the code for the argument definition", new JavaMethod.WithNoArguments("argumentsCode") {
                @Override
                public Object activate(IokeObject self, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return context.runtime.newText(((AssociatedCode)IokeObject.data(IokeObject.ensureTypeIs(AssociatedCode.class, self, on, context, message))).getArgumentsCode());
                }
            }));

        syntax.registerMethod(syntax.runtime.newJavaMethod("Returns a text inspection of the object", new TypeCheckingJavaMethod.WithNoArguments("inspect", syntax) {
                @Override
                public Object activate(IokeObject self, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return context.runtime.newText(DefaultSyntax.getInspect(on));
                }
            }));
        
        syntax.registerMethod(syntax.runtime.newJavaMethod("Returns a brief text inspection of the object", new TypeCheckingJavaMethod.WithNoArguments("notice", syntax) {
                @Override
                public Object activate(IokeObject self, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return context.runtime.newText(DefaultSyntax.getNotice(on));
                }
            }));

        syntax.registerMethod(syntax.runtime.newJavaMethod("returns the full code of this syntax, as a Text", new TypeCheckingJavaMethod.WithNoArguments("code", syntax) {
                @Override
                public Object activate(IokeObject self, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    IokeData data = IokeObject.data(on);
                    if(data instanceof DefaultSyntax) {
                        return context.runtime.newText(((DefaultSyntax)data).getCodeString());
                    } else {
                        return context.runtime.newText(((AliasMethod)data).getCodeString());
                    }
                }
            }));

        syntax.registerMethod(syntax.runtime.newJavaMethod("returns idiomatically formatted code for this syntax", new JavaMethod.WithNoArguments("formattedCode") {
                @Override
                public Object activate(IokeObject self, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return context.runtime.newText(((AssociatedCode)IokeObject.data(IokeObject.ensureTypeIs(AssociatedCode.class, self, on, context, message))).getFormattedCode(self));
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
            return "syntax(" + Message.code(code) + ")";
        } else {
            return name + ":syntax(" + Message.code(code) + ")";
        }
    }

    public String notice(Object self) {
        if(name == null) {
            return "syntax(...)";
        } else {
            return name + ":syntax(...)";
        }
    }

    private Object expand(final IokeObject self, IokeObject context, IokeObject message, Object on, Map<String, Object> data) throws ControlFlow {
        if(code == null) {
            IokeObject condition = IokeObject.as(IokeObject.getCellChain(context.runtime.condition, 
                                                                         message, 
                                                                         context, 
                                                                         "Error", 
                                                                         "Invocation",
                                                                         "NotActivatable"), context).mimic(message, context);
            condition.setCell("message", message);
            condition.setCell("context", context);
            condition.setCell("receiver", on);
            condition.setCell("method", self);
            condition.setCell("report", context.runtime.newText("You tried to activate a method without any code - did you by any chance activate the DefaultSyntax kind by referring to it without wrapping it inside a call to cell?"));
            context.runtime.errorCondition(condition);
            return null;
        }

        IokeObject c = context.runtime.locals.mimic(message, context);
        c.setCell("self", on);
        c.setCell("@", on);
        c.registerMethod(c.runtime.newJavaMethod("will return the currently executing syntax receiver", new JavaMethod.WithNoArguments("@@") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return self;
                }
            }));
        c.setCell("currentMessage", message);
        c.setCell("surroundingContext", context);
        c.setCell("call", context.runtime.newCallFrom(c, message, context, IokeObject.as(on, context)));
        if(data != null) {
            for(Map.Entry<String, Object> d : data.entrySet()) {
                String s = d.getKey();
                c.setCell(s.substring(0, s.length()-1), d.getValue());
            }
        }

        Object result = null;

        try {
            result = code.evaluateCompleteWith(c, on);
        } catch(ControlFlow.Return e) {
            if(e.context == c) {
                result = e.getValue();
            } else {
                throw e;
            }
        }

        return result;
    }

    private Object expandWithCall(final IokeObject self, IokeObject context, IokeObject message, Object on, Object call, Map<String, Object> data) throws ControlFlow {
        if(code == null) {
            IokeObject condition = IokeObject.as(IokeObject.getCellChain(context.runtime.condition, 
                                                                         message, 
                                                                         context, 
                                                                         "Error", 
                                                                         "Invocation",
                                                                         "NotActivatable"), context).mimic(message, context);
            condition.setCell("message", message);
            condition.setCell("context", context);
            condition.setCell("receiver", on);
            condition.setCell("method", self);
            condition.setCell("report", context.runtime.newText("You tried to activate a method without any code - did you by any chance activate the DefaultSyntax kind by referring to it without wrapping it inside a call to cell?"));
            context.runtime.errorCondition(condition);
            return null;
        }

        IokeObject c = context.runtime.locals.mimic(message, context);
        c.setCell("self", on);
        c.setCell("@", on);
        c.registerMethod(c.runtime.newJavaMethod("will return the currently executing syntax receiver", new JavaMethod.WithNoArguments("@@") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return self;
                }
            }));
        c.setCell("currentMessage", message);
        c.setCell("surroundingContext", context);
        c.setCell("call", call);
        if(data != null) {
            for(Map.Entry<String, Object> d : data.entrySet()) {
                String s = d.getKey();
                c.setCell(s.substring(0, s.length()-1), d.getValue());
            }
        }

        Object result = null;

        try {
            result = code.evaluateCompleteWith(c, on);
        } catch(ControlFlow.Return e) {
            if(e.context == c) {
                result = e.getValue();
            } else {
                throw e;
            }
        }

        return result;
    }

    @Override
    public Object activateWithCallAndData(final IokeObject self, IokeObject context, IokeObject message, Object on, Object call, Map<String, Object> data) throws ControlFlow {
        Object result = expandWithCall(self, context, message, on, call, data);

        if(result == context.runtime.nil) {
            // Remove chain completely
            IokeObject prev = Message.prev(message);
            IokeObject next = Message.next(message);
            if(prev != null) {
                Message.setNext(prev, next);
                if(next != null) {
                    Message.setPrev(next, prev);
                }
            } else {
                message.become(next, message, context);
                Message.setPrev(next, null);
            }
            return null;
        } else {
            // Insert resulting value into chain, wrapping it if it's not a message

            IokeObject newObj = null;
            if(IokeObject.data(result) instanceof Message) {
                newObj = IokeObject.as(result, context);
            } else {
                newObj = context.runtime.createMessage(Message.wrap(IokeObject.as(result, context)));
            }

            IokeObject prev = Message.prev(message);
            IokeObject next = Message.next(message);

            message.become(newObj, message, context);

            IokeObject last = newObj;
            while(Message.next(last) != null) {
                last = Message.next(last);
            }
            Message.setNext(last, next);
            if(next != null) {
                Message.setPrev(next, last);
            }
            Message.setPrev(newObj, prev);

            return message.sendTo(context, context);
        }
    }

    @Override
    public Object activateWithCall(final IokeObject self, IokeObject context, IokeObject message, Object on, Object call) throws ControlFlow {
        return activateWithCallAndData(self, context, message, on, call, null);
    }

    @Override
    public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
        return activateWithData(self, context, message, on, null);
    }


    @Override
    public Object activateWithData(IokeObject self, IokeObject context, IokeObject message, Object on, Map<String, Object> data) throws ControlFlow {
        Object result = expand(self, context, message, on, data);

        if(result == context.runtime.nil) {
            // Remove chain completely
            IokeObject prev = Message.prev(message);
            IokeObject next = Message.next(message);
            if(prev != null) {
                Message.setNext(prev, next);
                if(next != null) {
                    Message.setPrev(next, prev);
                }
            } else {
                message.become(next, message, context);
                Message.setPrev(next, null);
            }
            return null;
        } else {
            // Insert resulting value into chain, wrapping it if it's not a message

            IokeObject newObj = null;
            if(IokeObject.data(result) instanceof Message) {
                newObj = IokeObject.as(result, context);
            } else {
                newObj = context.runtime.createMessage(Message.wrap(IokeObject.as(result, context)));
            }

            IokeObject prev = Message.prev(message);
            IokeObject next = Message.next(message);

            message.become(newObj, message, context);

            IokeObject last = newObj;
            while(Message.next(last) != null) {
                last = Message.next(last);
            }
            Message.setNext(last, next);
            if(next != null) {
                Message.setPrev(next, last);
            }
            Message.setPrev(newObj, prev);

            return message.sendTo(context, context);
        }
    }
}// DefaultSyntax
