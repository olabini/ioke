/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.List;
import java.util.ArrayList;
import java.util.IdentityHashMap;

import ioke.lang.exceptions.ControlFlow;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class IokeObject {
    public Runtime runtime;
    public String documentation;
    public Map<String, Object> cells = new LinkedHashMap<String, Object>();
    public List<IokeObject> mimics = new ArrayList<IokeObject>();
    
    public Object opaque;

    public IokeData data;

    public IokeObject(Runtime runtime, String documentation) {
        this(runtime, documentation, IokeData.None);
    }

    public IokeObject(Runtime runtime, String documentation, IokeData data) {
        this.runtime = runtime;
        this.documentation = documentation;
        this.data = data;
    }

    public void init() throws ControlFlow {
        data.init(this);
    }

    public void setKind(String kind) {
        cells.put("kind", runtime.newText(kind));
    }

    public static List<IokeObject> getMimics(Object on) {
        return as(on).mimics;
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

    public static Object findSuperCellOn(Object obj, IokeObject early, IokeObject message, IokeObject context, String name) {
        return as(obj).findSuperCell(early, message, context, name, new boolean[]{false}, new IdentityHashMap<IokeObject, Object>());
    }

    public Object findSuperCell(IokeObject early, IokeObject message, IokeObject context, String name, boolean[] found, IdentityHashMap<IokeObject, Object> visited) {
        if(visited.containsKey(this)) {
            return runtime.nul;
        }

        if(cells.containsKey(name)) {
            if(found[0]) {
                return cells.get(name);
            }
            if(early == cells.get(name)) {
                found[0] = true;
            }
        }

        visited.put(this, null);
        
        for(IokeObject mimic : mimics) {
            Object cell = mimic.findSuperCell(early, message, context, name, found, visited);
            if(cell != runtime.nul) {
                return cell;
            }
        }

        return runtime.nul;
    }

    public static Object findCell(Object obj, IokeObject m, IokeObject context, String name) {
        return as(obj).findCell(m, context, name, new IdentityHashMap<IokeObject, Object>());
    }

    public static Object findCell(Object obj, IokeObject m, IokeObject context, String name, IdentityHashMap<IokeObject, Object> visited) {
        return as(obj).findCell(m, context, name, visited);
    }

    public static Object findPlace(Object obj, String name, IdentityHashMap<IokeObject, Object> visited) {
        return as(obj).findPlace(name, visited);
    }

    /**
     * Finds the first object in the chain where name is available as a cell, or nul if nothing can be found.
     * findPlace is cycle aware and will not loop in an infinite chain. subclasses should copy this behavior.
     */
    public Object findPlace(String name) {
        return findPlace(name, new IdentityHashMap<IokeObject, Object>());
    }

    protected Object findPlace(String name, IdentityHashMap<IokeObject, Object> visited) {
        if(visited.containsKey(this)) {
            return runtime.nul;
        }
        if(cells.containsKey(name)) {
            return this;
        } else {
            visited.put(this, null);

            for(IokeObject mimic : mimics) {
                Object place = mimic.findPlace(name, visited);
                if(place != runtime.nul) {
                    return place;
                }
            }

            return runtime.nul;
        }
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

    public static IokeObject mimic(Object on, IokeObject message, IokeObject context) throws ControlFlow {
        return as(on).mimic(message, context);
    }

    public IokeObject mimic(IokeObject message, IokeObject context) throws ControlFlow {
        IokeObject clone = allocateCopy(message, context);
        clone.mimics(this, message, context);
        return clone;
    }

    public Object findCell(IokeObject m, IokeObject context, String name) {
        return findCell(m, context, name, new IdentityHashMap<IokeObject, Object>());
    }

    public static boolean isKind(Object on, String kind) {
        return IokeObject.as(on).isKind(kind, new IdentityHashMap<IokeObject, Object>());
    }

    public static boolean isMimic(Object on, IokeObject potentialMimic) {
        return IokeObject.as(on).isMimic(potentialMimic, new IdentityHashMap<IokeObject, Object>());
    }

    private boolean isKind(String kind, IdentityHashMap<IokeObject, Object> visited) {
        if(visited.containsKey(this)) {
            return false;
        }

        if(cells.containsKey("kind") && kind.equals(Text.getText(cells.get("kind")))) {
            return true;
        }

        visited.put(this, null);
            
        for(IokeObject mimic : mimics) {
            if(mimic.isKind(kind, visited)) {
                return true;
            }
        }

        return false;
    }

    private boolean isMimic(IokeObject pot, IdentityHashMap<IokeObject, Object> visited) {
        if(visited.containsKey(this)) {
            return false;
        }

        if(this == pot || mimics.contains(pot)) {
            return true;
        }

        visited.put(this, null);
            
        for(IokeObject mimic : mimics) {
            if(mimic.isMimic(pot, visited)) {
                return true;
            }
        }

        return false;
    }

    public static Object getCellChain(Object on, IokeObject m, IokeObject c, String... names) throws ControlFlow {
        Object current = on;
        for(String name : names) {
            current = getCell(current, m, c, name);
        }
        return current;
    }
    
    public static Object getCell(Object on, IokeObject m, IokeObject context, String name) throws ControlFlow {
        return ((IokeObject)on).getCell(m, context, name);
    }

    public static Object setCell(Object on, IokeObject m, IokeObject context, String name, Object value) {
        ((IokeObject)on).setCell(name, value);
        return value;
    }

    public Object getCell(IokeObject m, IokeObject context, String name) throws ControlFlow {
        final String outerName = name;
        Object cell = this.findCell(m, context, name);

        while(cell == runtime.nul) {
            final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition, 
                                                                               m, 
                                                                               context, 
                                                                               "Error", 
                                                                               "NoSuchCell")).mimic(m, context);
            condition.setCell("message", m);
            condition.setCell("context", context);
            condition.setCell("receiver", this);
            condition.setCell("cellName", runtime.getSymbol(name));

            final Object[] newCell = new Object[]{cell};

            runtime.withRestartReturningArguments(new RunnableWithControlFlow() {
                    public void run() throws ControlFlow {
                        runtime.errorCondition(condition);
                    }}, 
                context,
                new Restart.ArgumentGivingRestart("useValue") { 
                    public IokeObject invoke(IokeObject context, List<Object> arguments) throws ControlFlow {
                        newCell[0] = arguments.get(0);
                        return context.runtime.nil;
                    }
                },
                new Restart.ArgumentGivingRestart("storeValue") {
                    public IokeObject invoke(IokeObject context, List<Object> arguments) throws ControlFlow {
                        newCell[0] = arguments.get(0);
                        setCell(outerName, newCell[0]);
                        return context.runtime.nil;
                    }
                }
                );

            cell = newCell[0];
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
        final String name = message.getName();
        final String outerName = name;
        Object cell = this.findCell(message, ctx, name);
        
        while(cell == runtime.nul && ((cell = this.findCell(message, ctx, "pass")) == runtime.nul)) {
            final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition, 
                                                                               message, 
                                                                               ctx, 
                                                                               "Error", 
                                                                               "NoSuchCell")).mimic(message, ctx);
            condition.setCell("message", message);
            condition.setCell("context", ctx);
            condition.setCell("receiver", this);
            condition.setCell("cellName", runtime.getSymbol(name));

            final Object[] newCell = new Object[]{cell};

            runtime.withRestartReturningArguments(new RunnableWithControlFlow() {
                    public void run() throws ControlFlow {
                        runtime.errorCondition(condition);
                    }}, 
                ctx,
                new Restart.ArgumentGivingRestart("useValue") { 
                    public IokeObject invoke(IokeObject context, List<Object> arguments) throws ControlFlow {
                        newCell[0] = arguments.get(0);
                        return context.runtime.nil;
                    }
                },
                new Restart.ArgumentGivingRestart("storeValue") {
                    public IokeObject invoke(IokeObject context, List<Object> arguments) throws ControlFlow {
                        newCell[0] = arguments.get(0);
                        setCell(outerName, newCell[0]);
                        return context.runtime.nil;
                    }
                }
                );

            cell = newCell[0];
        }

        return getOrActivate(cell, ctx, message, this);
    }

    public static void setCell(Object on, String name, Object value) {
        as(on).setCell(name, value);
    }

    public void setCell(String name, Object value) {
        cells.put(name, value);
    }

    public static void assign(Object on, String name, Object value) {
        as(on).assign(name, value);
    }

    public void assign(String name, Object value) {
        cells.put(name, value);
    }

    public boolean isSymbol() {
        return data.isSymbol();
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

    public List<IokeObject> getMimics() {
        return mimics;
    }

    public void mimicsWithoutCheck(IokeObject mimic) {
        if(!this.mimics.contains(mimic)) {
            this.mimics.add(mimic);
        }
    }

    public void mimics(IokeObject mimic, IokeObject message, IokeObject context) throws ControlFlow {
        mimic.data.checkMimic(mimic, message, context);
        if(!this.mimics.contains(mimic)) {
            this.mimics.add(mimic);
        }
    }

    public void mimics(int index, IokeObject mimic, IokeObject message, IokeObject context) throws ControlFlow {
        mimic.data.checkMimic(mimic, message, context);
        if(!this.mimics.contains(mimic)) {
            this.mimics.add(index, mimic);
        }
    }

    public void registerMethod(IokeObject m) {
        cells.put(((Method)m.data).getName(), m);
    }

    public void aliasMethod(String originalName, String newName) throws ControlFlow {
        IokeObject io = as(findCell(null, null, originalName));
        IokeObject newObj = io.mimic(null, null);
        newObj.data = new AliasMethod(newName, io.data, io);
        cells.put(newName, newObj);
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

    public IokeObject negate() {
        return data.negate(this);
    }
    
    public Map<String, Object> getCells() {
        return cells;
    }

    public static IokeData data(Object on) {
        return ((IokeObject)on).data;
    }

    public static IokeObject as(Object on) {
        return ((IokeObject)on);
    }

    public Object getSelf() {
        return this.cells.get("self");
    }

    public static IokeObject convertToNumber(Object on, IokeObject m, IokeObject context) throws ControlFlow {
        return ((IokeObject)on).convertToNumber(m, context);
    }

    public IokeObject convertToNumber(IokeObject m, IokeObject context) throws ControlFlow {
        return data.convertToNumber(this, m, context);
    }

    public static IokeObject convertToText(Object on, IokeObject m, IokeObject context) throws ControlFlow {
        return ((IokeObject)on).convertToText(m, context);
    }

    public static IokeObject tryConvertToText(Object on, IokeObject m, IokeObject context) throws ControlFlow {
        return ((IokeObject)on).tryConvertToText(m, context);
    }

    public static IokeObject convertToSymbol(Object on, IokeObject m, IokeObject context) throws ControlFlow {
        return ((IokeObject)on).convertToSymbol(m, context);
    }

    public static IokeObject convertToPattern(Object on, IokeObject m, IokeObject context) throws ControlFlow {
        return ((IokeObject)on).convertToPattern(m, context);
    }

    public static String inspect(Object on) throws ControlFlow {
        IokeObject ion = as(on);
        Runtime runtime = ion.runtime;
        return Text.getText(runtime.inspectMessage.sendTo(ion, ion));
    }

    public static String notice(Object on) throws ControlFlow {
        IokeObject ion = as(on);
        Runtime runtime = ion.runtime;
        return Text.getText(runtime.noticeMessage.sendTo(ion, ion));
    }

    public IokeObject convertToText(IokeObject m, IokeObject context) throws ControlFlow {
        return data.convertToText(this, m, context);
    }

    public IokeObject tryConvertToText(IokeObject m, IokeObject context) throws ControlFlow {
        return data.tryConvertToText(this, m, context);
    }

    public IokeObject convertToSymbol(IokeObject m, IokeObject context) throws ControlFlow {
        return data.convertToSymbol(this, m, context);
    }

    public IokeObject convertToPattern(IokeObject m, IokeObject context) throws ControlFlow {
        return data.convertToPattern(this, m, context);
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

    public static Object activate(Object self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
        return as(self).activate(context, message, on);
    }

    public Object activate(IokeObject context, IokeObject message, Object on) throws ControlFlow {
        return data.activate(this, context, message, on);
    }

    @Override
    public boolean equals(Object other) {
        return isEqualTo(other);
    }

    @Override
    public int hashCode() {
        return iokeHashCode();
    }

    public static boolean equals(Object lhs, Object rhs) {
        return IokeObject.as(lhs).isEqualTo(rhs);
    }

    public boolean isEqualTo(Object other) {
        return data.isEqualTo(this, other);
    }

    public int iokeHashCode() {
        return data.hashCode(this);
    }

    public Object getEvaluatedArgument(int index, IokeObject context) throws ControlFlow {
        return data.getEvaluatedArgument(this, index, context);
    }

    public List<Object> getEvaluatedArguments(IokeObject context) throws ControlFlow {
        return data.getEvaluatedArguments(this, context);
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

    public Object sendTo(IokeObject context, Object recv, List<Object> args) throws ControlFlow {
        return data.sendTo(this, context, recv, args);
    }

    public Object evaluateComplete() throws ControlFlow {
        return data.evaluateComplete(this);
    }

    public Object evaluateCompleteWith(IokeObject ctx, Object ground) throws ControlFlow {
        return data.evaluateCompleteWith(this, ctx, ground);
    }

    public Object evaluateCompleteWithReceiver(IokeObject ctx, Object ground, Object receiver) throws ControlFlow {
        return data.evaluateCompleteWithReceiver(this, ctx, ground, receiver);
    }

    public Object evaluateCompleteWithoutExplicitReceiver(IokeObject ctx, Object ground) throws ControlFlow {
        return data.evaluateCompleteWithoutExplicitReceiver(this, ctx, ground);
    }

    public Object evaluateCompleteWith(Object ground) throws ControlFlow {
        return data.evaluateCompleteWith(this, ground);
    }

    public List<Object> getArguments() throws ControlFlow {
        return data.getArguments(this);
    }

    public int getArgumentCount() throws ControlFlow {
        return data.getArgumentCount(this);
    }

    public String getName() throws ControlFlow {
        return data.getName(this);
    }

    public String getFile() throws ControlFlow {
        return data.getFile(this);
    }

    public int getLine() throws ControlFlow {
        return data.getLine(this);
    }

    public int getPosition() throws ControlFlow {
        return data.getPosition(this);
    }
}// IokeObject
