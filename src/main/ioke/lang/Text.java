/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Text extends IokeObject {
    private String text;

    public Text(Runtime runtime, String text) {
        super(runtime);
        if(runtime.text != null) {
            this.mimics(runtime.text);
        }
        this.text = text;
    }

    IokeObject allocateCopy() {
        return new Text(runtime, text);
    }

    public void init() {
        registerMethod("println", new JavaMethod(runtime) {
                public IokeObject activate(Context context, Message message, IokeObject on) {
                    runtime.getOut().println(runtime.asString.sendTo(context, on).toString());
                    runtime.getOut().flush();
                    return runtime.getNil();
                }
            });
        registerMethod("asString", new JavaMethod(runtime) {
                public IokeObject activate(Context context, Message message, IokeObject on) {
                    return on;
                }
            });
    }

    public String getText() {
        return text;
    }

    public String toString() {
        return text;
    }
}// Text
