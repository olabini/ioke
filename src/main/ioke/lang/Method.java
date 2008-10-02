/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.List;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Method extends IokeObject {
    String name;
    private Context context;
    private List<String> argumentNames;
    private Message code;

    public Method(Runtime runtime, String name, String documentation) {
        super(runtime, documentation);
        this.name = name;
    }

    public Method(Runtime runtime, Context context, List<String> argumentNames, Message code) {
        this(runtime, null, null);
        if(runtime.method != null) {
            this.mimics(runtime.method);
        }

        this.context = context;
        this.argumentNames = argumentNames;
        this.code = code;
        // TODO: Add documentation here
    }

    public void init() {
        registerMethod(new JavaMethod(runtime, "name", "returns the name of the method") {
                public IokeObject activate(Context context, Message message, IokeObject on) {
                    return new Text(runtime, ((Method)on).name);
                }
            });
    }

    public boolean isActivatable() {
        return true;
    }

    // TODO: make this use a real model later, with argument names etc
    public IokeObject activate(Context context, Message message, IokeObject on) {
        return code.evaluateCompleteWith(new Context(runtime, on, "Method activation context for " + message.getName()), on);
    }

    public String toString() {
        if(this == runtime.method) {
            return "Method-origin";
        }
        return "Method<" + name + ">";
    }
}// Method
