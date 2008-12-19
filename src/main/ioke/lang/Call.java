/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;

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

        obj.registerMethod(runtime.newJavaMethod("returns a list of all the unevaluated arguments", new JavaMethod.WithNoArguments("arguments") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    return context.runtime.newList(((Call)IokeObject.data(on)).message.getArguments());
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns the ground of the place this call originated", new JavaMethod.WithNoArguments("ground") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    return ((Call)IokeObject.data(on)).surroundingContext;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns the message that started this call", new JavaMethod.WithNoArguments("message") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    return ((Call)IokeObject.data(on)).message;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns a list of the result of evaluating all the arguments to this call", new JavaMethod.WithNoArguments("evaluatedArguments") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    return context.runtime.newList(((Call)IokeObject.data(on)).message.getEvaluatedArguments(((Call)IokeObject.data(on)).surroundingContext));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("takes one evaluated text or symbol argument and resends the current message to that method/macro on the current receiver.", new JavaMethod("resendToMethod") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("cellName")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject mess, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, mess, on, args, new HashMap<String, Object>());

                    Call c = (Call)IokeObject.data(on);
                    String name = Text.getText(runtime.asText.sendTo(context, args.get(0)));
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
