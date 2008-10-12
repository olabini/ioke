/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.ArrayList;
import java.util.IdentityHashMap;

import ioke.lang.exceptions.NotActivatableException;
import ioke.lang.exceptions.NoSuchCellException;
import ioke.lang.exceptions.ObjectIsNotRightType;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class IokeObject {
    public Runtime runtime;
    public String documentation;
    public Map<String, IokeObject> cells = new HashMap<String, IokeObject>();
    public List<IokeObject> mimics = new ArrayList<IokeObject>();
    
    public IokeObject(Runtime runtime, String documentation) {
        this.runtime = runtime;
        this.documentation = documentation;
    }

    IokeObject allocateCopy() {
        return new IokeObject(runtime, documentation);
    }

    IokeObject findCell(String name, IdentityHashMap<IokeObject, Object> visited) {
        if(visited.containsKey(this)) {
            return runtime.nul;
        }

        if(cells.containsKey(name)) {
            return cells.get(name);
        } else {
            visited.put(this, null);

            for(IokeObject mimic : mimics) {
                IokeObject cell = mimic.findCell(name, visited);
                if(cell != runtime.nul) {
                    return cell;
                }
            }

            return runtime.nul;
        }
    }

    public IokeObject findCell(String name) {
        return findCell(name, new IdentityHashMap<IokeObject, Object>());
    }

    public IokeObject getCell(String name) {
        IokeObject cell = this.findCell(name);

        if(cell == runtime.nul) {
            throw new NoSuchCellException(name, this);
        }

        return cell;
    }

    public IokeObject perform(Context ctx, Message message) {
        return getCell(message.getName()).getOrActivate(ctx, message, this);
    }

    public void setCell(String name, IokeObject value) {
        cells.put(name, value);
    }

    public boolean isNil() {
        return false;
    }

    public void mimics(IokeObject mimic) {
        this.mimics.add(mimic);
    }

    public void registerMethod(Method m) {
        cells.put(m.name, m);
    }

    public void registerMethod(String name, Method m) {
        cells.put(name, m);
    }

    public void registerCell(String name, IokeObject o) {
        cells.put(name, o);
    }

    public boolean isActivatable() {
        return false;
    }

    public Number convertToNumber() {
        throw new ObjectIsNotRightType(this, "Number");
    }

    public IokeObject getOrActivate(Context context, Message message, IokeObject on) {
        if(isActivatable()) {
            return activate(context, message, on);
        } else {
            return this;
        }
    }

    public IokeObject activate(Context context, Message message, IokeObject on) {
        throw new NotActivatableException("Can't activate " + this + "#" + message.getName() + " on " + on);
    }
}// IokeObject
