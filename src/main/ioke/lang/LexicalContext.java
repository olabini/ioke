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

        setKind("LexicalContext");
    }
    
    @Override
    public void init() {
    }

    @Override
    public Object getRealContext() {
        return ground;
    }

    @Override
    public Object getSelf() {
        return surroundingContext.getSelf();
    }

    @Override
    public void assign(String name, Object value, IokeObject context, IokeObject message) {
        Object place = findPlace(name);
        if(place == runtime.nul) {
            place = this;
        }
        IokeObject.setCell(place, name, value, context);
    }

    @Override
    protected Object findPlace(String name, IdentityHashMap<IokeObject, Object> visited) {
        Object nn = super.findPlace(name, visited);
        if(nn == runtime.nul) {
            return IokeObject.findPlace(surroundingContext, name, visited);
        } else {
            return nn;
        }
    }

    @Override
    public Object findSuperCell(IokeObject early, IokeObject message, IokeObject context, String name, boolean[] found, IdentityHashMap<IokeObject, Object> visited) {
        Object nn = super.findSuperCell(early, message, context, name, found, visited);
        if(nn == runtime.nul) {
            return IokeObject.findSuperCellOn(surroundingContext, early, message, context, name);
        } else {
            return nn;
        }
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
