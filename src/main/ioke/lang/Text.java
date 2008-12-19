/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.Map;
import java.util.Arrays;

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

        obj.registerMethod(obj.runtime.newJavaMethod("Returns a text representation of the object", new JavaMethod.WithNoArguments("asText") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return on;
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("Returns a text inspection of the object", new JavaMethod.WithNoArguments("inspect") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return method.runtime.newText(Text.getInspect(on));
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("Returns a brief text inspection of the object", new JavaMethod.WithNoArguments("notice") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return method.runtime.newText(Text.getInspect(on));
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("Returns an array of texts split around the argument", new JavaMethod("split") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("splitAround")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }
                
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());
                    String around = Text.getText(args.get(0));
                    String real = Text.getText(on);
                    String[] results = real.split(around);
                    List<Object> r = new ArrayList<Object>(results.length);
                    for(String s : results) {
                        r.add(context.runtime.newText(s));
                    }

                    return context.runtime.newList(r);
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("Takes two text arguments where the first is the substring to replace, and the second is the replacement to insert. Will only replace the first match, if any is found, and return a new Text with the result.", new JavaMethod("replace") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("pattern")
                    .withRequiredPositional("replacement")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }
                
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());
                    String pat = Text.getText(args.get(0));
                    String repl = Text.getText(args.get(1));
                    String initial = Text.getText(on);

                    return context.runtime.newText(initial.replaceFirst(pat, repl));
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("Takes two text arguments where the first is the substring to replace, and the second is the replacement to insert. Will replace all matches, if any is found, and return a new Text with the result.", new JavaMethod("replaceAll") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("pattern")
                    .withRequiredPositional("replacement")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }
                
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());
                    String pat = Text.getText(args.get(0));
                    String repl = Text.getText(args.get(1));
                    String initial = Text.getText(on);

                    return context.runtime.newText(initial.replaceAll(pat, repl));
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("Returns the length of this text", new JavaMethod.WithNoArguments("length") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return context.runtime.newNumber(getText(on).length());
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("Takes any number of arguments, and expects the text receiver to contain format specifications. The currently supported specifications are only %s and %{, %}. These have several parameters that can be used. See the spec for more info about these. The format method will return a new text based on the content of the receiver, and the arguments given.", new JavaMethod("format") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRest("replacements")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }
                
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    StringBuilder result = new StringBuilder();
                    Text.format(on, message, context, args, result);

                    return context.runtime.newText(result.toString());
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("compares this text against the argument, returning -1, 0 or 1 based on which one is lexically larger", new JavaMethod("<=>") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("other")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());
                    Object arg = args.get(0);

                    if(!(IokeObject.data(arg) instanceof Text)) {
                        arg = IokeObject.convertToText(arg, message, context, false);
                        if(!(IokeObject.data(arg) instanceof Text)) {
                            // Can't compare, so bail out
                            return context.runtime.nil;
                        }
                    }
                    return context.runtime.newNumber(Text.getText(on).compareTo(Text.getText(arg)));
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("takes one argument, that can be either an index or a range of two indicis. this slicing works the same as for Lists, so you can index from the end, both with the single index and with the range.", new JavaMethod("[]") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("index")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());
                    Object arg = args.get(0);
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
    
    public static void format(Object on, IokeObject message, IokeObject context, List<Object> positionalArgs, StringBuilder result) throws ControlFlow {
        formatString(Text.getText(on), 0, message, context, positionalArgs, result);
    }

    private static int formatString(final String format, int index, final IokeObject message, final IokeObject context, List<Object> positionalArgs, final StringBuilder result) throws ControlFlow {
        int argIndex = 0;
        int formatIndex = index;
        int justify = 0;
        boolean splat = false;
        boolean negativeJustify = false;
        boolean doAgain = false;
        int argCount = positionalArgs.size();
        int formatLength = format.length();
        Object arg = null;
        StringBuilder missingText = new StringBuilder();

        while(formatIndex < formatLength) {
            char c = format.charAt(formatIndex++);
            switch(c) {
            case '%':
                justify = 0;
                missingText.append(c);
                do {
                    doAgain = false;
                    if(formatIndex < formatLength) {
                        c = format.charAt(formatIndex++);
                        missingText.append(c);
                        
                        switch(c) {
                        case '*':
                            splat = true;
                            doAgain = true;
                            break;
                        case ']':
                            return formatIndex;
                        case '[':
                            arg = positionalArgs.get(argIndex++);
                            final int startLoop = formatIndex;
                            final int[] endLoop = new int[]{-1};
                            final boolean doSplat = splat;
                            splat = false;
                            context.runtime.each.sendTo(context, arg, context.runtime.createMessage(new Message(context.runtime, "internal:collectDataForText#format") { 
                                    private Object doEvaluation(IokeObject ctx, Object ground, Object receiver) throws ControlFlow {
                                        List<Object> args = null;
                                        if(doSplat) {
                                            args = IokeList.getList(receiver);
                                        } else {
                                            args = Arrays.asList(receiver);
                                        }

                                        int newVal = formatString(format, startLoop, message, context, args, result);
                                        endLoop[0] = newVal;
                                        return ctx.runtime.nil;
                                    }
                                    @Override
                                    public Object evaluateCompleteWithReceiver(IokeObject self, IokeObject ctx, Object ground, Object receiver) throws ControlFlow {
                                        return doEvaluation(ctx, ground, receiver);
                                    }                                
                                    @Override
                                    public Object evaluateCompleteWith(IokeObject self, IokeObject ctx, Object ground) throws ControlFlow {
                                        return doEvaluation(ctx, ground, ctx);
                                    }                                
                                }));
                            if(endLoop[0] == -1) {
                                int opened = 1;
                                while(opened > 0 && formatIndex < formatLength) {
                                    char c2 = format.charAt(formatIndex++);
                                    if(c2 == '%' && formatIndex < formatLength) {
                                        c2 = format.charAt(formatIndex++);
                                        if(c2 == '[') {
                                            opened++;
                                        } else if(c2 == ']') {
                                            opened--;
                                        }
                                    }
                                }
                            } else {
                                formatIndex = endLoop[0];
                            }
                            break;
                        case 's':
                            // TODO: missing argument
                            arg = positionalArgs.get(argIndex++);
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
                            result.append(missingText);
                            missingText = new StringBuilder();
                            break;
                        }
                    } else {
                        result.append(missingText);
                        missingText = new StringBuilder();
                    }
                } while(doAgain);
                break;
            default:
                result.append(c);
                break;
            }
        }
        return formatLength;
    }
    
    @Override
    public IokeObject convertToText(IokeObject self, IokeObject m, IokeObject context, boolean signalCondition) {
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
