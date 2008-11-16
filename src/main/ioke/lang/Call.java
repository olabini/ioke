/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Call extends IokeData {
    private IokeObject ctx;
    private IokeObject message;
    private IokeObject surroundingContext;
    private IokeObject on;

    public Call() {
    }

    public Call(IokeObject ctx, IokeObject message, IokeObject surroundingContext, IokeObject on) {
        this.ctx = ctx;
        this.message = message;
        this.surroundingContext = surroundingContext;
        this.on = on;
    }

    @Override
    public void init(IokeObject obj) {
        final Runtime runtime = obj.runtime;

        obj.setKind("Call");

        obj.registerMethod(runtime.newJavaMethod("returns a list of all the unevaluated arguments", new JavaMethod("arguments") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    return context.runtime.newList(((Call)IokeObject.data(on)).message.getArguments());
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns the ground of the place this call originated", new JavaMethod("ground") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    return ((Call)IokeObject.data(on)).surroundingContext;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns the message that started this call", new JavaMethod("message") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    return ((Call)IokeObject.data(on)).message;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns a list of the result of evaluating all the arguments to this call", new JavaMethod("evaluatedArguments") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    return context.runtime.newList(((Call)IokeObject.data(on)).message.getEvaluatedArguments(((Call)IokeObject.data(on)).surroundingContext));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("takes one evaluated text or symbol argument and resends the current message to that method/macro on the current receiver.", new JavaMethod("resendToMethod") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject mess, Object on) throws ControlFlow {
                    Call c = (Call)IokeObject.data(on);
                    String name = Text.getText(runtime.asText.sendTo(context, IokeObject.as(mess.getEvaluatedArgument(0, context))));
                    IokeObject m = Message.copy(c.message);
                    Message.setName(m, name);
                    return m.sendTo(c.surroundingContext, c.on);
                }
            }));

    }

    public IokeData cloneData(IokeObject obj, IokeObject m, IokeObject context) {
        return new Call(this.ctx, this.message, this.surroundingContext, this.on);
    }
}// Call
