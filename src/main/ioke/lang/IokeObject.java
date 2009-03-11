/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.List;
import java.util.ArrayList;
import java.util.IdentityHashMap;
import java.util.regex.Pattern;

import ioke.lang.exceptions.ControlFlow;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class IokeObject implements TypeChecker {
    public Runtime runtime;
    private String documentation;
    private Map<String, Object> cells = new LinkedHashMap<String, Object>();
    private List<IokeObject> mimics = new ArrayList<IokeObject>();
    
    private IokeData data;

    private boolean frozen = false;

    public IokeObject(Runtime runtime, String documentation) {
        this(runtime, documentation, IokeData.None);
    }

    public IokeObject(Runtime runtime, String documentation, IokeData data) {
        this.runtime = runtime;
        this.documentation = documentation;
        this.data = data;
    }

    public static boolean same(Object one, Object two) throws ControlFlow {
        if((one instanceof IokeObject) && (two instanceof IokeObject)) {
            return as(one, null).cells == as(two, null).cells;
        } else {
            return one == two;
        }
    }

    private void checkFrozen(String modification, IokeObject message, IokeObject context) throws ControlFlow {
        if(frozen) {
            final IokeObject condition = as(IokeObject.getCellChain(context.runtime.condition, 
                                                                    message, 
                                                                    context,
                                                                    "Error", 
                                                                    "ModifyOnFrozen"), context).mimic(message, context);
            condition.setCell("message", message);
            condition.setCell("context", context);
            condition.setCell("receiver", this);
            condition.setCell("modification", context.runtime.getSymbol(modification));
            context.runtime.errorCondition(condition);
        }
    }

    public void become(IokeObject other, IokeObject message, IokeObject context) throws ControlFlow {
        checkFrozen("become!", message, context);

        this.runtime = other.runtime;
        this.documentation = other.documentation;
        this.cells = other.cells;
        this.mimics = other.mimics;
        this.data = other.data;
        this.frozen = other.frozen;
    }

    public void init() throws ControlFlow {
        data.init(this);
    }

    public static boolean isFrozen(Object on) {
        return (on instanceof IokeObject) && as(on, null).frozen;
    }

    public static void freeze(Object on) {
        if(on instanceof IokeObject) {
            as(on,null).frozen = true;
        }

    }

    public static void thaw(Object on) {
        if(on instanceof IokeObject) {
            as(on, null).frozen = false;
        }
    }

    public void setDocumentation(String docs, IokeObject message, IokeObject context) throws ControlFlow {
        checkFrozen("documentation=", message, context);

        this.documentation = docs;
    }

    public String getDocumentation() {
        return this.documentation;
    }

    public void setData(IokeData data) {
        this.data = data;
    }

    public void setKind(String kind) {
        cells.put("kind", runtime.newText(kind));
    }

    public static List<IokeObject> getMimics(Object on, IokeObject context) {
        return as(on, context).mimics;
    }

    public static void removeMimic(Object on, Object other, IokeObject message, IokeObject context) throws ControlFlow {
        as(on, context).checkFrozen("removeMimic!", message, context);
        as(on, context).mimics.remove(other);
    }

    public static void removeAllMimics(Object on, IokeObject message, IokeObject context) throws ControlFlow {
        as(on, context).checkFrozen("removeAllMimics!", message, context);
        as(on, context).mimics.clear();
    }

    public static Object getRealContext(Object o) {
        if(o instanceof IokeObject) {
            return as(o, null).getRealContext();
        }
        return o;
    }

    public Object getRealContext() {
        return this;
    }

    public IokeObject allocateCopy(IokeObject m, IokeObject context) {
        return new IokeObject(runtime, null, data.cloneData(this, m, context));
    }

    public static Object findSuperCellOn(Object obj, IokeObject early, IokeObject message, IokeObject context, String name) {
        return as(obj, context).findSuperCell(early, message, context, name, new boolean[]{false}, new IdentityHashMap<IokeObject, Object>());
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
        return as(obj, context).findCell(m, context, name, new IdentityHashMap<IokeObject, Object>());
    }

    public static Object findCell(Object obj, IokeObject m, IokeObject context, String name, IdentityHashMap<IokeObject, Object> visited) {
        return as(obj, context).findCell(m, context, name, visited);
    }

    public static Object findPlace(Object obj, String name, IdentityHashMap<IokeObject, Object> visited) {
        return as(obj, null).findPlace(name, visited);
    }

    public static Object findPlace(Object obj, IokeObject m, IokeObject context, String name) throws ControlFlow {
        Object result = findPlace(obj, name, new IdentityHashMap<IokeObject, Object>());
        if(result == m.runtime.nul) {
            final IokeObject condition = as(IokeObject.getCellChain(m.runtime.condition, 
                                                                    m, 
                                                                    context, 
                                                                    "Error", 
                                                                    "NoSuchCell"), context).mimic(m, context);
            condition.setCell("message", m);
            condition.setCell("context", context);
            condition.setCell("receiver", obj);
            condition.setCell("cellName", m.runtime.getSymbol(name));

            m.runtime.withReturningRestart("ignore", context, new RunnableWithControlFlow() {
                    public void run() throws ControlFlow {
                        condition.runtime.errorCondition(condition);
                    }});
            
        }
        return result;
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
            if(cells.get(name) == runtime.nul) {
                return runtime.nul;
            }
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
        return as(on, context).mimic(message, context);
    }

    public IokeObject mimic(IokeObject message, IokeObject context) throws ControlFlow {
        checkFrozen("mimic!", message, context);

        IokeObject clone = allocateCopy(message, context);
        clone.mimics(this, message, context);
        return clone;
    }

    public Object findCell(IokeObject m, IokeObject context, String name) {
        return findCell(m, context, name, new IdentityHashMap<IokeObject, Object>());
    }

    public static boolean isKind(Object on, String kind, IokeObject context) {
        return as(on, context).isKind(kind, new IdentityHashMap<IokeObject, Object>());
    }

    public static boolean isMimic(Object on, IokeObject potentialMimic, IokeObject context) {
        return as(on, context).isMimic(potentialMimic, new IdentityHashMap<Map<String, Object>, Object>());
    }

    public static boolean isKind(IokeObject on, String kind) {
        return as(on, on).isKind(kind, new IdentityHashMap<IokeObject, Object>());
    }

    public static boolean isMimic(IokeObject on, IokeObject potentialMimic) {
        return as(on, on).isMimic(potentialMimic, new IdentityHashMap<Map<String, Object>, Object>());
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

    private boolean isMimic(IokeObject pot, IdentityHashMap<Map<String, Object>, Object> visited) {
        if(visited.containsKey(this.cells)) {
            return false;
        }

        if(this.cells == pot.cells || mimics.contains(pot)) {
            return true;
        }

        visited.put(this.cells, null);
            
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

    public static void removeCell(Object on, IokeObject m, IokeObject context, String name) throws ControlFlow {
        ((IokeObject)on).removeCell(m, context, name);
    }

    public static void undefineCell(Object on, IokeObject m, IokeObject context, String name) throws ControlFlow {
        ((IokeObject)on).undefineCell(m, context, name);
    }

    public Object getCell(IokeObject m, IokeObject context, String name) throws ControlFlow {
        final String outerName = name;
        Object cell = this.findCell(m, context, name);

        while(cell == runtime.nul) {
            final IokeObject condition = as(IokeObject.getCellChain(runtime.condition, 
                                                                    m, 
                                                                    context, 
                                                                    "Error", 
                                                                    "NoSuchCell"), context).mimic(m, context);
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
                    public String report() {
                        return "Use value for: " + outerName;
                    }

                    public List<String> getArgumentNames() {
                        return new ArrayList<String>(Arrays.asList("newValue"));
                    }

                    public IokeObject invoke(IokeObject context, List<Object> arguments) throws ControlFlow {
                        newCell[0] = arguments.get(0);
                        return context.runtime.nil;
                    }
                },
                new Restart.ArgumentGivingRestart("storeValue") {
                    public String report() {
                        return "Store value for: " + outerName;
                    }

                    public List<String> getArgumentNames() {
                        return new ArrayList<String>(Arrays.asList("newValue"));
                    }

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

    public void removeCell(IokeObject m, IokeObject context, String name) throws ControlFlow {
        if(cells.containsKey(name)) {
            cells.remove(name);
        } else {
            final IokeObject condition = as(IokeObject.getCellChain(runtime.condition, 
                                                                    m, 
                                                                    context, 
                                                                    "Error", 
                                                                    "NoSuchCell"), context).mimic(m, context);
            condition.setCell("message", m);
            condition.setCell("context", context);
            condition.setCell("receiver", this);
            condition.setCell("cellName", runtime.getSymbol(name));

            runtime.withReturningRestart("ignore", context, new RunnableWithControlFlow() {
                    public void run() throws ControlFlow {
                        runtime.errorCondition(condition);
                    }});
        }
    }

    public void undefineCell(IokeObject m, IokeObject context, String name) throws ControlFlow {
        cells.put(name, runtime.nul);
    }

    public String getKind(IokeObject message, IokeObject context) throws ControlFlow {
        Object obj = findCell(null, null, "kind");
        if(IokeObject.data(obj) instanceof Text) {
            return ((Text)IokeObject.data(obj)).getText();
        } else {
            return ((Text)IokeObject.data(getOrActivate(obj, context, message, this))).getText();
        }
    }

    public String getKind() {
        Object obj = findCell(null, null, "kind");
        if(obj != null && IokeObject.data(obj) instanceof Text) {
            return ((Text)IokeObject.data(obj)).getText();
        } else {
            return null;
        }
    }

    public boolean hasKind() {
        return cells.containsKey("kind");
    }

    public static Object getOrActivate(Object obj, IokeObject context, IokeObject message, Object on) throws ControlFlow {
        if(obj instanceof IokeObject) {
            return as(obj, context).getOrActivate(context, message, on);
        } else {
            return obj;
        }
    }

    public static Object perform(Object obj, IokeObject ctx, IokeObject message) throws ControlFlow {
        if((obj instanceof IokeObject) || IokeRegistry.isWrapped(obj, ctx)) {
            return as(obj, ctx).perform(ctx, message);
        } else {
            return performJava(obj, ctx, message);
        }
    }

    private static Object performJava(Object obj, IokeObject ctx, IokeObject message) throws ControlFlow {
        final IokeObject clz = IokeRegistry.wrap(obj.getClass(), ctx);
        final Runtime runtime = ctx.runtime;
        final String name = message.getName();
        final String outerName = name;
        Object cell = clz.findCell(message, ctx, name);

        while(cell == runtime.nul && ((cell = clz.findCell(message, ctx, "pass")) == runtime.nul)) {
            final IokeObject condition = as(IokeObject.getCellChain(runtime.condition, 
                                                                    message, 
                                                                    ctx, 
                                                                    "Error", 
                                                                    "NoSuchCell"), ctx).mimic(message, ctx);
            condition.setCell("message", message);
            condition.setCell("context", ctx);
            condition.setCell("receiver", obj);
            condition.setCell("cellName", runtime.getSymbol(name));

            final Object[] newCell = new Object[]{cell};

            runtime.withRestartReturningArguments(new RunnableWithControlFlow() {
                    public void run() throws ControlFlow {
                        runtime.errorCondition(condition);
                    }}, 
                ctx,
                new Restart.ArgumentGivingRestart("useValue") { 
                    public String report() {
                        return "Use value for: " + outerName;
                    }

                    public List<String> getArgumentNames() {
                        return new ArrayList<String>(Arrays.asList("newValue"));
                    }

                    public IokeObject invoke(IokeObject context, List<Object> arguments) throws ControlFlow {
                        newCell[0] = arguments.get(0);
                        return context.runtime.nil;
                    }
                },
                new Restart.ArgumentGivingRestart("storeValue") {
                    public String report() {
                        return "Store value for: " + outerName;
                    }

                    public List<String> getArgumentNames() {
                        return new ArrayList<String>(Arrays.asList("newValue"));
                    }

                    public IokeObject invoke(IokeObject context, List<Object> arguments) throws ControlFlow {
                        newCell[0] = arguments.get(0);
                        clz.setCell(outerName, newCell[0]);
                        return context.runtime.nil;
                    }
                }
                );

            cell = newCell[0];
        }

        return clz.getOrActivate(cell, ctx, message, obj);
    }

    public Object perform(IokeObject ctx, IokeObject message) throws ControlFlow {
        return perform(ctx, message, message.getName());
    }

    public Object perform(IokeObject ctx, IokeObject message, final String name) throws ControlFlow {
        final String outerName = name;
        Object cell = this.findCell(message, ctx, name);

        while(cell == runtime.nul && ((cell = this.findCell(message, ctx, "pass")) == runtime.nul)) {
            final IokeObject condition = as(IokeObject.getCellChain(runtime.condition, 
                                                                    message, 
                                                                    ctx, 
                                                                    "Error", 
                                                                    "NoSuchCell"), ctx).mimic(message, ctx);
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
                    public String report() {
                        return "Use value for: " + outerName;
                    }

                    public List<String> getArgumentNames() {
                        return new ArrayList<String>(Arrays.asList("newValue"));
                    }

                    public IokeObject invoke(IokeObject context, List<Object> arguments) throws ControlFlow {
                        newCell[0] = arguments.get(0);
                        return context.runtime.nil;
                    }
                },
                new Restart.ArgumentGivingRestart("storeValue") {
                    public String report() {
                        return "Store value for: " + outerName;
                    }

                    public List<String> getArgumentNames() {
                        return new ArrayList<String>(Arrays.asList("newValue"));
                    }

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

    public static void setCell(Object on, String name, Object value, IokeObject context) {
        as(on, context).setCell(name, value);
    }

    public static void setCell(IokeObject on, String name, Object value) {
        as(on, on).setCell(name, value);
    }

    public void setCell(String name, Object value) {
        cells.put(name, value);
    }

    public static void assign(Object on, String name, Object value, IokeObject context, IokeObject message) throws ControlFlow {
        as(on, context).assign(name, value, context, message);
    }

    public final static Pattern SLIGHTLY_BAD_CHARS = Pattern.compile("[!=\\.\\-\\+&|\\{\\[]");
    public void assign(String name, Object value, IokeObject context, IokeObject message) throws ControlFlow {
        checkFrozen("=", message, context);

        if(!SLIGHTLY_BAD_CHARS.matcher(name).find() && findCell(message, context, name + "=") != runtime.nul) {
            runtime.createMessage(new Message(runtime, name + "=", runtime.createMessage(Message.wrap(as(value, context))))).sendTo(context, this);
        } else {
            cells.put(name, value);
        }
    }

    public boolean isSymbol() {
        return data.isSymbol();
    }

    public boolean isNil() {
        return data.isNil();
    }

    public static boolean isTrue(Object on) {
        return !(on instanceof IokeObject) || as(on, null).isTrue();
    }

    public boolean isTrue() {
        return data.isTrue();
    }

    public static boolean isMessage(Object obj) {
        return (obj instanceof IokeObject) && as(obj, null).isMessage();
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
        checkFrozen("mimic!", message, context);

        mimic.data.checkMimic(mimic, message, context);
        if(!this.mimics.contains(mimic)) {
            this.mimics.add(mimic);
        }
    }

    public void mimics(int index, IokeObject mimic, IokeObject message, IokeObject context) throws ControlFlow {
        checkFrozen("prependMimic!", message, context);

        mimic.data.checkMimic(mimic, message, context);
        if(!this.mimics.contains(mimic)) {
            this.mimics.add(index, mimic);
        }
    }

    public void registerMethod(IokeObject m) {
        cells.put(((Method)m.data).getName(), m);
    }

    public void aliasMethod(String originalName, String newName, IokeObject message, IokeObject context) throws ControlFlow {
        checkFrozen("aliasMethod", message, context);

        IokeObject io = as(findCell(null, null, originalName), context);
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

    public static Map<String, Object> getCells(Object on, IokeObject context) {
        return as(on, context).getCells();
    }

    public Map<String, Object> getCells() {
        return cells;
    }

    public static IokeData data(Object on) {
        return ((IokeObject)on).data;
    }

    public static IokeObject as(Object on, IokeObject context) {
        if(on instanceof IokeObject) {
            return ((IokeObject)on);
        } else {
            return IokeRegistry.wrap(on, context);
        }
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

    public static Object convertTo(String kind, Object on, boolean signalCondition, String conversionMethod, IokeObject message, IokeObject context) throws ControlFlow {
        return ((IokeObject)on).convertTo(kind, signalCondition, conversionMethod, message, context);
    }

    public static Object convertTo(Object mimic, Object on, boolean signalCondition, String conversionMethod, IokeObject message, IokeObject context) throws ControlFlow {
        return ((IokeObject)on).convertTo(mimic, signalCondition, conversionMethod, message, context);
    }

    public static IokeObject convertToRational(Object on, IokeObject m, IokeObject context, boolean signalCondition) throws ControlFlow {
        return ((IokeObject)on).convertToRational(m, context, signalCondition);
    }

    public static IokeObject convertToDecimal(Object on, IokeObject m, IokeObject context, boolean signalCondition) throws ControlFlow {
        return ((IokeObject)on).convertToDecimal(m, context, signalCondition);
    }

    public Object convertTo(String kind, boolean signalCondition, String conversionMethod, IokeObject message, IokeObject context) throws ControlFlow {
        Object result = data.convertTo(this, kind, false, conversionMethod, message, context);
        if(result == null) {
            if(conversionMethod != null && findCell(message, context, conversionMethod) != context.runtime.nul) {
                return context.runtime.newMessage(conversionMethod).sendTo(context, this);
            }
            if(signalCondition) {
                return data.convertTo(this, kind, true, conversionMethod, message, context);
            }
            return context.runtime.nul;
        }
        return result;
    }

    public Object convertTo(Object mimic, boolean signalCondition, String conversionMethod, IokeObject message, IokeObject context) throws ControlFlow {
        Object result = data.convertTo(this, mimic, false, conversionMethod, message, context);
        if(result == null) {
            if(conversionMethod != null && findCell(message, context, conversionMethod) != context.runtime.nul) {
                return context.runtime.newMessage(conversionMethod).sendTo(context, this);
            }
            if(signalCondition) {
                return data.convertTo(this, mimic, true, conversionMethod, message, context);
            }
            return context.runtime.nul;
        }
        return result;
    }

    public Object convertToThis(Object on, IokeObject message, IokeObject context) throws ControlFlow {
    	return convertToThis(on, true, message, context);
    }
    
    public Object convertToThis(Object on, boolean signalCondition, IokeObject message, IokeObject context) throws ControlFlow {
        if(on instanceof IokeObject) {
            if(IokeObject.data(on).getClass().equals(data.getClass())) {
                return on;
            } else {
                return IokeObject.convertTo(this, on, signalCondition, IokeObject.data(on).getConvertMethod(), message, context);
            }
        } else {
            if(signalCondition) {
                throw new RuntimeException("oh no. -(: " + message.getName());
            } else {
                return context.runtime.nul;
            }
        }
    }

    public static Object ensureTypeIs(Class<?> clazz, IokeObject self, Object on, final IokeObject context, IokeObject message) throws ControlFlow {
        final Object[] receiver = new Object[] { on };
        while(!clazz.isInstance(IokeObject.data(receiver[0]))) {
            final IokeObject condition = as(IokeObject.getCellChain(context.runtime.condition, 
                                                                               message, 
                                                                               context, 
                                                                               "Error", 
                                                                               "Type",
                                                                               "IncorrectType"), context).mimic(message, context);
            condition.setCell("message", message);
            condition.setCell("context", context);
            condition.setCell("receiver", self);
            condition.setCell("expectedType", context.runtime.nil);

            context.runtime.withRestartReturningArguments(new RunnableWithControlFlow() {
                public void run() throws ControlFlow {
                    context.runtime.errorCondition(condition);
                }}, 
                context,
                new Restart.ArgumentGivingRestart("useValue") { 
                    public List<String> getArgumentNames() {
                        return new ArrayList<String>(Arrays.asList("newValue"));
                    }

                    public IokeObject invoke(IokeObject context, List<Object> arguments) throws ControlFlow {
                        receiver[0] = arguments.get(0);
                        return context.runtime.nil;
                    }
                }
            );
        }
        return receiver[0];
    }
    
    public IokeObject convertToRational(IokeObject m, IokeObject context, boolean signalCondition) throws ControlFlow {
        IokeObject result = data.convertToRational(this, m, context, false);
        if(result == null) {
            if(findCell(m, context, "asRational") != context.runtime.nul) {
                return IokeObject.as(context.runtime.asRational.sendTo(context, this), context);
            }
            if(signalCondition) {
                return data.convertToRational(this, m, context, true);
            }
            return context.runtime.nil;
        }
        return result;
    }

    public IokeObject convertToDecimal(IokeObject m, IokeObject context, boolean signalCondition) throws ControlFlow {
        IokeObject result = data.convertToDecimal(this, m, context, false);
        if(result == null) {
            if(findCell(m, context, "asDecimal") != context.runtime.nul) {
                return IokeObject.as(context.runtime.asDecimal.sendTo(context, this), context);
            }
            if(signalCondition) {
                return data.convertToDecimal(this, m, context, true);
            }
            return context.runtime.nil;
        }
        return result;
    }

    public static IokeObject convertToText(Object on, IokeObject m, IokeObject context, boolean signalCondition) throws ControlFlow {
        return ((IokeObject)on).convertToText(m, context, signalCondition);
    }

    public static IokeObject tryConvertToText(Object on, IokeObject m, IokeObject context) throws ControlFlow {
        return ((IokeObject)on).tryConvertToText(m, context);
    }

    public static IokeObject convertToSymbol(Object on, IokeObject m, IokeObject context, boolean signalCondition) throws ControlFlow {
        return ((IokeObject)on).convertToSymbol(m, context, signalCondition);
    }

    public static IokeObject convertToRegexp(Object on, IokeObject m, IokeObject context) throws ControlFlow {
        return ((IokeObject)on).convertToRegexp(m, context);
    }

    public static String inspect(Object on) throws ControlFlow {
        IokeObject ion = (IokeObject)on;
        Runtime runtime = ion.runtime;
        return Text.getText(runtime.inspectMessage.sendTo(ion, ion));
    }

    public static String notice(Object on) throws ControlFlow {
        IokeObject ion = (IokeObject)on;
        Runtime runtime = ion.runtime;
        return Text.getText(runtime.noticeMessage.sendTo(ion, ion));
    }

    public IokeObject convertToText(IokeObject m, IokeObject context, boolean signalCondition) throws ControlFlow {
        IokeObject result = data.convertToText(this, m, context, false);
        if(result == null) {
            if(findCell(m, context, "asText") != context.runtime.nul) {
                return as(context.runtime.asText.sendTo(context, this), context);
            }
            if(signalCondition) {
                return data.convertToText(this, m, context, true);
            }
            return context.runtime.nil;
        }
        return result;
    }

    public IokeObject tryConvertToText(IokeObject m, IokeObject context) throws ControlFlow {
        return data.tryConvertToText(this, m, context);
    }

    public IokeObject convertToSymbol(IokeObject m, IokeObject context, boolean signalCondition) throws ControlFlow {
        IokeObject result = data.convertToSymbol(this, m, context, false);
        if(result == null) {
            if(findCell(m, context, "asSymbol") != context.runtime.nul) {
                return as(context.runtime.asSymbol.sendTo(context, this), context);
            }
            if(signalCondition) {
                return data.convertToSymbol(this, m, context, true);
            }
            return context.runtime.nil;
        }
        return result;
    }

    public IokeObject convertToRegexp(IokeObject m, IokeObject context) throws ControlFlow {
        return data.convertToRegexp(this, m, context);
    }

    public Object getOrActivate(IokeObject context, IokeObject message, Object on) throws ControlFlow {
        if(isActivatable() || ((data instanceof AssociatedCode) && message.getArguments().size() > 0)) {
            return activate(context, message, on);
        } else {
            return this;
        }
    }

    public String toString() {
        return data.toString(this);
    }

    public static Object activate(Object self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
        return as(self, context).activate(context, message, on);
    }

    public Object activate(IokeObject context, IokeObject message, Object on) throws ControlFlow {
        return data.activate(this, context, message, on);
    }

    public Object activateWithData(IokeObject context, IokeObject message, Object on, Map<String, Object> d1) throws ControlFlow {
        return data.activateWithData(this, context, message, on, d1);
    }

    public Object activateWithCall(IokeObject context, IokeObject message, Object on, Object c) throws ControlFlow {
        return data.activateWithCall(this, context, message, on, c);
    }

    public Object activateWithCallAndData(IokeObject context, IokeObject message, Object on, Object c, Map<String, Object> d1) throws ControlFlow {
        return data.activateWithCallAndData(this, context, message, on, c, d1);
    }

    @Override
    public boolean equals(Object other) {
        try {
            return isEqualTo(other);
        } catch(Exception e) {
            return false;
        }
    }

    @Override
    public int hashCode() {
        return iokeHashCode();
    }

    public static boolean equals(Object lhs, Object rhs) {
        return ((IokeObject)lhs).isEqualTo(rhs);
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

    // TypeChecker
    public Object convertToMimic(Object on, IokeObject message, IokeObject context, boolean signal) throws ControlFlow {
        return convertToThis(on, signal, message, context);
    }
}// IokeObject
