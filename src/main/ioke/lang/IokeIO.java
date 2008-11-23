/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.io.IOException;
import java.io.Writer;

import java.util.ArrayList;
import java.util.List;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class IokeIO extends IokeData {
    private Writer writer;

    public IokeIO() {}

    public IokeIO(Writer writer) {
        this.writer = writer;
    }

    public static Writer getWriter(Object arg) {
        return ((IokeIO)IokeObject.data(arg)).writer;
    }
    
    @Override
    public void init(IokeObject obj) {
        final Runtime runtime = obj.runtime;

        obj.setKind("IO");

        obj.registerMethod(runtime.newJavaMethod("Prints a text representation of the argument and a newline to the current IO object", new JavaMethod("println") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);

                    try {
                        IokeIO.getWriter(on).write(context.runtime.asText.sendTo(context, arg).toString());
                        IokeIO.getWriter(on).write("\n");
                        IokeIO.getWriter(on).flush();
                    } catch(IOException e) {
                        final Runtime runtime = context.runtime;
                        final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition, 
                                                                                           message, 
                                                                                           context, 
                                                                                           "Error", 
                                                                                           "IO")).mimic(message, context);
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

        obj.registerMethod(runtime.newJavaMethod("Prints a text representation of the argument to the current IO object", new JavaMethod("print") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);

                    try {
                        IokeIO.getWriter(on).write(context.runtime.asText.sendTo(context, arg).toString());
                        IokeIO.getWriter(on).flush();
                    } catch(IOException e) {
                        final Runtime runtime = context.runtime;
                        final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition, 
                                                                                           message, 
                                                                                           context, 
                                                                                           "Error", 
                                                                                           "IO")).mimic(message, context);
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
        return new IokeIO(writer);
    }
}// IokeIO
