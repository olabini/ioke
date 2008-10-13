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
    IokeObject ground;

    public Message message;
    public IokeObject surroundingContext;

    public Context(Runtime runtime, IokeObject ground, String documentation, Message message, IokeObject surroundingContext) {
        super(runtime, documentation);
        this.ground = ground.getRealContext();
        this.message = message;
        this.surroundingContext = surroundingContext;
    }

    public IokeObject getRealContext() {
        return ground;
    }

    IokeObject findCell(Message m, IokeObject context, String name, IdentityHashMap<IokeObject, Object> visited) {
        if(visited.containsKey(this)) {
            return runtime.nul;
        }

        if(cells.containsKey(name)) {
            return cells.get(name);
        } else {
            visited.put(this, null);
            return ground.findCell(m, context, name, visited);
        }
    }

    @Override
    public String toString() {
        return "Context:" + System.identityHashCode(this) + "<" + ground + ">";
    }
}// Context
