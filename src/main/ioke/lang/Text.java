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

    public void init() {
        registerMethod("println", new JavaMethod(runtime) {
                public IokeObject activate(Message message, IokeObject on) {
                    runtime.getOut().println(runtime.asString.sendTo(on).toString());
                    runtime.getOut().flush();
                    return runtime.getNil();
                }
            });
        registerMethod("asString", new JavaMethod(runtime) {
                public IokeObject activate(Message message, IokeObject on) {
                    return on;
                }
            });
    }

    public String toString() {
        return text;
    }
}// Text
