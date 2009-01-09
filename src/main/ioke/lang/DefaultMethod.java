/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class DefaultMethod extends Method implements AssociatedCode {
    private DefaultArgumentsDefinition arguments;
    private IokeObject code;

    public DefaultMethod(String name) {
        super(name);
    }

    public DefaultMethod(IokeObject context, DefaultArgumentsDefinition arguments, IokeObject code) {
        super(context);
        this.arguments = arguments;
        this.code = code;
    }

    public IokeObject getCode() {
        return code;
    }

    @Override
    public void init(IokeObject defaultMethod) throws ControlFlow {
        defaultMethod.setKind("DefaultMethod");
        defaultMethod.registerMethod(defaultMethod.runtime.newJavaMethod("returns a list of the keywords this method takes", new JavaMethod.WithNoArguments("keywords") {
                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    List<Object> keywords = new ArrayList<Object>();
                    
                    for(String keyword : ((DefaultMethod)IokeObject.data(on)).arguments.getKeywords()) {
                        keywords.add(context.runtime.getSymbol(keyword.substring(0, keyword.length()-1)));
                    }

                    return context.runtime.newList(keywords);
                }
            }));
        defaultMethod.registerMethod(defaultMethod.runtime.newJavaMethod("returns the message chain for this method", new JavaMethod.WithNoArguments("message") {
                @Override
                public Object activate(IokeObject self, IokeObject dynamicContext, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(dynamicContext, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return ((AssociatedCode)IokeObject.data(on)).getCode();
                }
            }));
        defaultMethod.registerMethod(defaultMethod.runtime.newJavaMethod("returns the code for the argument definition", new JavaMethod.WithNoArguments("argumentsCode") {
                @Override
                public Object activate(IokeObject self, IokeObject dynamicContext, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(dynamicContext, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return dynamicContext.runtime.newText(((AssociatedCode)IokeObject.data(on)).getArgumentsCode());
                }
            }));
        defaultMethod.registerMethod(defaultMethod.runtime.newJavaMethod("returns idiomatically formatted code for this method", new JavaMethod.WithNoArguments("formattedCode") {
                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return context.runtime.newText(((AssociatedCode)IokeObject.data(on)).getFormattedCode(self));
                }
            }));
    }

    public String getArgumentsCode() {
        return arguments.getCode(false);
    }

    public String getFormattedCode(Object self) throws ControlFlow {
        String args = arguments == null ? "" : arguments.getCode();
        return "method(" + args + "\n  " + Message.formattedCode(code, 2) + ")";
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

    private IokeObject createSuperCallFor(final IokeObject out_self, final IokeObject out_context, final IokeObject out_message, final Object out_on, final Object out_superCell) throws ControlFlow {
        return out_context.runtime.newJavaMethod("will call the super method of the current message on the same receiver", new JavaMethod("super") {
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
                    if(IokeObject.data(out_superCell) instanceof Method) {
                        return IokeObject.activate(out_superCell, context, message, out_on);
                    } else {
                        return out_superCell;
                    }
                }
            });
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
            condition.setCell("report", context.runtime.newText("You tried to activate a method without any code - did you by any chance activate the DefaultMethod kind by referring to it without wrapping it inside a call to cell?"));
            context.runtime.errorCondition(condition);
            return null;
        }


        IokeObject c = context.runtime.locals.mimic(message, context);
        c.setCell("self", on);
        c.setCell("@", on);

        c.registerMethod(c.runtime.newJavaMethod("will return the currently executing method receiver", new JavaMethod.WithNoArguments("@@") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return self;
                }
            }));

        c.setCell("currentMessage", message);
        c.setCell("surroundingContext", context);

        Object superCell = IokeObject.findSuperCellOn(on, self, message, context, name);
        if(superCell != context.runtime.nul) {
            c.setCell("super", createSuperCallFor(self, context, message, on, superCell));
        }

        arguments.assignArgumentValues(c, context, message, on);

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
}// DefaultMethod
