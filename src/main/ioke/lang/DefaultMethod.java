/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.ArrayList;
import java.util.List;

import ioke.lang.exceptions.MismatchedArgumentCount;
import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class DefaultMethod extends Method {
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

    }

    @Override
    public String getCode() {
        String args = arguments.getCode();
        return "method(" + args + Message.code(code) + ")";
    }

    @Override
    public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
        IokeObject c = context.runtime.locals.mimic(message, context);
        //        Context c = new Context(self.runtime, on, "Method activation context for " + message.getName(), message, context);
        
        c.setCell("self", on);
        c.setCell("@", on);
        c.setCell("currentMessage", on);
        c.setCell("surroundingContext", context);

        arguments.assignArgumentValues(c, context, message, on);

        return code.evaluateCompleteWith(c, on);
    }
}// DefaultMethod
