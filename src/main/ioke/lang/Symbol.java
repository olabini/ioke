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
    public void init(IokeObject obj) throws ControlFlow {
        obj.setKind("Symbol");
        obj.mimics(IokeObject.as(obj.runtime.mixins.getCell(null, null, "Comparing")), obj.runtime.nul, obj.runtime.nul);

        obj.registerMethod(obj.runtime.newJavaMethod("Returns a text representation of the object", new JavaMethod("asText") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    return method.runtime.newText(Symbol.getText(on));
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("Returns a text inspection of the object", new JavaMethod("inspect") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    return method.runtime.newText(Symbol.getInspect(on));
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("Returns a brief text inspection of the object", new JavaMethod("notice") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    return method.runtime.newText(Symbol.getInspect(on));
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("compares this symbol against the argument, returning -1, 0 or 1 based on which one is lexically larger", new JavaMethod("<=>") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    if(!(IokeObject.data(arg) instanceof Symbol)) {
                        arg = IokeObject.convertToSymbol(arg, message, context);
                    }
                    return context.runtime.newNumber(Symbol.getText(on).compareTo(Symbol.getText(arg)));
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

    public static String getInspect(Object on) {
        return ((Symbol)(IokeObject.data(on))).inspect(on);
    }

    public String getText() {
        return text;
    }

    @Override
    public boolean isSymbol() {
        return true;
    }
    
    @Override
    public IokeObject convertToSymbol(IokeObject self, IokeObject m, IokeObject context) {
        return self;
    }

    @Override
    public IokeObject convertToText(IokeObject self, IokeObject m, IokeObject context) {
        return self.runtime.newText(getText());
    }

    @Override
    public IokeObject tryConvertToText(IokeObject self, IokeObject m, IokeObject context) {
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

    public static boolean onlyGoodChars(Object sym) {
        String text = Symbol.getText(sym);
        return !(text.length() == 0 || BAD_CHARS.matcher(text).find());
    }

    public String inspect(Object obj) {
        if(!onlyGoodChars(obj)) {
            return ":\"" + text + "\"";
        } else {
            return ":" + text;
        }
    }
}// Symbol
