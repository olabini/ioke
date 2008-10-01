/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.ArrayList;

import ioke.lang.exceptions.NotActivatableException;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class IokeObject {
    Runtime runtime;
    Map<String, IokeObject> cells = new HashMap<String, IokeObject>();
    List<IokeObject> mimics = new ArrayList<IokeObject>();
    
    IokeObject(Runtime runtime) {
        this.runtime = runtime;
    }

    public IokeObject findCell(String name) {
        if(cells.containsKey(name)) {
            return cells.get(name);
        } else {
            for(IokeObject mimic : mimics) {
                IokeObject cell = mimic.findCell(name);
                if(!cell.isNil()) {
                    return cell;
                }
            }
            return runtime.getNil();
        }
    }

    public boolean isNil() {
        return false;
    }

    public void mimics(IokeObject mimic) {
        this.mimics.add(mimic);
    }

    public void registerMethod(String name, Method m) {
        cells.put(name, m);
    }

    public IokeObject activate(Message message, IokeObject on) {
        throw new NotActivatableException("Can't activate " + this + "#" + message.getName() + " on " + on);
    }
}// IokeObject
