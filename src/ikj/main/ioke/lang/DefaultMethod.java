/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class DefaultMethod extends Method implements AssociatedCode {
    private ArgumentsDefinition arguments;
    private IokeObject code;

    public DefaultMethod(String name) {
        super(name, IokeData.TYPE_DEFAULT_METHOD);
    }

    public DefaultMethod(IokeObject context, ArgumentsDefinition arguments, IokeObject code) {
        super(context, IokeData.TYPE_DEFAULT_METHOD);
        this.arguments = arguments;
        this.code = code;
    }

    public IokeObject getCode() {
        return code;
    }

    @Override
    public void init(IokeObject defaultMethod) throws ControlFlow {
        defaultMethod.setKind("DefaultMethod");

        defaultMethod.registerMethod(defaultMethod.runtime.newNativeMethod("returns a list of the keywords this method takes", new TypeCheckingNativeMethod.WithNoArguments("keywords", defaultMethod) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    List<Object> keywordList = new ArrayList<Object>();

                    for(String keyword : ((DefaultMethod)IokeObject.data(on)).arguments.getKeywords()) {
                        keywordList.add(context.runtime.getSymbol(keyword.substring(0, keyword.length()-1)));
                    }

                    return context.runtime.newList(keywordList);
                }
            }));

        defaultMethod.registerMethod(defaultMethod.runtime.newNativeMethod("returns the message chain for this method", new NativeMethod.WithNoArguments("message") {
                @Override
                public Object activate(IokeObject self, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return ((AssociatedCode)IokeObject.data(IokeObject.ensureTypeIs(AssociatedCode.class, self, on, context, message))).getCode();
                }
            }));

        defaultMethod.registerMethod(defaultMethod.runtime.newNativeMethod("returns the code for the argument definition", new NativeMethod.WithNoArguments("argumentsCode") {
                @Override
                public Object activate(IokeObject self, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return context.runtime.newText(((AssociatedCode)IokeObject.data(IokeObject.ensureTypeIs(AssociatedCode.class, self, on, context, message))).getArgumentsCode());
                }
            }));

        defaultMethod.registerMethod(defaultMethod.runtime.newNativeMethod("returns idiomatically formatted code for this method", new NativeMethod.WithNoArguments("formattedCode") {
                @Override
                public Object activate(IokeObject self, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return context.runtime.newText(((AssociatedCode)IokeObject.data(IokeObject.ensureTypeIs(AssociatedCode.class, self, on, context, message))).getFormattedCode(self));
                }
            }));
    }

    public String getArgumentsCode() {
        return arguments.getCode(false);
    }

    public String getFormattedCode(Object self) throws ControlFlow {
        String args = arguments == null ? "" : arguments.getCode();
        return "method(" + args + "\n  " + Message.formattedCode(code, 2, (IokeObject)self) + ")";
    }

    @Override
    public String getCodeString() {
        String args = arguments == null ? "" : arguments.getCode();
        return "method(" + args + Message.code(code) + ")";
    }

    @Override
    public String inspect(Object self) {
        String args = arguments == null ? "" : arguments.getCode();
        if(name == null) {
            return "method(" + args + Message.code(code) + ")";
        } else {
            return name + ":method(" + args + Message.code(code) + ")";
        }
    }

    private static IokeObject createSuperCallFor(final IokeObject out_self, final IokeObject out_context, final IokeObject out_message, final Object out_on, final String out_name) throws ControlFlow {
        return out_context.runtime.newNativeMethod("will call the super method of the current message on the same receiver", new NativeMethod("super") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRestUnevaluated("arguments")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object superCell = context.runtime.nul;
                    if(out_name != null) {
                        superCell = IokeObject.findSuperCellOn(out_on, out_self, out_context, out_name);
                    }
                    if(superCell == context.runtime.nul) {
                        superCell = IokeObject.findSuperCellOn(out_on, out_self, out_context, Message.name(out_message));
                    }

                    if(superCell != context.runtime.nul) {
                        if(IokeObject.data(superCell) instanceof Method) {
                            return Interpreter.activate(((IokeObject)superCell), context, message, out_on);
                        } else {
                            return superCell;
                        }
                    } else {
                        return Interpreter.signalNoSuchCell(message, context, out_on, out_name, superCell, out_self);
                    }
                }
            });
    }

    public static Object activateWithCallAndDataFixed(final IokeObject self, IokeObject context, IokeObject message, Object on, Object call, Map<String, Object> data) throws ControlFlow {
        DefaultMethod dm = (DefaultMethod)self.data;
        if(dm.code == null) {
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
            condition.setCell("report", context.runtime.newText("You tried to activate a method without any code - did you by any chance activate the DefaultMethod kind by referring to it without wrapping it inside a call to cell?"));
            context.runtime.errorCondition(condition);
            return null;
        }


        IokeObject c = context.runtime.locals.mimic(message, context);
        c.setCell("self", on);
        c.setCell("@", on);

        c.registerMethod(c.runtime.newNativeMethod("will return the currently executing method receiver", new NativeMethod.WithNoArguments("@@") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return self;
                }
            }));

        c.setCell("currentMessage", message);
        c.setCell("surroundingContext", context);
        for(Map.Entry<String, Object> d : data.entrySet()) {
            String s = d.getKey();
            c.setCell(s.substring(0, s.length()-1), d.getValue());
        }

        c.setCell("super", createSuperCallFor(self, context, message, on, dm.name));

        dm.arguments.assignArgumentValues(c, context, message, on, ((Call)IokeObject.data(call)));

        try {
            return context.runtime.interpreter.evaluate(dm.code, c, on, c);
        } catch(ControlFlow.Return e) {
            if(e.context == c) {
                return e.getValue();
            } else {
                throw e;
            }
        }
    }

    public static Object activateFixed(final IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
        DefaultMethod dm = (DefaultMethod)self.data;
        if(dm.code == null) {
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
            condition.setCell("report", context.runtime.newText("You tried to activate a method without any code - did you by any chance activate the DefaultMethod kind by referring to it without wrapping it inside a call to cell?"));
            context.runtime.errorCondition(condition);
            return null;
        }


        IokeObject c = context.runtime.locals.mimic(message, context);
        c.setCell("self", on);
        c.setCell("@", on);

        c.registerMethod(c.runtime.newNativeMethod("will return the currently executing method receiver", new NativeMethod.WithNoArguments("@@") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return self;
                }
            }));

        c.setCell("currentMessage", message);
        c.setCell("surroundingContext", context);
        c.setCell("super", createSuperCallFor(self, context, message, on, dm.name));

        dm.arguments.assignArgumentValues(c, context, message, on);

        try {
            return context.runtime.interpreter.evaluate(dm.code, c, on, c);
        } catch(ControlFlow.Return e) {
            if(e.context == c) {
                return e.getValue();
            } else {
                throw e;
            }
        }
    }

    public static Object activateWithDataFixed(final IokeObject self, IokeObject context, IokeObject message, Object on, Map<String, Object> data) throws ControlFlow {
        DefaultMethod dm = (DefaultMethod)self.data;
        if(dm.code == null) {
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
            condition.setCell("report", context.runtime.newText("You tried to activate a method without any code - did you by any chance activate the DefaultMethod kind by referring to it without wrapping it inside a call to cell?"));
            context.runtime.errorCondition(condition);
            return null;
        }


        IokeObject c = context.runtime.locals.mimic(message, context);
        c.setCell("self", on);
        c.setCell("@", on);

        c.registerMethod(c.runtime.newNativeMethod("will return the currently executing method receiver", new NativeMethod.WithNoArguments("@@") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return self;
                }
            }));

        c.setCell("currentMessage", message);
        c.setCell("surroundingContext", context);
        for(Map.Entry<String, Object> d : data.entrySet()) {
            String s = d.getKey();
            c.setCell(s.substring(0, s.length()-1), d.getValue());
        }

        c.setCell("super", createSuperCallFor(self, context, message, on, dm.name));

        dm.arguments.assignArgumentValues(c, context, message, on);

        try {
            return context.runtime.interpreter.evaluate(dm.code, c, on, c);
        } catch(ControlFlow.Return e) {
            if(e.context == c) {
                return e.getValue();
            } else {
                throw e;
            }
        }
    }
}// DefaultMethod
