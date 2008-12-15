/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.ArrayList;
import java.util.List;

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

    @Override
    public IokeObject getCode() {
        return code;
    }

    @Override
    public void init(IokeObject defaultMethod) {
        defaultMethod.setKind("DefaultMethod");
        defaultMethod.registerMethod(defaultMethod.runtime.newJavaMethod("returns a list of the keywords this method takes", new JavaMethod("keywords") {
                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) {
                    List<Object> keywords = new ArrayList<Object>();
                    
                    for(String keyword : ((DefaultMethod)IokeObject.data(on)).arguments.getKeywords()) {
                        keywords.add(context.runtime.getSymbol(keyword.substring(0, keyword.length()-1)));
                    }

                    return context.runtime.newList(keywords);
                }
            }));
        defaultMethod.registerMethod(defaultMethod.runtime.newJavaMethod("returns the message chain for this method", new JavaMethod("message") {
                @Override
                public Object activate(IokeObject self, IokeObject dynamicContext, IokeObject message, Object on) throws ControlFlow {
                    return ((AssociatedCode)IokeObject.data(on)).getCode();
                }
            }));
        defaultMethod.registerMethod(defaultMethod.runtime.newJavaMethod("returns the code for the argument definition", new JavaMethod("argumentsCode") {
                @Override
                public Object activate(IokeObject self, IokeObject dynamicContext, IokeObject message, Object on) throws ControlFlow {
                    return dynamicContext.runtime.newText(((AssociatedCode)IokeObject.data(on)).getArgumentsCode());
                }
            }));
    }

    @Override
    public String getArgumentsCode() {
        return arguments.getCode(false);
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

    private IokeObject createSuperCallFor(final IokeObject out_self, final IokeObject out_context, final IokeObject out_message, final Object out_on, final Object out_superCell) {
        return out_context.runtime.newJavaMethod("will call the super method of the current message on the same receiver", new JavaMethod("super") {
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
    public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
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
