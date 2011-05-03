/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class LexicalContext extends IokeData {
    public Object ground;
    public IokeObject surroundingContext;

    public LexicalContext(Object ground, IokeObject surroundingContext) {
        this.ground = IokeObject.getRealContext(ground);
        this.surroundingContext = surroundingContext;
    }

    @Override
    public String toString(IokeObject self) {
        return "LexicalContext:" + System.identityHashCode(self);
    }
}// LexicalContext
