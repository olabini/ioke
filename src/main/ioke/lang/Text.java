/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Text extends IokeData {
    private final String text;

    public Text(String text) {
        this.text = text;
    }

    @Override
    public void init(IokeObject obj) {
        obj.setKind("Text");
        obj.registerMethod(obj.runtime.newJavaMethod("Returns a text representation of the object", new JavaMethod("asText") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    return on;
                }
            }));
    }

    public static String getText(Object on) {
        return ((Text)(IokeObject.data(on))).getText();
    }

    public String getText() {
        return text;
    }
    
    @Override
    public IokeObject convertToText(IokeObject self, IokeObject m, IokeObject context) {
        return self;
    }

    @Override
    public String toString() {
        return text;
    }

    @Override
    public String toString(IokeObject obj) {
        return text;
    }
}// Text
