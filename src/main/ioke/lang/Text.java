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
    public void init(IokeObject obj) throws ControlFlow {
        obj.setKind("Text");
        obj.mimics(IokeObject.as(obj.runtime.mixins.getCell(null, null, "Comparing")), obj.runtime.nul, obj.runtime.nul);

        obj.registerMethod(obj.runtime.newJavaMethod("Returns a text representation of the object", new JavaMethod("asText") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    return on;
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("Returns the length of this text", new JavaMethod("length") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    return context.runtime.newNumber(getText(on).length());
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("compares this text against the argument, returning -1, 0 or 1 based on which one is lexically larger", new JavaMethod("<=>") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    if(!(IokeObject.data(arg) instanceof Text)) {
                        arg = IokeObject.convertToText(arg, message, context);
                    }
                    return context.runtime.newNumber(Text.getText(on).compareTo(Text.getText(arg)));
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("takes one argument, that can be either an index or a range of two indicis. this slicing works the same as for Lists, so you can index from the end, both with the single index and with the range.", new JavaMethod("[]") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    IokeData data = IokeObject.data(arg);
                    
                    if(data instanceof Range) {
                        int first = Number.extractInt(Range.getFrom(arg), message, context); 
                        
                        if(first < 0) {
                            return context.runtime.newText("");
                        }

                        int last = Number.extractInt(Range.getTo(arg), message, context);
                        boolean inclusive = Range.isInclusive(arg);

                        String str = getText(on);
                        int size = str.length();

                        if(last < 0) {
                            last = size + last;
                        }

                        if(last < 0) {
                            return context.runtime.newText("");
                        }

                        if(last >= size) {
                            
                            last = inclusive ? size-1 : size;
                        }

                        if(first > last || (!inclusive && first == last)) {
                            return context.runtime.newText("");
                        }
                        
                        if(!inclusive) {
                            last--;
                        }
                        
                        return context.runtime.newText(str.substring(first, last+1));
                    } else if(data instanceof Number) {
                        String str = getText(on);
                        int len = str.length();

                        int ix = ((Number)data).asJavaInteger();

                        if(ix < 0) {
                            ix = len + ix;
                        }

                        if(ix >= 0 && ix < len) {
                            return context.runtime.newNumber(str.charAt(ix));
                        } else {
                            return context.runtime.nil;
                        }
                    }

                    return on;
                }
            }));
    }

    public static String getText(Object on) {
        return ((Text)(IokeObject.data(on))).getText();
    }

    public static boolean isText(Object on) {
        return IokeObject.data(on) instanceof Text;
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
    public int hashCode(IokeObject self) {
        return this.text.hashCode();
    }

    @Override
    public String toString() {
        return text;
    }

    @Override
    public String toString(IokeObject obj) {
        return text;
    }

//     @Override
//     public String inspect(IokeObject obj) {
//         // This should obviously have more stuff later for escaping and so on.
//         return "\"" + text + "\"";
//     }
}// Text
