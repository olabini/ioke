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
    public Map<String, Object> cells = new HashMap<String, Object>();
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

    public static Object getRealContext(Object o) {
        if(o instanceof IokeObject) {
            return IokeObject.as(o).getRealContext();
        }
        return o;
    }

    public Object getRealContext() {
        return this;
    }

    public IokeObject allocateCopy(IokeObject m, IokeObject context) {
        return new IokeObject(runtime, documentation, data.cloneData(this, m, context));
    }

    public static Object findCell(Object obj, IokeObject m, IokeObject context, String name, IdentityHashMap<IokeObject, Object> visited) {
        return as(obj).findCell(m, context, name, visited);
    }

    public Object findCell(IokeObject m, IokeObject context, String name, IdentityHashMap<IokeObject, Object> visited) {
        if(visited.containsKey(this)) {
            return runtime.nul;
        }

        if(cells.containsKey(name)) {
            return cells.get(name);
        } else {
            visited.put(this, null);

            for(IokeObject mimic : mimics) {
                Object cell = mimic.findCell(m, context, name, visited);
                if(cell != runtime.nul) {
                    return cell;
                }
            }

            return runtime.nul;
        }
    }

    public IokeObject mimic(IokeObject message, IokeObject context) {
        IokeObject clone = allocateCopy(message, context);
        clone.mimics(this);
        return clone;
    }

    public Object findCell(IokeObject m, IokeObject context, String name) {
        return findCell(m, context, name, new IdentityHashMap<IokeObject, Object>());
    }

    public static Object getCell(Object on, IokeObject m, IokeObject context, String name) {
        return ((IokeObject)on).getCell(m, context, name);
    }

    public Object getCell(IokeObject m, IokeObject context, String name) {
        Object cell = this.findCell(m, context, name);

        if(cell == runtime.nul) {
            throw new NoSuchCellException(m, name, this, context);
        }

        return cell;
    }

    public String getKind() {
        return ((Text)IokeObject.data(findCell(null, null, "kind"))).getText();
    }

    public boolean hasKind() {
        return cells.containsKey("kind");
    }

    public static Object getOrActivate(Object obj, IokeObject context, IokeObject message, Object on) throws ControlFlow {
        return as(obj).getOrActivate(context, message, on);
    }

    public static Object perform(Object obj, IokeObject ctx, IokeObject message) throws ControlFlow {
        return as(obj).perform(ctx, message);
    }

    public Object perform(IokeObject ctx, IokeObject message) throws ControlFlow {
        return getOrActivate(getCell(message, ctx, message.getName()), ctx, message, this);
    }

    public static void setCell(Object on, String name, Object value) {
        as(on).setCell(name, value);
    }

    public void setCell(String name, Object value) {
        cells.put(name, value);
    }

    public boolean isNil() {
        return data.isNil();
    }

    public static boolean isTrue(Object on) {
        return as(on).isTrue();
    }

    public boolean isTrue() {
        return data.isTrue();
    }

    public boolean isMessage() {
        return data.isMessage();
    }

    public void mimics(IokeObject mimic) {
        this.mimics.add(mimic);
    }

    public void registerMethod(IokeObject m) {
        cells.put(((Method)m.data).getName(), m);
    }

    public void registerMethod(String name, IokeObject m) {
        cells.put(name, m);
    }

    public void registerCell(String name, Object o) {
        cells.put(name, o);
    }

    public boolean isActivatable() {
        return isTrue(findCell(null, null, "activatable"));
    }

    public static IokeData data(Object on) {
        return ((IokeObject)on).data;
    }

    public static IokeObject as(Object on) {
        return ((IokeObject)on);
    }

    public static IokeObject convertToNumber(Object on, IokeObject m, IokeObject context) {
        return ((IokeObject)on).convertToNumber(m, context);
    }

    public IokeObject convertToNumber(IokeObject m, IokeObject context) {
        return data.convertToNumber(this, m, context);
    }

    public static IokeObject convertToText(Object on, IokeObject m, IokeObject context) {
        return ((IokeObject)on).convertToText(m, context);
    }

    public IokeObject convertToText(IokeObject m, IokeObject context) {
        return data.convertToText(this, m, context);
    }

    public Object getOrActivate(IokeObject context, IokeObject message, Object on) throws ControlFlow {
        if(isActivatable()) {
            return activate(context, message, on);
        } else {
            return this;
        }
    }

    public String toString() {
        return data.toString(this);
    }

    public String representation() {
        StringBuilder sb = new StringBuilder();

        return sb.append("#<").append(this).append(": mimics=").append(mimics).append(" cells=").append(cells).append(">").toString();
    }

    public static Object activate(Object self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
        return as(self).activate(context, message, on);
    }

    public Object activate(IokeObject context, IokeObject message, Object on) throws ControlFlow {
        return data.activate(this, context, message, on);
    }













    public Object getEvaluatedArgument(int index, IokeObject context) throws ControlFlow {
        return data.getEvaluatedArgument(this, index, context);
    }

    public Object sendTo(IokeObject context, Object recv) throws ControlFlow {
        return data.sendTo(this, context, recv);
    }

    public Object sendTo(IokeObject context, Object recv, Object argument) throws ControlFlow {
        return data.sendTo(this, context, recv, argument);
    }

    public Object sendTo(IokeObject context, Object recv, Object arg1, Object arg2) throws ControlFlow {
        return data.sendTo(this, context, recv, arg1, arg2);
    }

    public Object evaluateComplete() throws ControlFlow {
        return data.evaluateComplete(this);
    }

    public Object evaluateCompleteWith(IokeObject ctx, Object ground) throws ControlFlow {
        return data.evaluateCompleteWith(this, ctx, ground);
    }

    public Object evaluateCompleteWithoutExplicitReceiver(IokeObject ctx, Object ground) throws ControlFlow {
        return data.evaluateCompleteWithoutExplicitReceiver(this, ctx, ground);
    }

    public Object evaluateCompleteWith(Object ground) throws ControlFlow {
        return data.evaluateCompleteWith(this, ground);
    }

    public List<Object> getArguments() {
        return data.getArguments(this);
    }

    public int getArgumentCount() {
        return data.getArgumentCount(this);
    }

    public String getName() {
        return data.getName(this);
    }

    public String getFile() {
        return data.getFile(this);
    }

    public int getLine() {
        return data.getLine(this);
    }

    public int getPosition() {
        return data.getPosition(this);
    }
}// IokeObject
