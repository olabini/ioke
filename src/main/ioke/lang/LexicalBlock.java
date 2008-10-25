/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class LexicalBlock extends IokeData {
    private DefaultArgumentsDefinition arguments;
    private IokeObject context;
    private IokeObject message;

    public LexicalBlock(IokeObject context, DefaultArgumentsDefinition arguments, IokeObject message) {
        this.context = context;
        this.arguments = arguments;
        this.message = message;
    }

    public LexicalBlock(IokeObject context) {
        this(context, null, context.runtime.nilMessage);
    }

    @Override
    public void init(IokeObject lexicalBlock) {
        lexicalBlock.setKind("LexicalBlock");

        lexicalBlock.registerMethod(lexicalBlock.runtime.newJavaMethod("invokes the block with the arguments provided, returning the result of the last expression in the block", new JavaMethod("call") {
                @Override
                public Object activate(IokeObject self, IokeObject dynamicContext, IokeObject message, Object on) throws ControlFlow {
                    return IokeObject.as(on).activate(dynamicContext, message, on);
                }
            }));
    }

    @Override
    public Object activate(IokeObject self, IokeObject dynamicContext, IokeObject message, Object on) throws ControlFlow {
        LexicalContext c = new LexicalContext(self.runtime, on, "Lexical activation context", message, this.context);

        arguments.assignArgumentValues(c, dynamicContext, message, on);

        return this.message.evaluateCompleteWith(c, on);
    }
}// LexicalBlock
