/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.IdentityHashMap;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class LexicalContext extends IokeObject {
    Object ground;

    public IokeObject message;
    public IokeObject surroundingContext;

    public LexicalContext(Runtime runtime, Object ground, String documentation, IokeObject message, IokeObject surroundingContext) {
        super(runtime, documentation);
        this.ground = IokeObject.getRealContext(ground);
        this.message = message;
        this.surroundingContext = surroundingContext;

        if(runtime.lexicalContext != null) {
            this.mimics(runtime.lexicalContext);
        }
    }
    
    @Override
    public void init() {
        setKind("LexicalContext");
    }

    @Override
    public Object getRealContext() {
        return ground;
    }


    @Override
    public Object findCell(IokeObject m, IokeObject context, String name, IdentityHashMap<IokeObject, Object> visited) {
        Object nn = super.findCell(m, context, name, visited);
        
        if(nn == runtime.nul) {
            return IokeObject.findCell(surroundingContext, m, context, name, visited);
        } else {
            return nn;
        }
    }

    @Override
    public String toString() {
        return "LexicalContext:" + System.identityHashCode(this);
    }
}// LexicalContext
