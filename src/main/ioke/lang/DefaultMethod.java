/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.List;

import ioke.lang.exceptions.MismatchedArgumentCount;
import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class DefaultMethod extends Method {
    private List<String> argumentNames;
    private IokeObject code;

    public DefaultMethod(String name) {
        super(name);
    }

    public DefaultMethod(IokeObject context, List<String> argumentNames, IokeObject code) {
        super(context);
        this.argumentNames = argumentNames;
        this.code = code;
    }

    @Override
    public void init(IokeObject defaultMethod) {
        defaultMethod.setKind("DefaultMethod");
    }

    // TODO: make this use a real model later, with argument names etc
    @Override
    public IokeObject activate(IokeObject self, IokeObject context, IokeObject message, IokeObject on) throws ControlFlow {
        int argCount = message.getArguments().size();
        if(argCount != argumentNames.size()) {
            throw new MismatchedArgumentCount(message, argumentNames.size(), argCount, on, context);
        }
        
        Context c = new Context(self.runtime, on, "Method activation context for " + message.getName(), message, context);

        for(int i=0; i<argCount; i++) {
            c.setCell(argumentNames.get(i), message.getEvaluatedArgument(i, context));
        }

        return code.evaluateCompleteWith(c, on);
    }
}// DefaultMethod
