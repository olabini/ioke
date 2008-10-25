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
    }

    // TODO: make this use a real model later, with argument names etc
    @Override
    public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
        Context c = new Context(self.runtime, on, "Method activation context for " + message.getName(), message, context);

        arguments.assignArgumentValues(c, context, message, on);

        return code.evaluateCompleteWith(c, on);
    }
}// DefaultMethod
