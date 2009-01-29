/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.io.IOException;
import java.io.Reader;
import java.io.BufferedReader;
import java.io.Writer;
import java.io.StringReader;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class IokeIO extends IokeData {
    protected Writer writer;
    protected BufferedReader reader;

    public IokeIO() {
        this(null, null);
    }

    public IokeIO(Writer writer) {
        this(null, writer);
    }

    public IokeIO(Reader reader) {
        this(reader, null);
    }

    public IokeIO(Reader reader, Writer writer) {
        if(null != reader) {
            if(reader instanceof BufferedReader) {
                this.reader = (BufferedReader)reader;
            } else {
                this.reader = new BufferedReader(reader);
            }
        }
        this.writer = writer;
    }

    public static Writer getWriter(Object arg) {
        return ((IokeIO)IokeObject.data(arg)).writer;
    }

    public static BufferedReader getReader(Object arg) {
        return ((IokeIO)IokeObject.data(arg)).reader;
    }
    
    @Override
    public void init(IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;

        obj.setKind("IO");

        obj.registerMethod(runtime.newJavaMethod("Prints a text representation of the argument and a newline to the current IO object", new TypeCheckingJavaMethod("println") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(runtime.io)
                    .withOptionalPositional("object", "nil")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    try {
                        if(args.size() > 0) {
                            Object arg = args.get(0);
                            IokeIO.getWriter(on).write(context.runtime.asText.sendTo(context, arg).toString());
                        }

                        IokeIO.getWriter(on).write("\n");
                        IokeIO.getWriter(on).flush();
                    } catch(IOException e) {
                        final Runtime runtime = context.runtime;
                        final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition, 
                                                                                           message, 
                                                                                           context, 
                                                                                           "Error", 
                                                                                           "IO"), context).mimic(message, context);
                        condition.setCell("message", message);
                        condition.setCell("context", context);
                        condition.setCell("receiver", on);
                        condition.setCell("exceptionMessage", runtime.newText(e.getMessage()));
                        List<Object> ob = new ArrayList<Object>();
                        for(StackTraceElement ste : e.getStackTrace()) {
                            ob.add(runtime.newText(ste.toString()));
                        }

                        condition.setCell("exceptionStackTrace", runtime.newList(ob));

                        runtime.withReturningRestart("ignore", context, new RunnableWithControlFlow() {
                                public void run() throws ControlFlow {
                                    runtime.errorCondition(condition);
                                }});
                    }

                    return context.runtime.getNil();
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Prints a text representation of the argument to the current IO object", new TypeCheckingJavaMethod("print") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(runtime.io)
                    .withRequiredPositional("object")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    Object arg = args.get(0);
                    try {
                        IokeIO.getWriter(on).write(context.runtime.asText.sendTo(context, arg).toString());
                        IokeIO.getWriter(on).flush();
                    } catch(IOException e) {
                        final Runtime runtime = context.runtime;
                        final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition, 
                                                                                           message, 
                                                                                           context, 
                                                                                           "Error", 
                                                                                           "IO"), context).mimic(message, context);
                        condition.setCell("message", message);
                        condition.setCell("context", context);
                        condition.setCell("receiver", on);
                        condition.setCell("exceptionMessage", runtime.newText(e.getMessage()));
                        List<Object> ob = new ArrayList<Object>();
                        for(StackTraceElement ste : e.getStackTrace()) {
                            ob.add(runtime.newText(ste.toString()));
                        }

                        condition.setCell("exceptionStackTrace", runtime.newList(ob));

                        runtime.withReturningRestart("ignore", context, new RunnableWithControlFlow() {
                                public void run() throws ControlFlow {
                                    runtime.errorCondition(condition);
                                }});
                    }

                    return context.runtime.getNil();
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("tries to read as much as possible and return a message chain representing what's been read", new TypeCheckingJavaMethod.WithNoArguments("read", runtime.io) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    try {
                        String line = IokeIO.getReader(on).readLine();
                        return Message.newFromStream(context.runtime, new StringReader(line), message, context);
                    } catch(IOException e) {
                        final Runtime runtime = context.runtime;
                        final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition, 
                                                                                           message, 
                                                                                           context, 
                                                                                           "Error", 
                                                                                           "IO"), context).mimic(message, context);
                        condition.setCell("message", message);
                        condition.setCell("context", context);
                        condition.setCell("receiver", on);
                        condition.setCell("exceptionMessage", runtime.newText(e.getMessage()));
                        List<Object> ob = new ArrayList<Object>();
                        for(StackTraceElement ste : e.getStackTrace()) {
                            ob.add(runtime.newText(ste.toString()));
                        }

                        condition.setCell("exceptionStackTrace", runtime.newList(ob));

                        runtime.withReturningRestart("ignore", context, new RunnableWithControlFlow() {
                                public void run() throws ControlFlow {
                                    runtime.errorCondition(condition);
                                }});
                    }

                    return context.runtime.getNil();
                }
            }));
    }

    public IokeData cloneData(IokeObject obj, IokeObject m, IokeObject context) {
        return new IokeIO(reader, writer);
    }
}// IokeIO
