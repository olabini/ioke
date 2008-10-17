/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Text extends IokeData {
    private String text;

    public Text(String text) {
        this.text = text;
    }

    @Override
    public void init(IokeObject obj) {
        obj.setKind("Text");
        obj.registerMethod(new JavaMethod(obj.runtime, "asText", "Returns a text representation of the object") {
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
