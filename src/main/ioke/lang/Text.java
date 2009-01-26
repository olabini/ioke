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

import org.jregex.Pattern;
import org.jregex.RETokenizer;
import org.jregex.Replacer;

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

        final Runtime runtime = obj.runtime;

        obj.setKind("Text");
        obj.mimics(IokeObject.as(obj.runtime.mixins.getCell(null, null, "Comparing")), obj.runtime.nul, obj.runtime.nul);

        obj.registerMethod(obj.runtime.newJavaMethod("Returns a text representation of the object", new JavaMethod.WithNoArguments("asText") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return on;
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("Converts the content of this text into a rational value", new TypeCheckingJavaMethod.WithNoArguments("toRational", runtime.text) {
                @Override
                public Object activate(IokeObject self, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return Text.toRational(on, context, message);
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("Converts the content of this text into a decimal value", new TypeCheckingJavaMethod.WithNoArguments("toDecimal", runtime.text) {
                @Override
                public Object activate(IokeObject self, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return Text.toDecimal(on, context, message);
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

        obj.registerMethod(obj.runtime.newJavaMethod("Returns a lower case version of this text", new TypeCheckingJavaMethod.WithNoArguments("lower", runtime.text) {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getValidatedArgumentsAndReceiver(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return method.runtime.newText(Text.getText(on).toLowerCase());
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("Returns an upper case version of this text", new TypeCheckingJavaMethod.WithNoArguments("upper", runtime.text) {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getValidatedArgumentsAndReceiver(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return method.runtime.newText(Text.getText(on).toUpperCase());
                }
            }));
        
        obj.registerMethod(obj.runtime.newJavaMethod("Returns a version of this text with leading and trailing whitespace removed", new TypeCheckingJavaMethod.WithNoArguments("trim", runtime.text) {
            @Override
            public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
              getArguments().getValidatedArgumentsAndReceiver(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
              return method.runtime.newText(Text.getText(on).trim());
            }
          }));

        obj.registerMethod(obj.runtime.newJavaMethod("Returns an array of texts split around the argument", new TypeCheckingJavaMethod("split") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(runtime.text)
                    .withRequiredPositional("splitAround")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }
                
                @Override
                public Object activate(IokeObject self, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());
                    String real = Text.getText(on);
                    Object arg = args.get(0);

                    List<Object> r = new ArrayList<Object>();
                    Pattern p = null;
                    if(IokeObject.data(arg) instanceof Regexp) {
                        p = Regexp.getRegexp(arg);
                    } else {
                        String around = Text.getText(arg);
                        p = new Pattern(Pattern.quote(around));
                    }

                    RETokenizer tok = new RETokenizer(p, real);
                    tok.setEmptyEnabled(true);
                    while(tok.hasMore()) {
                        r.add(context.runtime.newText(tok.nextToken()));
                    }

                    return context.runtime.newList(r);
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("Takes two text arguments where the first is the substring to replace, and the second is the replacement to insert. Will only replace the first match, if any is found, and return a new Text with the result.", new TypeCheckingJavaMethod("replace") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(runtime.text)
                    .withRequiredPositional("pattern")
                    .withRequiredPositional("replacement")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }
                
                @Override
                public Object activate(IokeObject self, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());
                    String initial = Text.getText(on);
                    String repl = Text.getText(args.get(1));

                    Object arg = args.get(0);

                    Pattern pat = null;
                    if(IokeObject.data(arg) instanceof Regexp) {
                        pat = Regexp.getRegexp(arg);
                    } else {
                        String around = Text.getText(arg);
                        pat = new Pattern(Pattern.quote(around));
                    }

                    Replacer r = pat.replacer(repl);
                    String result = r.replaceFirst(initial);

                    return context.runtime.newText(result);
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("Takes two text arguments where the first is the substring to replace, and the second is the replacement to insert. Will replace all matches, if any is found, and return a new Text with the result.", new TypeCheckingJavaMethod("replaceAll") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(runtime.text)
                    .withRequiredPositional("pattern")
                    .withRequiredPositional("replacement")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }
                
                @Override
                public Object activate(IokeObject self, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());
                    String initial = Text.getText(on);
                    String repl = Text.getText(args.get(1));

                    Object arg = args.get(0);

                    Pattern pat = null;
                    if(IokeObject.data(arg) instanceof Regexp) {
                        pat = Regexp.getRegexp(arg);
                    } else {
                        String around = Text.getText(arg);
                        pat = new Pattern(Pattern.quote(around));
                    }

                    Replacer r = pat.replacer(repl);
                    String result = r.replace(initial);

                    return context.runtime.newText(result);
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("Returns the length of this text", new TypeCheckingJavaMethod.WithNoArguments("length", runtime.text) {
                @Override
                public Object activate(IokeObject self, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return context.runtime.newNumber(getText(on).length());
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("Takes any number of arguments, and expects the text receiver to contain format specifications. The currently supported specifications are only %s and %{, %}. These have several parameters that can be used. See the spec for more info about these. The format method will return a new text based on the content of the receiver, and the arguments given.", new TypeCheckingJavaMethod("format") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(runtime.text)
                    .withRest("replacements")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }
                
                @Override
                public Object activate(IokeObject self, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    StringBuilder result = new StringBuilder();
                    Text.format(on, message, context, args, result);

                    return context.runtime.newText(result.toString());
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("compares this text against the argument, returning -1, 0 or 1 based on which one is lexically larger", new TypeCheckingJavaMethod("<=>") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(runtime.text)
                    .withRequiredPositional("other")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject self, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());
                    Object arg = args.get(0);

                    if(!(IokeObject.data(arg) instanceof Text)) {
                        arg = IokeObject.convertToText(arg, message, context, false);
                        if(!(IokeObject.data(arg) instanceof Text)) {
                            // Can't compare, so bail out
                            return context.runtime.nil;
                        }
                    }

                    if(on == context.runtime.text || arg == context.runtime.text) {
                        if(on == arg) {
                            return context.runtime.newNumber(0);
                        }
                        return context.runtime.nil;
                    }

                    int result = Text.getText(on).compareTo(Text.getText(arg));
                    if(result < 0) {
                        result = -1;
                    } else if(result > 0) {
                        result = 1;
                    }

                    return context.runtime.newNumber(result);
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("takes one argument, that can be either an index or a range of two indicis. this slicing works the same as for Lists, so you can index from the end, both with the single index and with the range.", new TypeCheckingJavaMethod("[]") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(runtime.text)
                    .withRequiredPositional("index")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject self, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
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
        
        obj.registerMethod(obj.runtime.newJavaMethod("Returns a symbol representing the Unicode category of the character", new JavaMethod.WithNoArguments("category") {
            @Override
            public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                String character = getText(on);
                if(character.length() == 1) {
                  return context.runtime.getSymbol(Character.UnicodeBlock.of(character.codePointAt(0)).toString());                  
                }
                
                final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition, 
                                                                                   message,
                                                                                   context,
                                                                                   "Error",
                                                                                   "Default")).mimic(message, context);
                condition.setCell("message", message);
                condition.setCell("context", context);
                condition.setCell("receiver", on);
                condition.setCell("text", context.runtime.newText("Text does not contain exactly one character"));

                runtime.errorCondition(condition);
                return null;
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
        boolean splatPairs = false;
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
                        case ':':
                            splatPairs = true;
                            doAgain = true;
                            break;
                        case ']':
                            return formatIndex;
                        case '[':
                            arg = positionalArgs.get(argIndex++);
                            final int startLoop = formatIndex;
                            final int[] endLoop = new int[]{-1};
                            final boolean doSplat = splat;
                            final boolean doSplatPairs = splatPairs;
                            splat = false;
                            splatPairs = false;
                            context.runtime.each.sendTo(context, arg, context.runtime.createMessage(new Message(context.runtime, "internal:collectDataForText#format") { 
                                    private Object doEvaluation(IokeObject ctx, Object ground, Object receiver) throws ControlFlow {
                                        List<Object> args = null;
                                        if(doSplat) {
                                            args = IokeList.getList(receiver);
                                        } else if(doSplatPairs) {
                                            args = Arrays.asList(Pair.getFirst(receiver), Pair.getSecond(receiver));
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

    public static Object toRational(Object on, IokeObject context, IokeObject message) throws ControlFlow {
        final String tvalue = getText(on);
        try {
            return context.runtime.newNumber(tvalue);
        } catch(NumberFormatException e) {
            final Runtime runtime = context.runtime;
            final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition, 
                                                                               message, 
                                                                               context, 
                                                                               "Error", 
                                                                               "Arithmetic",
                                                                               "NotParseable")).mimic(message, context);
            condition.setCell("message", message);
            condition.setCell("context", context);
            condition.setCell("receiver", on);
            condition.setCell("text", on);

            final Object[] newCell = new Object[]{null};

            runtime.withRestartReturningArguments(new RunnableWithControlFlow() {
                    public void run() throws ControlFlow {
                        runtime.errorCondition(condition);
                    }}, 
                context,
                new Restart.ArgumentGivingRestart("useValue") { 
                    public String report() {
                        return "Use number instead of " + tvalue;
                    }

                    public List<String> getArgumentNames() {
                        return new ArrayList<String>(Arrays.asList("newValue"));
                    }

                    public IokeObject invoke(IokeObject context, List<Object> arguments) throws ControlFlow {
                        newCell[0] = arguments.get(0);
                        return context.runtime.nil;
                    }
                },
                new Restart.ArgumentGivingRestart("takeLongest") { 
                    public String report() {
                        return "Parse the longest number possible from " + tvalue;
                    }

                    public List<String> getArgumentNames() {
                        return new ArrayList<String>();
                    }

                    public IokeObject invoke(IokeObject context, List<Object> arguments) throws ControlFlow {
                        int ix = 0;
                        int len = tvalue.length();
                        outer: while(ix < len) {
                            char c = tvalue.charAt(ix);
                            switch(c) {
                            case '-':
                            case '+':
                                if(ix != 0) {
                                    break outer;
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
                                break;
                            default:
                                break outer;
                            }
                            ix++;
                        }

                        newCell[0] = context.runtime.newNumber(tvalue.substring(0, ix));
                        return context.runtime.nil;
                    }
                }
                );

            return newCell[0];
        }
    }

    public static Object toDecimal(Object on, IokeObject context, IokeObject message) throws ControlFlow {
        final String tvalue = getText(on);
        try {
            return context.runtime.newDecimal(tvalue);
        } catch(NumberFormatException e) {
            final Runtime runtime = context.runtime;
            final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition, 
                                                                               message, 
                                                                               context, 
                                                                               "Error", 
                                                                               "Arithmetic",
                                                                               "NotParseable")).mimic(message, context);
            condition.setCell("message", message);
            condition.setCell("context", context);
            condition.setCell("receiver", on);
            condition.setCell("text", on);

            final Object[] newCell = new Object[]{null};

            runtime.withRestartReturningArguments(new RunnableWithControlFlow() {
                    public void run() throws ControlFlow {
                        runtime.errorCondition(condition);
                    }}, 
                context,
                new Restart.ArgumentGivingRestart("useValue") { 
                    public String report() {
                        return "Use number instead of " + tvalue;
                    }

                    public List<String> getArgumentNames() {
                        return new ArrayList<String>(Arrays.asList("newValue"));
                    }

                    public IokeObject invoke(IokeObject context, List<Object> arguments) throws ControlFlow {
                        newCell[0] = arguments.get(0);
                        return context.runtime.nil;
                    }
                },
                new Restart.ArgumentGivingRestart("takeLongest") { 
                    public String report() {
                        return "Parse the longest number possible from " + tvalue;
                    }

                    public List<String> getArgumentNames() {
                        return new ArrayList<String>();
                    }

                    public IokeObject invoke(IokeObject context, List<Object> arguments) throws ControlFlow {
                        int ix = 0;
                        int len = tvalue.length();
                        boolean hadDot = false;
                        boolean hadE = false;
                        outer: while(ix < len) {
                            char c = tvalue.charAt(ix);
                            switch(c) {
                            case '-':
                            case '+':
                                if(ix != 0 && tvalue.charAt(ix-1) != 'e' && tvalue.charAt(ix-1) != 'E') {
                                    break outer;
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
                                break;
                            case '.':
                                if(hadDot || hadE) {
                                    break outer;
                                }
                                hadDot = true;
                                break;
                            case 'e':
                            case 'E':
                                if(hadE) {
                                    break outer;
                                }
                                hadE = true;
                                break;
                            default:
                                break outer;
                            }
                            ix++;
                        }

                        newCell[0] = context.runtime.newDecimal(tvalue.substring(0, ix));
                        return context.runtime.nil;
                    }
                }
                );

            return newCell[0];
        }
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
                && ((self == self.runtime.text || other == self.runtime.text) ? self == other :
                    this.text.equals(((Text)IokeObject.data(other)).text)));
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
