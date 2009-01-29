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
public abstract class JavaMethod extends Method {
    public static class WithNoArguments extends JavaMethod {
        private final static DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition.empty();

        public WithNoArguments(String name) {
            super(name);
        }

        @Override
        public DefaultArgumentsDefinition getArguments() {
            return ARGUMENTS;
        }
    }

    public JavaMethod(String name) {
        super(name);
    }

    @Override
    public void init(IokeObject javaMethod) throws ControlFlow {
        javaMethod.setKind("JavaMethod");
        javaMethod.registerMethod(javaMethod.runtime.newJavaMethod("returns a list of the keywords this method takes", new WithNoArguments("keywords") {
                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());

                    return context.runtime.newList(new ArrayList<Object>());
                }
            }));
        javaMethod.registerMethod(javaMethod.runtime.newJavaMethod("returns the code for the argument definition", new WithNoArguments("argumentsCode") {
                @Override
                public Object activate(IokeObject self, IokeObject dynamicContext, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(dynamicContext, message, on, new ArrayList<Object>(), new HashMap<String, Object>());

                    IokeData data = IokeObject.data(on);
                    if(data instanceof JavaMethod) {
                        return dynamicContext.runtime.newText(((JavaMethod)data).getArgumentsCode());
                    } else {
                        return dynamicContext.runtime.newText(((AssociatedCode)data).getArgumentsCode());
                    }
                }
            }));
    }

    public abstract DefaultArgumentsDefinition getArguments();

    public String getArgumentsCode() {
        return getArguments().getCode(false);
    }

    @Override
    public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
        List<Object> args = new ArrayList<Object>();
        Map<String, Object> keywords = new HashMap<String, Object>();
        getArguments().getEvaluatedArguments(context, message, on, args, keywords);
        return activate(self, on, args, keywords, context, message);
    }

    public Object activate(IokeObject self, Object on, List<Object> args,
            Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
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
        condition.setCell("report", context.runtime.newText("You tried to activate a method without any code - did you by any chance activate the JavaMethod kind by referring to it without wrapping it inside a call to cell?"));
        context.runtime.errorCondition(condition);

        return self.runtime.nil;
    }
    
    private String getDominantClassName() {
        String name = getClass().getName();
        int dollar = name.indexOf("$");
        int dot = name.lastIndexOf(".");
        if(dollar == -1) {
            dollar = name.length();
        }
        return name.substring(dot+1, dollar);
    }

    @Override
    public String inspect(Object self) {
        return "method(" + getDominantClassName() + ((name != null) ? ("_" + name) : "") + ")";
    }
}

