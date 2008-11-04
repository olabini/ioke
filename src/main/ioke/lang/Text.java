/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.exceptions.ControlFlow;

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

        obj.registerMethod(obj.runtime.newJavaMethod("takes one argument, that can be either an index or a range of two indicis. this slicing works the same as for Lists, so you can index from the end, both with the single index and with the range.", new JavaMethod("[]") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    IokeData data = IokeObject.data(arg);
                    
                    if(data instanceof Range) {
                        String str = getText(on);
                        int len = str.length();

                        int from = Number.extractInt(((Range)data).getFrom(), message, context);
                        int to = Number.extractInt(((Range)data).getTo(), message, context);
                        boolean inclusive = ((Range)data).isInclusive();
                        
                        if(from < 0) {
                            from = len + 1 + from;
                        }

                        if(to < 0) {
                            to = len + 1 + to;
                        }
                        
                        if(!inclusive) {
                            to--;
                        }

                        return context.runtime.newText(str.substring(from, to));
                    } else if(data instanceof Number) {
                        String str = getText(on);
                        int len = str.length();

                        int ix = ((Number)data).asJavaInteger();
                        if(ix < 0) {
                            ix = len + ix;
                        }

                        return context.runtime.newNumber(str.charAt(ix));
                    }

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
    public boolean isEqualTo(IokeObject self, Object other) {
        return ((other instanceof IokeObject) && 
                (IokeObject.data(other) instanceof Text) 
                && this.text.equals(((Text)IokeObject.data(other)).text));
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
