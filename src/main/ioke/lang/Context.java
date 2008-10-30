/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.IdentityHashMap;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Context extends IokeObject {
    Object ground;

    public IokeObject message;
    public IokeObject surroundingContext;

    public Context(Runtime runtime, Object ground, String documentation, IokeObject message, IokeObject surroundingContext) {
        super(runtime, documentation);
        this.ground = IokeObject.getRealContext(ground);
        this.message = message;
        this.surroundingContext = surroundingContext;
        
        if(runtime.context != null) {
            this.mimicsWithoutCheck(runtime.context);
        }

        setCell("self", getRealContext());
        setCell("@", getRealContext());
    }
    
    @Override
    public void init() {
        setKind("Context");
    }

    @Override
    public Object getRealContext() {
        return ground;
    }

    @Override
    public Object findCell(IokeObject m, IokeObject context, String name, IdentityHashMap<IokeObject, Object> visited) {
        Object nn = super.findCell(m, context, name, visited);
        
        if(nn == runtime.nul) {
            return IokeObject.findCell(ground, m, context, name, visited);
        } else {
            return nn;
        }
    }

    @Override
    public String toString() {
        return "Context:" + System.identityHashCode(this) + "<" + ground + ">";
    }
}// Context
