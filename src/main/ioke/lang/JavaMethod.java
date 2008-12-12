/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.ArrayList;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class JavaMethod extends Method {
    public JavaMethod(String name) {
        super(name);
    }

    @Override
    public void init(IokeObject javaMethod) {
        javaMethod.setKind("JavaMethod");
        javaMethod.registerMethod(javaMethod.runtime.newJavaMethod("returns a list of the keywords this method takes", new JavaMethod("keywords") {
                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) {
                    return context.runtime.newList(new ArrayList<Object>());
                }
            }));
    }

    @Override
    public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
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

