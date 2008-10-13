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
        super(runtime, runtime.text.documentation);
        this.mimics(runtime.text);
        this.text = text;
    }

    public Text(Runtime runtime, String text, String description) {
        super(runtime, description);
        if(runtime.text != null) {
            this.mimics(runtime.text);
        }
        this.text = text;
    }

    @Override
    IokeObject allocateCopy(Message m, IokeObject context) {
        return new Text(runtime, text);
    }

    public void init() {
        registerMethod(new JavaMethod(runtime, "asText", "Returns a text representation of the object") {
                public IokeObject activate(IokeObject context, Message message, IokeObject on) {
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
