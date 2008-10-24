/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class LexicalBlock extends IokeData {
    private IokeObject context;

    public LexicalBlock(IokeObject context) {
        this.context = context;
    }

    @Override
    public void init(IokeObject lexicalBlock) {
        lexicalBlock.setKind("LexicalBlock");
    }
}// LexicalBlock
