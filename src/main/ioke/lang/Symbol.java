/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.exceptions.CantMimicOddballObject;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Symbol extends IokeData {
    private final String text;

    public Symbol(String text) {
        this.text = text;
    }

    @Override
    public void init(IokeObject obj) {
        obj.setKind("Symbol");
        obj.registerMethod(obj.runtime.newJavaMethod("Returns a text representation of the object", new JavaMethod("asText") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    return method.runtime.newText(Symbol.getText(on));
                }
            }));
    }

    @Override
    public void checkMimic(IokeObject obj, IokeObject m, IokeObject context) {
        throw new CantMimicOddballObject(m, obj, context);
    }

    public static String getText(Object on) {
        return ((Symbol)(IokeObject.data(on))).getText();
    }

    public String getText() {
        return text;
    }

    @Override
    public boolean isSymbol() {
        return true;
    }
    
    @Override
    public IokeObject convertToText(IokeObject self, IokeObject m, IokeObject context) {
        return self.runtime.newText(getText());
    }

    @Override
    public String toString() {
        return text;
    }

    @Override
    public String toString(IokeObject obj) {
        return text;
    }

    @Override
    public String representation(IokeObject obj) {
        return ":" + text;
    }
}// Symbol
