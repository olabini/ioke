/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.List;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class DefaultMethod extends Method {
    private List<String> argumentNames;
    private Message code;

    public DefaultMethod(Runtime runtime, String name, String documentation) {
        super(runtime, name, documentation);
    }

    public DefaultMethod(Runtime runtime, Context context, List<String> argumentNames, Message code) {
        super(runtime, context);
        this.argumentNames = argumentNames;
        this.code = code;
        if(runtime.defaultMethod != null) {
            this.mimics(runtime.defaultMethod);
        }
    }

    public void init() {
    }

    // TODO: make this use a real model later, with argument names etc
    public IokeObject activate(Context context, Message message, IokeObject on) {
        return code.evaluateCompleteWith(new Context(runtime, on, "Method activation context for " + message.getName()), on);
    }
}// DefaultMethod
