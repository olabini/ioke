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

    public Context(Runtime runtime, IokeObject ground, String documentation) {
        super(runtime, documentation);
        this.ground = ground;
    }

    IokeObject findCell(Message m, String name, IdentityHashMap<IokeObject, Object> visited) {
//         System.err.println("Ylooking for " + name + " on " + this);
        if(visited.containsKey(this)) {
            return runtime.nul;
        }

        if(cells.containsKey(name)) {
            return cells.get(name);
        } else {
            visited.put(this, null);
            return ground.findCell(m, name, visited);
        }
    }
}// Context
