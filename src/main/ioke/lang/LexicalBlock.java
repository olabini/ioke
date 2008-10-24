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
    private IokeObject context;
    private IokeObject message;

    public LexicalBlock(IokeObject context, IokeObject message) {
        this.context = context;
        this.message = message;
    }

    public LexicalBlock(IokeObject context) {
        this(context, context.runtime.nilMessage);
    }

    @Override
    public void init(IokeObject lexicalBlock) {
        lexicalBlock.setKind("LexicalBlock");

        lexicalBlock.registerMethod(lexicalBlock.runtime.newJavaMethod("invokes the block with the arguments provided, returning the result of the last expression in the block", new JavaMethod("call") {
                @Override
                public Object activate(IokeObject self, IokeObject dynamicContext, IokeObject message, Object on) throws ControlFlow {
                    LexicalContext c = new LexicalContext(self.runtime, on, "Lexical activation context", message, ((LexicalBlock)IokeObject.as(on).data).context);
                    return ((LexicalBlock)IokeObject.as(on).data).message.evaluateCompleteWith(c, on);
                }
            }));
    }
}// LexicalBlock
