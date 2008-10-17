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
import ioke.lang.exceptions.ControlFlow;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class IokeObject {
    public Runtime runtime;
    public String documentation;
    public Map<String, IokeObject> cells = new HashMap<String, IokeObject>();
    public List<IokeObject> mimics = new ArrayList<IokeObject>();
    
    public IokeData data;

    public IokeObject(Runtime runtime, String documentation) {
        this(runtime, documentation, IokeData.None);
    }

    public IokeObject(Runtime runtime, String documentation, IokeData data) {
        this.runtime = runtime;
        this.documentation = documentation;
        this.data = data;
    }

    public void init() {
        data.init(this);
    }

    public void setKind(String kind) {
        cells.put("kind", runtime.newText(kind));
    }

    public IokeObject getRealContext() {
        return this;
    }

    public IokeObject allocateCopy(Message m, IokeObject context) {
        return new IokeObject(runtime, documentation, data.cloneData(this, m, context));
    }

    public IokeObject findCell(Message m, IokeObject context, String name, IdentityHashMap<IokeObject, Object> visited) {
        if(visited.containsKey(this)) {
            return runtime.nul;
        }

        if(cells.containsKey(name)) {
            return cells.get(name);
        } else {
            visited.put(this, null);

            for(IokeObject mimic : mimics) {
                IokeObject cell = mimic.findCell(m, context, name, visited);
                if(cell != runtime.nul) {
                    return cell;
                }
            }

            return runtime.nul;
        }
    }

    public IokeObject findCell(Message m, IokeObject context, String name) {
        return findCell(m, context, name, new IdentityHashMap<IokeObject, Object>());
    }

    public IokeObject getCell(Message m, IokeObject context, String name) {
        IokeObject cell = this.findCell(m, context, name);

        if(cell == runtime.nul) {
            throw new NoSuchCellException(m, name, this, context);
        }

        return cell;
    }

    public IokeObject perform(IokeObject ctx, Message message) throws ControlFlow {
        return getCell(message, ctx, message.getName()).getOrActivate(ctx, message, this);
    }

    public void setCell(String name, IokeObject value) {
        cells.put(name, value);
    }

    public boolean isNil() {
        return data.isNil();
    }

    public boolean isTrue() {
        return data.isTrue();
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

    public IokeObject convertToNumber(Message m, IokeObject context) {
        return data.convertToNumber(this, m, context);
    }

    public IokeObject getOrActivate(IokeObject context, Message message, IokeObject on) throws ControlFlow {
        if(isActivatable()) {
            return activate(context, message, on);
        } else {
            return this;
        }
    }

    public String toString() {
        return data.toString();
    }

    public String representation() {
        StringBuilder sb = new StringBuilder();

        return sb.append("#<").append(this).append(": mimics=").append(mimics).append(" cells=").append(cells).append(">").toString();
    }

    public IokeObject activate(IokeObject context, Message message, IokeObject on) throws ControlFlow {
        throw new NotActivatableException(message, "Can't activate " + this + "#" + message.getName() + " on " + on, on, context);
    }
}// IokeObject
