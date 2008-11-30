/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

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

        obj.registerMethod(obj.runtime.newJavaMethod("Returns a text inspection of the object", new JavaMethod("inspect") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    return method.runtime.newText(Text.getInspect(on));
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("Returns a brief text inspection of the object", new JavaMethod("notice") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    return method.runtime.newText(Text.getInspect(on));
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("Returns the length of this text", new JavaMethod("length") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    return context.runtime.newNumber(getText(on).length());
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("Takes any number of arguments, and expects the text receiver to contain format specifications. The currently supported specifications are only %s and %{, %}. These have several parameters that can be used. See the spec for more info about these. The format method will return a new text based on the content of the receiver, and the arguments given.", new JavaMethod("format") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> positionalArgs = new ArrayList<Object>();
                    Map<String, Object> keywordArgs = new HashMap<String, Object>();
                    DefaultArgumentsDefinition.getEvaluatedArguments(message, context, positionalArgs, keywordArgs);

                    String format = Text.getText(on);
                    int argIndex = 0;
                    int formatIndex = 0;
                    int justify = 0;
                    boolean negativeJustify = false;
                    boolean doAgain = false;
                    int argCount = positionalArgs.size();
                    int formatLength = format.length();
                    StringBuilder result = new StringBuilder();

                    while(formatIndex < formatLength) {
                        char c = format.charAt(formatIndex++);
                        switch(c) {
                        case '%':
                            justify = 0;
                            do {
                                doAgain = false;
                                c = format.charAt(formatIndex++);
                                switch(c) {
                                case 's':
                                    // TODO: missing argument
                                    Object arg = positionalArgs.get(argIndex++);
                                    Object txt = IokeObject.tryConvertToText(arg, message, context);
                                    if(txt == null) {
                                        txt = context.runtime.asText.sendTo(context, arg);
                                    }
                                    String outTxt = Text.getText(txt);

                                    if(outTxt.length() < justify) {
                                        int missing = justify - outTxt.length();
                                        char[] spaces = new char[missing];
                                        java.util.Arrays.fill(spaces, ' ');
                                        if(negativeJustify) {
                                            result.append(outTxt);
                                            result.append(spaces);
                                        } else {
                                            result.append(spaces);
                                            result.append(outTxt);
                                        }
                                    } else {
                                        result.append(outTxt);
                                    }
                                    break;
                                case '0':
                                case '1':
                                case '2':
                                case '3':
                                case '4':
                                case '5':
                                case '6':
                                case '7':
                                case '8':
                                case '9':
                                    justify *= 10;
                                    justify += (c - '0');
                                    doAgain = true;
                                    break;
                                case '-':
                                    negativeJustify = !negativeJustify;
                                    doAgain = true;
                                    break;
                                default:
                                    // TODO: unknown format specifier
                                    break;
                                }
                            } while(doAgain);
                            break;
                        default:
                            result.append(c);
                            break;
                        }
                    }
                    return context.runtime.newText(result.toString());
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

    public static String getInspect(Object on) {
        return ((Text)(IokeObject.data(on))).inspect(on);
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
    public IokeObject tryConvertToText(IokeObject self, IokeObject m, IokeObject context) {
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

    public String inspect(Object obj) {
        // This should obviously have more stuff later for escaping and so on.
        return "\"" + text + "\"";
    }
}// Text
