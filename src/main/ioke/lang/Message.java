/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.io.Reader;
import java.io.StringReader;

import java.util.List;
import java.util.ArrayList;
import java.util.Map;

import org.antlr.runtime.tree.Tree;

import ioke.lang.parser.iokeLexer;
import ioke.lang.parser.iokeParser;
import ioke.lang.parser.Levels;

import ioke.lang.exceptions.ControlFlow;

import org.antlr.runtime.ANTLRReaderStream;
import org.antlr.runtime.CommonTokenStream;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Message extends IokeData {
    public static enum Type {MESSAGE, DETACH, TERMINATOR, SEPARATOR, START_INTERPOLATION, START_RE_INTERPOLATION, END_INTERPOLATION, MIDDLE_INTERPOLATION};

    private String name;
    private String file;
    private int line;
    private int pos;
    private Type type = Type.MESSAGE;

    private List<Object> arguments = new ArrayList<Object>();

    public IokeObject next;
    public IokeObject prev;

    private Object cached = null;

    public Message(Runtime runtime, String name) {
        this(runtime, name, null, Type.MESSAGE);
    }

    Message(Runtime runtime, String name, Type type) {
        this(runtime, name, null, type);
    }

    public Message(Runtime runtime, String name, Object arg1) {
        this(runtime, name, arg1, Type.MESSAGE);
    }

    public Message(Runtime runtime, String name, Object arg1, Type type) {
        this.type = type;
        this.name = name;

        this.file = ((IokeSystem)IokeObject.data(runtime.system)).currentFile();

        if(arg1 != null) {
            arguments.add(arg1);
        }
    }

    public static Message wrap(Object cachedResult, Runtime runtime) {
        return wrap("cachedResult", cachedResult, runtime);
    }

    public static Message wrap(IokeObject cachedResult) {
        return wrap("cachedResult", cachedResult, cachedResult.runtime);
    }

    public static Message wrap(String name, Object cachedResult, Runtime runtime) {
        Message m = new Message(runtime, name);
        m.cached = cachedResult;
        return m;
    }

    public static boolean isTerminator(Object message) {
        return ((Message)IokeObject.data(message)).type == Type.TERMINATOR;
    }

    public static void cacheValue(Object message, Object cachedValue) throws ControlFlow {
        ((Message)IokeObject.data(message)).cached = cachedValue;
    }

    public static void addArg(Object message, Object arg) throws ControlFlow {
        IokeObject.as(message, null).getArguments().add(arg);
    }

    public static IokeObject copy(Object message) throws ControlFlow {
        IokeObject copy = IokeObject.as(message, null).mimic(null, null);
        copySourceLocation(message, copy);
        Message.setPrev(copy, Message.prev(message));
        Message.setNext(copy, Message.next(message));
        return copy;
    }

    public static IokeObject deepCopy(Object message) throws ControlFlow {
        IokeObject copy = IokeObject.as(message, null).mimic(null, null);
        copySourceLocation(message, copy);
        Message orgMsg = (Message)IokeObject.data(message);
        Message copyMsg = (Message)IokeObject.data(copy);
        
        copyMsg.type = orgMsg.type;
        copyMsg.cached = orgMsg.cached;

        List<Object> newArgs = new ArrayList<Object>();
        for(Object arg : orgMsg.arguments) {
            if((arg instanceof IokeObject) && IokeObject.isMessage(arg)) {
                newArgs.add(deepCopy(arg));
            } else {
                newArgs.add(arg);
            }
        }
        copyMsg.arguments = newArgs;

        if(orgMsg.next != null) {
            copyMsg.next = deepCopy(orgMsg.next);
            Message.setPrev(orgMsg.next, copy);
        }

        return copy;
    }

    public static void copySourceLocation(Object from, Object to) throws ControlFlow {
        Message.setFile(to, Message.file(from));
        Message.setLine(to, Message.line(from));
        Message.setPosition(to, Message.position(from));
    }

    public static Object getArg1(IokeObject message) {
        return ((Message)IokeObject.data(message)).arguments.get(0);
    }

    public static Object getArg2(IokeObject message) {
        return ((Message)IokeObject.data(message)).arguments.get(1);
    }

    public static Type type(IokeObject message) {
        return ((Message)IokeObject.data(message)).type;
    }

    public static void setType(IokeObject message, Type type) {
        ((Message)IokeObject.data(message)).type = type;
    }

    public static String getStackTraceText(Object _message) throws ControlFlow {
        IokeObject message = IokeObject.as(_message, null);
        IokeObject start = message;
        
        while(prev(start) != null && prev(start).getLine() == message.getLine()) {
            start = prev(start);
        }

        String s1 = code(start);

        int ix = s1.indexOf("\n");
        if(ix > -1) {
            ix--;
        }
        
        return String.format(" %-48.48s %s", 
                             (ix == -1 ? s1 : s1.substring(0,ix)),
                             "[" + message.getFile() + ":" + message.getLine() + ":" + message.getPosition() + "]");
    }

    @Override
    public void init(final IokeObject message) throws ControlFlow {
        message.setKind("Message");
        message.mimics(IokeObject.as(message.runtime.mixins.getCell(null, null, "Enumerable"), null), message.runtime.nul, message.runtime.nul);

        message.registerMethod(message.runtime.newJavaMethod("Returns a code representation of the object", new TypeCheckingJavaMethod.WithNoArguments("code", message) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return method.runtime.newText(((Message)IokeObject.data(on)).code());
                }
            }));

        message.registerMethod(message.runtime.newJavaMethod("Returns the unevaluated arguments for this message", new TypeCheckingJavaMethod.WithNoArguments("arguments", message) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return context.runtime.newList(((Message)IokeObject.data(on)).arguments);
                }
            }));
        
        message.registerMethod(message.runtime.newJavaMethod("Returns a formatted code representation of the object", new TypeCheckingJavaMethod.WithNoArguments("formattedCode", message) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return method.runtime.newText(Message.formattedCode(IokeObject.as(on, context), 0));
                }
            }));
        
        message.registerMethod(message.runtime.newJavaMethod("returns the name of this message", new TypeCheckingJavaMethod.WithNoArguments("name", message) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return method.runtime.getSymbol(((Message)IokeObject.data(on)).name);
                }
            }));

        message.registerMethod(message.runtime.newJavaMethod("takes either one or two arguments. if one argument is given, it should be a message chain that will be sent to each message in the chain, recursively. the result will be thrown away. if two arguments are given, the first is an unevaluated name that will be set to each of the messages in the chain in succession, and then the second argument will be evaluated in a scope with that argument in it. the code will evaluate in a lexical context, and if the argument name is available outside the context, it will be shadowed. the method will return the original message.", new JavaMethod("walk") {
            private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                .builder()
                .withOptionalPositionalUnevaluated("argOrCode")
                .withOptionalPositionalUnevaluated("code")
                .getArguments();

            @Override
            public DefaultArgumentsDefinition getArguments() {
                return ARGUMENTS;
            }

            @Override
            public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                getArguments().checkArgumentCount(context, message, on);

                Object onAsMessage = context.runtime.message.convertToThis(on, message, context);

                switch(message.getArgumentCount()) {
                case 1: {
                    IokeObject code = IokeObject.as(message.getArguments().get(0), context);
                    walkWithReceiver(context, onAsMessage, code);

                    break;
                }
                case 2: {
                    LexicalContext c = new LexicalContext(context.runtime, context, "Lexical activation context for Message#walk", message, context);
                    String name = IokeObject.as(message.getArguments().get(0), context).getName();
                    IokeObject code = IokeObject.as(message.getArguments().get(1), context);

                    walkWithoutExplicitReceiver(onAsMessage, c, name, code);
                    break;
                }
                }
                return onAsMessage;

            }

            private void walkWithoutExplicitReceiver(Object onAsMessage, LexicalContext c, String name, IokeObject code) throws ControlFlow {
                Object o = onAsMessage;
                while(o != null) {
                    c.setCell(name, o);
                    code.evaluateCompleteWithoutExplicitReceiver(c, c.getRealContext());
                    for (Object arg : ((IokeObject)o).getArguments()) {
                        walkWithoutExplicitReceiver(arg, c, name, code);
                    }
                    o = next(o);
                }
            }

            private void walkWithReceiver(IokeObject context, Object onAsMessage, IokeObject code) throws ControlFlow {
                Object o = onAsMessage;
                while(o != null) {
                    code.evaluateCompleteWithReceiver(context, context.getRealContext(), o);
                    for (Object arg : ((IokeObject)o).getArguments()) {
                        walkWithReceiver(context, arg, code);
                    }
                    o = next(o);
                }
            }
        }));

        message.registerMethod(message.runtime.newJavaMethod("takes either one or two or three arguments. if one argument is given, it should be a message chain that will be sent to each message in the chain. the result will be thrown away. if two arguments are given, the first is an unevaluated name that will be set to each of the messages in the chain in succession, and then the second argument will be evaluated in a scope with that argument in it. if three arguments is given, the first one is an unevaluated name that will be set to the index of each message, and the other two arguments are the name of the argument for the value, and the actual code. the code will evaluate in a lexical context, and if the argument name is available outside the context, it will be shadowed. the method will return the original message.", new JavaMethod("each") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositionalUnevaluated("indexOrArgOrCode")
                    .withOptionalPositionalUnevaluated("argOrCode")
                    .withOptionalPositionalUnevaluated("code")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    Object onAsMessage = context.runtime.message.convertToThis(on, message, context);
                    
                    Runtime runtime = context.runtime;
                    switch(message.getArgumentCount()) {
                    case 1: {
                        IokeObject code = IokeObject.as(message.getArguments().get(0), context);
                        Object o = onAsMessage;
                        while(o != null) {
                            code.evaluateCompleteWithReceiver(context, context.getRealContext(), o);
                            o = next(o);
                        }

                        break;
                    }
                    case 2: {
                        LexicalContext c = new LexicalContext(context.runtime, context, "Lexical activation context for List#each", message, context);
                        String name = IokeObject.as(message.getArguments().get(0), context).getName();
                        IokeObject code = IokeObject.as(message.getArguments().get(1), context);

                        Object o = onAsMessage;
                        while(o != null) {
                            c.setCell(name, o);
                            code.evaluateCompleteWithoutExplicitReceiver(c, c.getRealContext());
                            o = next(o);
                        }
                        break;
                    }
                    case 3: {
                        LexicalContext c = new LexicalContext(context.runtime, context, "Lexical activation context for List#each", message, context);
                        String iname = IokeObject.as(message.getArguments().get(0), context).getName();
                        String name = IokeObject.as(message.getArguments().get(1), context).getName();
                        IokeObject code = IokeObject.as(message.getArguments().get(2), context);

                        int index = 0;
                        Object o = onAsMessage;
                        while(o != null) {
                            c.setCell(name, o);
                            c.setCell(iname, runtime.newNumber(index++));
                            code.evaluateCompleteWithoutExplicitReceiver(c, c.getRealContext());
                            o = next(o);
                        }
                        break;
                    }
                    }
                    return onAsMessage;
                }
            }));

        message.registerMethod(message.runtime.newJavaMethod("sets the name of the message and then returns that name", new TypeCheckingJavaMethod("name=") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(message)
                    .withRequiredPositional("newName")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    Object o = args.get(0);
                    String name = null;
                    if(IokeObject.data(o) instanceof Symbol) {
                        name = Symbol.getText(o); 
                    } else if(IokeObject.data(o) instanceof Text) {
                        name = Text.getText(o);
                    } else {
                        name = Text.getText(IokeObject.convertToText(o, message, context, true));
                    }
                    
                    Message.setName(IokeObject.as(on, context), name);
                    return o;
                }
            }));

        message.registerMethod(message.runtime.newJavaMethod("sets the next pointer of the message and then returns that pointer", new TypeCheckingJavaMethod("next=") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(message)
                    .withRequiredPositional("newNext")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    Object o = args.get(0);
                    if(o == context.runtime.nil) {
                        Message.setNext(IokeObject.as(on, context), null);
                    } else {
                        o = context.runtime.message.convertToThis(o, message, context);
                        Message.setNext(IokeObject.as(on, context), IokeObject.as(o, context));
                    }
                    return o;
                }
            }));
        
        message.registerMethod(message.runtime.newJavaMethod("sets the prev pointer of the message and then returns that pointer", new TypeCheckingJavaMethod("prev=") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(message)
                    .withRequiredPositional("newPrev")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    Object o = args.get(0);
                    if(o == context.runtime.nil) {
                        Message.setPrev(IokeObject.as(on, context), null);
                    } else {
                        o = context.runtime.message.convertToThis(o, message, context);
                        Message.setPrev(IokeObject.as(on, context), IokeObject.as(o, context));
                    }
                    return o;
                }
            }));
        
        message.registerMethod(message.runtime.newJavaMethod("returns the file name where this message is written", new TypeCheckingJavaMethod.WithNoArguments("filename", message) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return method.runtime.newText(((Message)IokeObject.data(on)).file);
                }
            }));
        
        message.registerMethod(message.runtime.newJavaMethod("returns the line where this message is written", new TypeCheckingJavaMethod.WithNoArguments("line", message) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return method.runtime.newNumber(((Message)IokeObject.data(on)).line);
                }
            }));
        
        message.registerMethod(message.runtime.newJavaMethod("returns the position on the line where this message is written", new TypeCheckingJavaMethod.WithNoArguments("position", message) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return method.runtime.newNumber(((Message)IokeObject.data(on)).pos);
                }
            }));

        message.registerMethod(message.runtime.newJavaMethod("returns the next message in the chain, or nil", new TypeCheckingJavaMethod.WithNoArguments("next", message) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    IokeObject next = ((Message)IokeObject.data(on)).next;
                    if(next == null) {
                        return context.runtime.nil;
                    } else {
                        return next;
                    }
                }
            }));
        
        message.registerMethod(message.runtime.newJavaMethod("returns the last message in the chain", new TypeCheckingJavaMethod.WithNoArguments("last", message) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    IokeObject current = IokeObject.as(on, context);
                    while(next(current) != null) {
                        current = next(current);
                    }
                    return current;
                }
            }));
        
        message.registerMethod(message.runtime.newJavaMethod("returns the previous message in the chain, or nil", new TypeCheckingJavaMethod.WithNoArguments("prev", message) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    IokeObject prev = ((Message)IokeObject.data(on)).prev;
                    if(prev == null) {
                        return context.runtime.nil;
                    } else {
                        return prev;
                    }
                }
            }));
        
        message.registerMethod(message.runtime.newJavaMethod("returns true when this message is a terminator, otherwise false", new TypeCheckingJavaMethod.WithNoArguments("terminator?", message) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return Message.isTerminator(on) ? context.runtime._true : context.runtime._false;
                }
            }));
        
        message.registerMethod(message.runtime.newJavaMethod("returns a string that describes this message as a stack trace elemtn", new TypeCheckingJavaMethod.WithNoArguments("asStackTraceText", message) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return context.runtime.newText(Message.getStackTraceText(on));
                }
            }));

        message.registerMethod(message.runtime.newJavaMethod("returns a deep clone of this message chain, starting at the current point.", new TypeCheckingJavaMethod.WithNoArguments("deepCopy", message) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return Message.deepCopy(on);
                }
            }));

        message.registerMethod(message.runtime.newJavaMethod("returns true if this message is a keyword parameter or not", new TypeCheckingJavaMethod.WithNoArguments("keyword?", message) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return ((Message)IokeObject.data(on)).isKeyword() ? context.runtime._true : context.runtime._false;
                }
            }));

        message.registerMethod(message.runtime.newJavaMethod("returns true if this message is a symbol message or not", new TypeCheckingJavaMethod.WithNoArguments("symbol?", message) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return ((Message)IokeObject.data(on)).isSymbol() ? context.runtime._true : context.runtime._false;
                }
            }));

        message.registerMethod(message.runtime.newJavaMethod("Takes one evaluated argument and sends this message to that argument", new JavaMethod("sendTo") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("newReceiver")
                    .withOptionalPositional("context", "nil")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    IokeObject realReceiver = IokeObject.as(args.get(0), context);
                    IokeObject realContext = realReceiver;
                    if(args.size() > 1) {
                        realContext = IokeObject.as(args.get(1), context);
                    }

                    return IokeObject.as(on, context).sendTo(realContext, realReceiver);
                }
            }));
        
        message.registerMethod(message.runtime.newJavaMethod("evaluates the argument and adds it to the argument list of this message. it then returns the receiving message.", new JavaMethod("appendArgument") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("newArgument")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    IokeObject.as(on, context).getArguments().add(args.get(0));
                    return on;
                }
            }));

        message.aliasMethod("appendArgument", "<<", null, null);

        message.registerMethod(message.runtime.newJavaMethod("evaluates the argument and adds it to the beginning of the argument list of this message. it then returns the receiving message.", new JavaMethod(">>") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("newArgument")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    IokeObject.as(on, context).getArguments().add(0, args.get(0));
                    return on;
                }
            }));

        message.registerMethod(message.runtime.newJavaMethod("evaluates the argument and makes it the new next pointer of the receiver. it also modifies the argument so its prev pointer points back to this message. if the argument is nil, the next pointer will be erased. it then returns the receiving message.", new TypeCheckingJavaMethod("->") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(message)
                    .withRequiredPositional("nextMessage")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    Object arg = args.get(0);
                    if(arg == context.runtime.nil) {
                        Message.setNext(IokeObject.as(on, context), null);
                    } else {
                        arg = context.runtime.message.convertToThis(arg, message, context);
                        Message.setNext(IokeObject.as(on, context), IokeObject.as(arg, context));
                        Message.setPrev(IokeObject.as(arg, context), IokeObject.as(on, context));
                    }
                    return arg;
                }
            }));

        message.registerMethod(message.runtime.newJavaMethod("Takes one or more evaluated arguments and sends this message chain to where the first argument is ground, and if there are more arguments, the second is the receiver, and the rest will be the arguments", new JavaMethod("evaluateOn") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("ground")
                    .withOptionalPositional("receiver", "ground")
                    .withRest("arguments")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    IokeObject messageGround = IokeObject.as(args.get(0), context);
                    IokeObject receiver = messageGround;
                    int size = args.size();
                    if(size > 1) {
                        receiver = IokeObject.as(args.get(1), context);
                        if(size > 2) {
                            IokeObject m = IokeObject.as(on, context).allocateCopy(IokeObject.as(on, context), context);
                            m.getArguments().clear();
                            m.getArguments().addAll(args.subList(2, size));
                            on = m;
                        }
                    }
                    
                    return IokeObject.as(on, context).evaluateCompleteWithReceiver(messageGround, messageGround, receiver);
                }
            }));
        
        message.registerMethod(message.runtime.newJavaMethod("takes one index, and a context and returns the evaluated argument at that index.", new JavaMethod("evalArgAt") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("argumentIndex")
                    .withRequiredPositional("context")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    int index = Number.extractInt(args.get(0), message, context);
                    IokeObject newContext = IokeObject.as(args.get(1), context);
                    return IokeObject.as(on, context).getEvaluatedArgument(index, newContext);
                }
            }));
        
        message.registerMethod(message.runtime.newJavaMethod("Will rearrange this message and all submessages to follow regular C style operator precedence rules. Will use Message OperatorTable to guide this operation. The operation is mutating, but should not change anything if done twice.", new JavaMethod.WithNoArguments("shuffleOperators") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Levels levels = new Levels(IokeObject.as(on, context), context, message);
                    List<IokeObject> expressions = new ArrayList<IokeObject>();
                    if(on instanceof IokeObject) {
                        expressions.add(0, IokeObject.as(on, context));

                        while(expressions.size() > 0) {
                            IokeObject n = expressions.remove(0);
                            do {
                                levels.attach(n, expressions);
                                for(Object o : n.getArguments()) {
                                    if(o instanceof IokeObject) { //Otherwise a pure String parameter to internal:createText
                                        expressions.add(0, IokeObject.as(o, context));
                                    }
                                }
                            } while((n = Message.next(n)) != null);
                        
                            levels.nextMessage(expressions);
                        }
                    }

                    return on;
                }
            }));

        message.registerMethod(message.runtime.newJavaMethod("Takes one evaluated argument and returns the message resulting from parsing and operator shuffling the resulting message.", new TypeCheckingJavaMethod("fromText") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .withRequiredPositional("code").whichMustMimic(message.runtime.text)
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    String code = Text.getText(args.get(0));
                    return Message.newFromStream(context.runtime, new StringReader(code), message, context);
                }
            }));

        message.registerMethod(message.runtime.newJavaMethod("Takes one evaluated argument and returns a message that wraps the value of that argument.", new JavaMethod("wrap") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("value")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return context.runtime.createMessage(Message.wrap(IokeObject.as(args.get(0), context)));
                }
            }));

        message.registerMethod(message.runtime.newJavaMethod("Takes one evaluated argument and executes the contents of that text in the current context and returns the result of that.", new TypeCheckingJavaMethod("doText") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .withRequiredPositional("code").whichMustMimic(message.runtime.text)
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    String code = Text.getText(args.get(0));
                    return context.runtime.evaluateString(code, message, context);
                }
            }));
    }

    public static void setName(IokeObject message, String name) {
        ((Message)IokeObject.data(message)).name = name;
    }

    public static void setArguments(IokeObject message, List<Object> arguments) {
        ((Message)IokeObject.data(message)).arguments = arguments;
    }

    public static void setFile(IokeObject message, String file) {
        ((Message)IokeObject.data(message)).file = file;
    }

    public static void setLine(IokeObject message, int line) {
        ((Message)IokeObject.data(message)).line = line;
    }

    public static void setPosition(IokeObject message, int position) {
        ((Message)IokeObject.data(message)).pos = position;
    }

    public static boolean isKeyword(Object message) {
        if((message instanceof IokeObject) && (IokeObject.data(message) instanceof Message)) {
            return ((Message)IokeObject.data(message)).isKeyword();
        } else {
            return false;
        }
    }

    public static boolean isSymbol(Object message) {
        if((message instanceof IokeObject) && (IokeObject.data(message) instanceof Message)) {
            return ((Message)IokeObject.data(message)).isSymbol();
        } else {
            return false;
        }
    }

    public static boolean hasName(Object message, String name) {
        if((message instanceof IokeObject) && (IokeObject.data(message) instanceof Message)) {
            return Message.name(message).equals(name);
        } else {
            return false;
        }
    }

    public boolean isKeyword() {
        return name.length() > 1 && arguments.size() == 0 && name.charAt(name.length()-1) == ':';
    }

    public boolean isSymbol() {
        return name.length() > 1 && name.charAt(0) == ':';
    }

    @Override
    public List<Object> getArguments(IokeObject self) {
        return arguments;
    }

    public void setArguments(List<Object> arguments) {
        this.arguments = arguments;
    }

    @Override
    public int getArgumentCount(IokeObject self) {
        return arguments.size();
    }

    public static String file(Object message) throws ControlFlow {
        return IokeObject.as(message, null).getFile();
    }

    public static int line(Object message) throws ControlFlow {
        return IokeObject.as(message, null).getLine();
    }

    public static int position(Object message) throws ControlFlow {
        return IokeObject.as(message, null).getPosition();
    }

    public static void setFile(Object message, String file) throws ControlFlow {
        ((Message)IokeObject.data(message)).file = file;
    }

    public static void setLine(Object message, int line) throws ControlFlow {
        ((Message)IokeObject.data(message)).line = line;
    }

    public static void setPosition(Object message, int pos) throws ControlFlow {
        ((Message)IokeObject.data(message)).pos = pos;
    }

    @Override
    public String getFile(IokeObject self) {
        return file;
    }

    @Override
    public int getLine(IokeObject self) {
        return line;
    }

    @Override
    public int getPosition(IokeObject self) {
        return pos;
    }

    void setFile(String file) {
        this.file = file;
    }

    void setLine(int line) {
        this.line = line;
    }

    void setPosition(int pos) {
        this.pos = pos;
    }

    @Override
    public IokeData cloneData(IokeObject obj, IokeObject message, IokeObject context) {
        Message m = new Message(obj.runtime, name);
        m.arguments = new ArrayList<Object>(((Message)IokeObject.data(obj)).arguments);
        m.type = ((Message)IokeObject.data(obj)).type;
        return m;
    }

    public void setNext(IokeObject next) {
        this.next = next;
    }

    public static void opShuffle(IokeObject self) throws ControlFlow {
        // TODO: Should handle stuff that's not been inited at this point...
        if(self != null) {
            self.runtime.opShuffle.sendTo(self.runtime.ground, self);
        }
    }

    public static IokeObject newFromStream(Runtime runtime, Reader reader, IokeObject message, IokeObject context) throws ControlFlow {
        try {
            iokeParser parser = new iokeParser(new CommonTokenStream(new iokeLexer(new ANTLRReaderStream(reader))));
//             System.err.println("parseFully ...");
            Tree t = parser.parseFully();
//                         System.err.println("t: " + t.toStringTree());
            if(t == null) {
                Message m = new Message(runtime, ".", null, Type.TERMINATOR);
                m.setLine(0);
                m.setPosition(0);
                return runtime.createMessage(m);
            }

            IokeObject m = fromTree(runtime, t);
//                         System.err.println("m: " + m);
//                          System.err.println("m1: " + m);
            opShuffle(m);
//                          System.err.println("m2: " + m);
            return m;
        } catch(Exception e) {
//             System.err.println(e);
//             System.err.println(e.getMessage());
//             e.printStackTrace();
                       runtime.reportJavaException(e, message, context);
            return null;
        }
    }
    

    public static IokeObject fromTree(Runtime runtime, Tree tree) throws ControlFlow {
        //        System.err.println(" fromTree(" + tree.toStringTree() + ")");
        Message m = null;
        int argStart = 0;
        if(!tree.isNil()) {
            switch(tree.getType()) {
            case iokeParser.RegexpLiteral: {
                String s = tree.getText();
                char first = s.charAt(0);
                char second = s.charAt(1);
                char last = s.charAt(s.length()-1);
                if(first == '#' && last != '{') {
                    if(second == 'r') {
                        int lastIndex = s.lastIndexOf(']');
                        m = new Message(runtime, "internal:createRegexp", s.substring(3, lastIndex));
                        m.arguments.add(s.substring(lastIndex+1));
                    } else {
                        int lastIndex = s.lastIndexOf('/');
                        m = new Message(runtime, "internal:createRegexp", s.substring(2, lastIndex));
                        m.arguments.add(s.substring(lastIndex+1));
                    }
                    m.setLine(tree.getLine());
                    m.setPosition(tree.getCharPositionInLine());
                    return runtime.createMessage(m);
                } else if(first == '}' && last == '{') {
                    m = new Message(runtime, "internal:createText", s.substring(1, s.length()-2), Type.MIDDLE_INTERPOLATION);
                    m.setLine(tree.getLine());
                    m.setPosition(tree.getCharPositionInLine());
                    return runtime.createMessage(m);
                } else if(first == '}') {
                    int lastIndex = s.lastIndexOf('/');
                    if(lastIndex == -1) {
                        lastIndex = s.lastIndexOf(']');
                    }
                    m = new Message(runtime, "internal:createRegexp", s.substring(1, lastIndex), Type.END_INTERPOLATION);
                    m.arguments.add(s.substring(lastIndex+1));
                    m.setLine(tree.getLine());
                    m.setPosition(tree.getCharPositionInLine());
                    return runtime.createMessage(m);
                } else {
                    m = new Message(runtime, "internal:createText", s.substring(2, s.length()-2), Type.START_RE_INTERPOLATION);
                    m.setLine(tree.getLine());
                    m.setPosition(tree.getCharPositionInLine());
                    return runtime.createMessage(m);
                }
            }
            case iokeParser.StringLiteral: {
                String s = tree.getText();
                char first = s.charAt(0);
                char last = s.charAt(s.length()-1);
                if(first == '"' && last == '"') {
                    m = new Message(runtime, "internal:createText", s.substring(1, s.length()-1));
                    m.setLine(tree.getLine());
                    m.setPosition(tree.getCharPositionInLine());
                    return runtime.createMessage(m);
                } else if(first == '#' && last == ']') {
                    m = new Message(runtime, "internal:createText", s.substring(2, s.length()-1));
                    m.setLine(tree.getLine());
                    m.setPosition(tree.getCharPositionInLine());
                    return runtime.createMessage(m);
                } else {
                    if(first == '}' && (last == '"' || last == ']')) { // This is an ending
                        m = new Message(runtime, "internal:createText", s.substring(1, s.length()-1), Type.END_INTERPOLATION);
                        m.setLine(tree.getLine());
                        m.setPosition(tree.getCharPositionInLine());
                        return runtime.createMessage(m);
                    } else if(first == '"') { // This is a beginning
                        m = new Message(runtime, "internal:createText", s.substring(1, s.length()-2), Type.START_INTERPOLATION);
                        m.setLine(tree.getLine());
                        m.setPosition(tree.getCharPositionInLine());
                        return runtime.createMessage(m);
                    } else if(first == '#') { // This is a beginning
                        m = new Message(runtime, "internal:createText", s.substring(2, s.length()-2), Type.START_INTERPOLATION);
                        m.setLine(tree.getLine());
                        m.setPosition(tree.getCharPositionInLine());
                        return runtime.createMessage(m);
                    } else { // This is in the middle
                        m = new Message(runtime, "internal:createText", s.substring(1, s.length()-2), Type.MIDDLE_INTERPOLATION);
                        m.setLine(tree.getLine());
                        m.setPosition(tree.getCharPositionInLine());
                        return runtime.createMessage(m);
                    }
                }
            }
            case iokeParser.NumberLiteral:
                m = new Message(runtime, "internal:createNumber", tree.getText());
                m.setLine(tree.getLine());
                m.setPosition(tree.getCharPositionInLine());
                return runtime.createMessage(m);
            case iokeParser.DecimalLiteral:
                m = new Message(runtime, "internal:createDecimal", tree.getText());
                m.setLine(tree.getLine());
                m.setPosition(tree.getCharPositionInLine());
                return runtime.createMessage(m);
            case iokeParser.UnitLiteral: {
                String text = tree.getText();
                int ending = text.length()-1;
                while(!Character.isDigit(text.charAt(ending))) {
                    ending--;
                }
                Message mex = new Message(runtime, "internal:createNumber", text.substring(0, ending+1));
                mex.setLine(tree.getLine());
                mex.setPosition(tree.getCharPositionInLine());
                m = new Message(runtime, "internal:createUnit", runtime.createMessage(mex));
                m.setLine(tree.getLine());
                m.setPosition(tree.getCharPositionInLine());
                return runtime.createMessage(m);
            }
            case iokeParser.UnitDecimalLiteral: {
                String text = tree.getText();
                int ending = text.length()-1;
                while(!Character.isDigit(text.charAt(ending))) {
                    ending--;
                }
                Message mex = new Message(runtime, "internal:createDecimal", text.substring(0, ending+1));
                mex.setLine(tree.getLine());
                mex.setPosition(tree.getCharPositionInLine());
                m = new Message(runtime, "internal:createUnit", mex);
                m.setLine(tree.getLine());
                m.setPosition(tree.getCharPositionInLine());
                return runtime.createMessage(m);
            }
            case iokeParser.Identifier:
                m = new Message(runtime, tree.getText());
                m.setLine(tree.getLine());
                m.setPosition(tree.getCharPositionInLine());
                return runtime.createMessage(m);
            case iokeParser.Terminator:
                m = new Message(runtime, ".", null, Type.TERMINATOR);
                m.setLine(tree.getLine());
                m.setPosition(tree.getCharPositionInLine());
                return runtime.createMessage(m);
            case iokeParser.Comma:
                m = new Message(runtime, ",", null, Type.SEPARATOR);
                m.setLine(tree.getLine());
                m.setPosition(tree.getCharPositionInLine());
                return runtime.createMessage(m);
            case iokeParser.MESSAGE: {
                String text = tree.getChild(0).getText();
                m = new Message(runtime, text);
                int count = tree.getChildCount();
                argStart = 1;
                if(count > 1) {
                    int diff = tree.getChild(1).getCharPositionInLine() - (tree.getCharPositionInLine()+text.length());
                    if(diff != 0) {
                        m.type = Type.DETACH;
                    }
                    argStart = 2;
                }

                break;
            }
            default:
                java.lang.System.err.println("NOOOO: Can't handle " + tree + " : " + tree.getType());
                return null;
            }

            m.setLine(tree.getLine());
            m.setPosition(tree.getCharPositionInLine());
        } 

        IokeObject mx = m == null ? (IokeObject)null : runtime.createMessage(m);

        IokeObject head = null;
        List<IokeObject> currents = new ArrayList<IokeObject>();

        List<List<IokeObject>> oldCurrents = new ArrayList<List<IokeObject>>();
        List<IokeObject> oldHeads = new ArrayList<IokeObject>();
        List<IokeObject> oldMx = new ArrayList<IokeObject>();

        for(int i=argStart,j=tree.getChildCount(); i<j; i++) {
            IokeObject created = fromTree(runtime, tree.getChild(i));

            switch(Message.type(created)) {
            case START_INTERPOLATION:{
                Message mvv = new Message(runtime, "internal:concatenateText");
                mvv.setLine(tree.getLine());
                mvv.setPosition(tree.getCharPositionInLine());
                oldCurrents.add(0, currents);
                oldHeads.add(0, head);
                oldMx.add(0, mx);

                currents = new ArrayList<IokeObject>();
                head = created;
                mx = runtime.createMessage(mvv);

                created = runtime.createMessage(new Message(runtime, ",", null, Type.SEPARATOR));
                break;
            }
            case START_RE_INTERPOLATION:{
                Message mvv = new Message(runtime, "internal:compositeRegexp");
                mvv.setLine(tree.getLine());
                mvv.setPosition(tree.getCharPositionInLine());
                oldCurrents.add(0, currents);
                oldHeads.add(0, head);
                oldMx.add(0, mx);

                currents = new ArrayList<IokeObject>();
                head = created;
                mx = runtime.createMessage(mvv);

                created = runtime.createMessage(new Message(runtime, ",", null, Type.SEPARATOR));
                break;
            }
            case MIDDLE_INTERPOLATION:
                mx.getArguments().add(head);

                currents.clear();
                head = created;

                created = runtime.createMessage(new Message(runtime, ",", null, Type.SEPARATOR));
                break;
            case END_INTERPOLATION:
                mx.getArguments().add(head);
                mx.getArguments().add(created);

                currents = oldCurrents.remove(0);
                head = oldHeads.remove(0);
                created = mx;
                mx = oldMx.remove(0);
                break;
            }

            if(Message.type(created) == Type.TERMINATOR && head == null && currents.size() == 0) {
                continue;
            }

            if(Message.type(created) == Type.SEPARATOR && mx != null) {
                mx.getArguments().add(head);
                currents.clear();
                head = null;
            } else {
                if(Message.type(created) == Type.TERMINATOR && currents.size() > 1) {
                    while(currents.size() > 1) {
                        currents.remove(0);
                    }
                }
                Message.setPrev(created, currents.size() > 0 ? currents.get(0) : null);

                if(head == null && Message.type(created) != Type.TERMINATOR) {
                    head = created;
                }

                if(currents.size() > 0) {
                    Message.setNextOfLast(currents.get(0), created);
                    currents.set(0, created);
                } else {
                    currents.add(0, created);
                }
            }
        }

        if(mx != null && head != null) {
            mx.getArguments().add(head);
        }

        return mx == null ? head : mx;
    }

    public static String name(Object o) {
        return ((Message)IokeObject.data(o)).name;
    }

    public static List<Object> arguments(Object o) {
        return ((Message)IokeObject.data(o)).arguments;
    }

    @Override
    public String getName(IokeObject self) {
        return name;
    }

    @Override
    public boolean isMessage() {
        return true;
    }

    public static Object getEvaluatedArgument(Object argument, IokeObject context) throws ControlFlow {
        if(!(argument instanceof IokeObject)) {
            return argument;
        }

        IokeObject o = IokeObject.as(argument, context);
        if(!o.isMessage()) {
            return o;
        }

        return o.evaluateCompleteWithoutExplicitReceiver(context, context.getRealContext());
    }

    @Override
    public Object getEvaluatedArgument(IokeObject self, int index, IokeObject context) throws ControlFlow {
        return Message.getEvaluatedArgument(arguments.get(index), context);
    }

    @Override
    public List<Object> getEvaluatedArguments(IokeObject self, IokeObject context) throws ControlFlow {
        List<Object> args = new ArrayList<Object>(arguments.size());
        for(Object o : arguments) {
            args.add(getEvaluatedArgument(o, context));
        }
        return args;
    }

    @Override
    public Object sendTo(IokeObject self, IokeObject context, Object recv) throws ControlFlow {
        if(cached != null) {
            return cached;
        }

        return IokeObject.perform(recv, context, self);
    }

    @Override
    public Object sendTo(IokeObject self, IokeObject context, Object recv, Object argument) throws ControlFlow {
        if(cached != null) {
            return cached;
        }

        IokeObject m = self.allocateCopy(self, context);
        m.mimicsWithoutCheck(context.runtime.message);
        m.getArguments().clear();
        m.getArguments().add(argument);
        return IokeObject.perform(recv, context, m);
    }

    @Override
    public Object sendTo(IokeObject self, IokeObject context, Object recv, Object arg1, Object arg2) throws ControlFlow {
        if(cached != null) {
            return cached;
        }

        IokeObject m = self.allocateCopy(self, context);
        m.getArguments().clear();
        m.getArguments().add(arg1);
        m.getArguments().add(arg2);
        return IokeObject.perform(recv, context, m);
    }

    @Override
    public Object sendTo(IokeObject self, IokeObject context, Object recv, List<Object> args) throws ControlFlow {
        if(cached != null) {
            return cached;
        }

        IokeObject m = self.allocateCopy(self, context);
        m.getArguments().clear();
        m.getArguments().addAll(args);
        return IokeObject.perform(recv, context, m);
    }

    @Override
    public Object evaluateComplete(IokeObject self) throws ControlFlow {
        return evaluateCompleteWith(self, self.runtime.getGround());
    }

    @Override
    public Object evaluateCompleteWith(IokeObject self, IokeObject ctx, Object ground) throws ControlFlow {
        return evaluateCompleteWithReceiver(self, ctx, ground, ctx);
    }

    @Override
    public Object evaluateCompleteWithReceiver(IokeObject self, IokeObject ctx, Object ground, Object receiver) throws ControlFlow {
        Object current = receiver;
        Object tmp = null;
        Object lastReal = self.runtime.getNil();
        IokeObject m = self;
        while(m != null) {
            String name = m.getName();

            if(name.equals(".")) {
                current = ctx;
            } else if(name.length() > 0 && m.getArguments().size() == 0 && name.charAt(0) == ':') {
                current = self.runtime.getSymbol(name.substring(1));
                Message.cacheValue(m, current);
                lastReal = current;
            } else {
                tmp = m.sendTo(ctx, current);
                if(tmp != null) {
                    current = tmp;
                    lastReal = current;
                }
            }
            m = Message.next(m);
        }
        return lastReal;
    }

    @Override
    public Object evaluateCompleteWithoutExplicitReceiver(IokeObject self, IokeObject ctx, Object ground) throws ControlFlow {
        return evaluateCompleteWith(self, ctx, ctx);
    }

    @Override
    public Object evaluateCompleteWith(IokeObject self, Object ground) throws ControlFlow {
        return evaluateCompleteWith(self, IokeObject.as(ground, self), IokeObject.getRealContext(ground));
    }

    public static String code(IokeObject message) {
        if(message == null) {
            return "";
        }
        return ((Message)IokeObject.data(message)).code();
    }

    public static String formattedCode(IokeObject message, int indent) throws ControlFlow {
        if(message == null) {
            return "";
        }
        return ((Message)IokeObject.data(message)).formattedCode(indent);
    }

    public String code() {
        StringBuilder base = new StringBuilder();

        currentCode(base);
        
        if(next != null) {
            if(this.type != Type.TERMINATOR) {
                base.append(" ");
            }

            base.append(Message.code(next));
        }

        return base.toString();
    }

    public String formattedCode(int indent) throws ControlFlow {
        StringBuilder base = new StringBuilder();

        currentFormattedCode(base, indent);
        
        if(next != null) {
            if(this.type != Type.TERMINATOR) {
                base.append(" ");
            }

            base.append(Message.formattedCode(next, indent));
        }

        return base.toString();
    }

    public static IokeObject prev(Object message) {
        return ((Message)IokeObject.data(message)).prev;
    }

    public static IokeObject next(Object message) {
        return ((Message)IokeObject.data(message)).next;
    }

    public static void setPrev(IokeObject message, IokeObject prev) {
        ((Message)IokeObject.data(message)).prev = prev;
    }

    public static void setNext(IokeObject message, IokeObject next) {
        ((Message)IokeObject.data(message)).next = next;
    }

    public static void setNextOfLast(IokeObject message, IokeObject next) {
        while(next(message) != null) {
            message = next(message);
        }
        ((Message)IokeObject.data(message)).next = next;
    }

    public static String thisCode(IokeObject message) {
        return ((Message)IokeObject.data(message)).thisCode();
    }

    public static String codeSequenceTo(IokeObject message, String name) throws ControlFlow {
        return ((Message)IokeObject.data(message)).codeSequenceTo(name);
    }

    public String thisCode() {
        StringBuilder base = new StringBuilder();

        currentCode(base);
        
        return base.toString();
    }

    private void currentCode(StringBuilder base) {
        if(this.name.equals("internal:createText") && (this.arguments.get(0) instanceof String)) {
            base.append('"').append(this.arguments.get(0)).append('"');
        } else if(this.name.equals("internal:createRegexp") && (this.arguments.get(0) instanceof String)) {
            base.append("#/").append(this.arguments.get(0)).append('/').append(this.arguments.get(1));
        } else if(this.name.equals("internal:createNumber") && (this.arguments.get(0) instanceof String)) {
            base.append(this.arguments.get(0));
        } else if(this.name.equals("internal:createDecimal") && (this.arguments.get(0) instanceof String)) {
            base.append(this.arguments.get(0));
        } else if(cached != null && this.name.equals("cachedResult")) {
            base.append(cached);
        } else if(this.type == Type.TERMINATOR) {
            base.append(".\n");
        } else {
            base.append(this.name);
            if(arguments.size() > 0 || this.name.length() == 0) {
                base.append("(");
                String sep = "";
                for(Object o : arguments) {
                    if(!(o instanceof IokeObject) || !(IokeObject.data(o) instanceof Message)) {
                        base.append(sep).append(o);
                    } else {
                        base.append(sep).append(Message.code((IokeObject)o));
                    }

                    sep = ", ";
                }
                base.append(")");
            }
        }
    }

    private void currentFormattedCode(StringBuilder base, int indent) throws ControlFlow {
        if(this.name.equals("internal:createText") && (this.arguments.get(0) instanceof String)) {
            base.append('"').append(this.arguments.get(0)).append('"');
        } else if(this.name.equals("internal:concatenateText")) {
            base.append('"');
            for(int i=0;i<this.arguments.size();i++) {
                Object arg = this.arguments.get(i);
                if(Message.name(arg).equals("internal:createText") && (Message.arguments(arg).get(0) instanceof String)) {
                    base.append(Message.arguments(arg).get(0));
                } else {
                    base.append("#{");
                    base.append(Message.formattedCode(IokeObject.as(arg, null), 0));
                    base.append("}");
                }
            }
            base.append('"');
        } else if(this.name.equals("internal:createRegexp") && (this.arguments.get(0) instanceof String)) {
            base.append("#/").append(this.arguments.get(0)).append('/').append(this.arguments.get(1));
        } else if(this.name.equals("internal:createNumber") && (this.arguments.get(0) instanceof String)) {
            base.append(this.arguments.get(0));
        } else if(this.name.equals("internal:createDecimal") && (this.arguments.get(0) instanceof String)) {
            base.append(this.arguments.get(0));
        } else if(cached != null && this.name.equals("cachedResult")) {
            base.append(cached);
        } else if(this.name.equals("=")) {
            base.append(this.arguments.get(0));
            base.append(" = ");
            base.append(Message.formattedCode(IokeObject.as(this.arguments.get(1), null), indent+2));
        } else if(this.type == Type.TERMINATOR) {
            base.append("\n");
            for(int i=0;i<indent;i++) {
                base.append(" ");
            }
        } else {
            base.append(this.name);
            int theLine = line;
            if(arguments.size() > 0 || this.name.length() == 0) {
                base.append("(");
                String sep = "";
                for(Object o : arguments) {
                    base.append(sep);

                    if(o instanceof String) {
                        base.append(o);
                    } else {
                        if(Message.line(o) != theLine) {
                            int diff = Message.line(o) - theLine;
                            theLine += diff;
                            base.append("\n");
                            for(int i=0;i<(indent+2);i++) {
                                base.append(" ");
                            }
                        }

                        base.append(Message.formattedCode(IokeObject.as(o, null), indent+2));
                    }

                    sep = ", ";
                }
                base.append(")");
            }
        }
    }


    public String codeSequenceTo(String name) throws ControlFlow {
        if(this.name.equals(name)) {
            return "";
        } 

        StringBuilder base = new StringBuilder();

        currentCode(base);
        
        if(next != null && !next.getName().equals(name)) {
            base.append(" ");
            base.append(Message.codeSequenceTo(next, name));
        }

        return base.toString();

    }

    @Override
    public String toString(IokeObject self) {
        return code();
    }
}// Message
