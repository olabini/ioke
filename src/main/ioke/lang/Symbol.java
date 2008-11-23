/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.regex.Pattern;

import ioke.lang.exceptions.ControlFlow;

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
    public void checkMimic(IokeObject obj, IokeObject m, IokeObject context) throws ControlFlow {
        final IokeObject condition = IokeObject.as(IokeObject.getCellChain(context.runtime.condition, 
                                                                           m, 
                                                                           context,
                                                                           "Error", 
                                                                           "CantMimicOddball")).mimic(m, context);
        condition.setCell("message", m);
        condition.setCell("context", context);
        condition.setCell("receiver", obj);
        context.runtime.errorCondition(condition);
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

    private final static Pattern BAD_CHARS = Pattern.compile("[=\\.:\\-\\+&|\\{\\[]");

    @Override
    public String inspect(IokeObject obj) {
        if(text.length() == 0 || BAD_CHARS.matcher(text).find()) {
            return ":\"" + text + "\"";
        } else {
            return ":" + text;
        }
    }
}// Symbol
