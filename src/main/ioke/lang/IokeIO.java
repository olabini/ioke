/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.io.IOException;
import java.io.Writer;

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
                        throw new RuntimeException(e);
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
                        throw new RuntimeException(e);
                    }

                    return context.runtime.getNil();
                }
            }));
    }

    public IokeData cloneData(IokeObject obj, IokeObject m, IokeObject context) {
        return new IokeIO(writer);
    }
}// IokeIO
