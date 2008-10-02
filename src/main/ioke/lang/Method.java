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
    private Context context;
    private List<String> argumentNames;
    private Message code;

    public Method(Runtime runtime) {
        super(runtime);
    }

    public Method(Runtime runtime, Context context, List<String> argumentNames, Message code) {
        this(runtime);
        if(runtime.method != null) {
            this.mimics(runtime.method);
        }

        this.context = context;
        this.argumentNames = argumentNames;
        this.code = code;
    }

    public void init() {
    }

    public boolean isActivatable() {
        return true;
    }

    // TODO: make this use a real model later, with argument names etc
    public IokeObject activate(Context context, Message message, IokeObject on) {
        return code.evaluateCompleteWith(new Context(runtime, on), on);
    }
}// Method
