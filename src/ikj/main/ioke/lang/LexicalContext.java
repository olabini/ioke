/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class LexicalContext extends IokeObject {
    public Object ground;
    public IokeObject surroundingContext;

    public LexicalContext(Runtime runtime, Object ground, String documentation, IokeObject surroundingContext) {
        super(runtime, documentation);
        this.ground = IokeObject.getRealContext(ground);
        this.surroundingContext = surroundingContext;

        setKind("LexicalContext");
        this.body.flags |= IokeObject.LEXICAL_F;
    }

    @Override
    public void init() {
    }

    @Override
    public String toString() {
        return "LexicalContext:" + System.identityHashCode(this);
    }
}// LexicalContext
