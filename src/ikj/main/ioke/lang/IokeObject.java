/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.Collection;
import java.util.Map;
import java.util.List;
import java.util.ArrayList;
import java.util.regex.Pattern;

import ioke.lang.exceptions.ControlFlow;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public final class IokeObject implements TypeChecker {
    public Runtime runtime;
    IokeData data;
    Body body = new Body();

    public static final int FALSY_F = 1 << 0;
    public static final int NIL_F = 1 << 1;
    public static final int FROZEN_F = 1 << 2;
    public static final int ACTIVATABLE_F = 1 << 3;
    public static final int HAS_ACTIVATABLE_F = 1 << 4;
    public static final int LEXICAL_F = 1 << 5;

    public final boolean isNil() {
        return (body.flags & NIL_F) != 0;
    }

    public final boolean isTrue() {
        return (body.flags & FALSY_F) == 0;
    }

    public final boolean isFrozen() {
        return (body.flags & FROZEN_F) != 0;
    }

    public final void setFrozen(boolean frozen) {
        if (frozen) {
            body.flags |= FROZEN_F;
        } else {
            body.flags &= ~FROZEN_F;
        }
    }

    public final boolean isActivatable() {
        return (body.flags & ACTIVATABLE_F) != 0;
    }

    public final boolean isSetActivatable() {
        return (body.flags & HAS_ACTIVATABLE_F) != 0;
    }

    public final void setActivatable(boolean activatable) {
        body.flags |= HAS_ACTIVATABLE_F;
        if (activatable) {
            body.flags |= ACTIVATABLE_F;
        } else {
            body.flags &= ~ACTIVATABLE_F;
        }
    }

    public final boolean isLexical() {
        return (body.flags & LEXICAL_F) != 0;
    }
    
    public IokeObject(Runtime runtime, String documentation) {
        this(runtime, documentation, IokeData.None);
    }

    public IokeObject(Runtime runtime, String documentation, IokeData data) {
        this.runtime = runtime;
        this.body.documentation = documentation;
        this.data = data;
    }

    public static boolean same(Object one, Object two) throws ControlFlow {
        if((one instanceof IokeObject) && (two instanceof IokeObject)) {
            return as(one, null).body == as(two, null).body;
        } else {
            return one == two;
        }
    }

    private void checkFrozen(String modification, IokeObject message, IokeObject context) throws ControlFlow {
        if(isFrozen()) {
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
        this.data = other.data;
        this.body = other.body;
    }

    public void init() throws ControlFlow {
        data.init(this);
    }

    public static boolean isFrozen(Object on) {
        return (on instanceof IokeObject) && as(on, null).isFrozen();
    }

    public static void freeze(Object on) {
        if(on instanceof IokeObject) {
            as(on,null).setFrozen(true);
        }
    }

    public static void thaw(Object on) {
        if(on instanceof IokeObject) {
            as(on, null).setFrozen(false);
        }
    }

    public void setDocumentation(String docs, IokeObject message, IokeObject context) throws ControlFlow {
        checkFrozen("documentation=", message, context);

        this.body.documentation = docs;
    }

    public String getDocumentation() {
        return this.body.documentation;
    }

    public void setData(IokeData data) {
        this.data = data;
    }

    public void setKind(String kind) {
        body.put("kind", runtime.newText(kind));
    }

    public static List<IokeObject> getMimics(Object on, IokeObject context) {
        return as(on, context).getMimics();
    }

    private int mimicIndex(Object other) {
        if(body.mimicCount == 1) {
            return body.mimic == other ? -2 : -1;
        }

        for(int i = 0; i < body.mimicCount; i++) {
            if(body.mimics[i] == other) {
                return i;
            }
        }
        return -1;
    }

    private void removeMimicAt(int index) {
        switch(index) {
        case -2:
            body.mimic = null;
            body.mimicCount--;
            break;
        case 0:
            if(body.mimicCount-- == 2) {
                body.mimic = body.mimics[1];
                body.mimics = null;
            } else {
                IokeObject[] newMimics = new IokeObject[body.mimicCount];
                System.arraycopy(body.mimics, 1, newMimics, 0, body.mimicCount);
                body.mimics = newMimics;
            }
            break;
        default:
            if(index == body.mimicCount - 1) {
                if(body.mimicCount-- == 2) {
                    body.mimic = body.mimics[0];
                    body.mimics = null;
                } else {
                    body.mimics[index] = null;
                }
            } else {
                IokeObject[] newMimics = new IokeObject[body.mimicCount];
                System.arraycopy(body.mimics, 0, newMimics, 0, index);
                System.arraycopy(body.mimics, index + 1, newMimics, index, body.mimicCount - (index + 1));
                body.mimics = newMimics;
                body.mimicCount--;
            }
            break;
        }
    }

    public static void removeMimic(Object on, Object other, IokeObject message, IokeObject context) throws ControlFlow {
        IokeObject me = as(on, context);
        me.checkFrozen("removeMimic!", message, context);
        int ix = me.mimicIndex(other);
        if(ix != -1) {
            me.removeMimicAt(ix);
            if(me.body.hooks != null) {
                Hook.fireMimicsChanged(me, message, context, other);
                Hook.fireMimicRemoved(me, message, context, other);
            }
        }
    }

    public static void removeAllMimics(Object on, IokeObject message, IokeObject context) throws ControlFlow {
        IokeObject me = as(on, context);
        me.checkFrozen("removeAllMimics!", message, context);

        if(me.body.mimicCount == 1) {
            Hook.fireMimicsChanged(me, message, context, me.body.mimic);
            Hook.fireMimicRemoved(me, message, context, me.body.mimic);
            me.body.mimicCount--;
        } else {
            while(me.body.mimicCount > 0) {
                Hook.fireMimicsChanged(me, message, context, me.body.mimics[me.body.mimicCount-1]);
                Hook.fireMimicRemoved(me, message, context, me.body.mimics[me.body.mimicCount-1]);
                me.body.mimicCount--;
            }
        }

        me.body.mimic = null;
        me.body.mimics = null;
    }

    public static Object getRealContext(Object o) {
        if(o instanceof IokeObject) {
            return as(o, null).getRealContext();
        }
        return o;
    }

    public final Object getRealContext() {
        if(isLexical()) {
            return ((LexicalContext)this.data).ground;
        } else {
            return this;
        }
    }

    public IokeObject allocateCopy(IokeObject m, IokeObject context) {
        return new IokeObject(runtime, null, data.cloneData(this, m, context));
    }

    public static Object findSuperCellOn(Object obj, IokeObject early, IokeObject context, String name) {
        if(name == null) {
            throw new RuntimeException("can't be asked to find the super cell named null");
        }

        return as(obj, context).markingFindSuperCell(early, name, new boolean[]{false});
    }

    protected final Object realMarkingFindSuperCell(IokeObject early, String name, boolean[] found) {
        if(body.has(name)) {
            if(found[0]) {
                return body.get(name);
            }
            if(early == body.get(name)) {
                found[0] = true;
            }
        }
        
        if(body.mimicCount == 1) {
            return body.mimic.markingFindSuperCell(early, name, found);
        } else {
            for(int i = 0; i<body.mimicCount; i++) {
                Object cell = body.mimics[i].markingFindSuperCell(early, name, found);
                if(cell != runtime.nul) {
                    return cell;
                }
            }
            return runtime.nul;
        }
    }

    protected final Object markingFindSuperCell(IokeObject early, String name, boolean[] found) {
        Object nn = realMarkingFindSuperCell(early, name, found);
        if(nn == runtime.nul && isLexical()) {
            return ((LexicalContext)this.data).surroundingContext.realMarkingFindSuperCell(early, name, new boolean[]{false});
        }
        return nn;
    }

    public static Object findPlace(Object obj, String name) {
        return as(obj, null).markingFindPlace(name);
    }

    public static Object findPlace(Object obj, IokeObject m, IokeObject context, String name) throws ControlFlow {
        Object result = findPlace(obj, name);
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
        return markingFindPlace(name);
    }

    protected final Object markingFindPlace(String name) {
        if(body.has(name)) {
            if(body.get(name) == runtime.nul) {
                if(isLexical()) {
                    return IokeObject.findPlace(((LexicalContext)this.data).surroundingContext, name);
                }
                return runtime.nul;
            }
            return this;
        } else {
            if(body.mimic != null) {
                Object place = body.mimic.markingFindPlace(name);
                if(place != runtime.nul) {
                    return place;
                }
            } else {
                for(int i = 0; i<body.mimicCount; i++) {
                    Object place = body.mimics[i].markingFindPlace(name);
                    if(place != runtime.nul) {
                        return place;
                    }
                }
            }
                
            if(isLexical()) {
                return IokeObject.findPlace(((LexicalContext)this.data).surroundingContext, name);
            }
            return runtime.nul;
        }
    }

    public static final Object findCell(IokeObject on, String name) {
        Object cell;
        IokeObject nul = on.runtime.nul;
        IokeObject c = on;

        while(true) {
            Body b = c.body;
            if((cell = b.get(name)) != null) {
                if(cell == nul && c.isLexical()) {
                    c = ((LexicalContext)c.data).surroundingContext;
                } else {
                    return cell;
                }
            } else {
                if(b.mimic != null) {
                    if(c.isLexical()) {
                        if((cell = findCell(b.mimic, name)) != nul) {
                            return cell;
                        }
                        c = ((LexicalContext)c.data).surroundingContext;
                    } else {
                        c = b.mimic;
                    }
                } else {
                    for(int i = 0; i<b.mimicCount; i++) {
                        if((cell = findCell(b.mimics[i], name)) != nul) {
                            return cell;
                        }
                    }
                    if(c.isLexical()) {
                        c = ((LexicalContext)c.data).surroundingContext;
                    } else {
                        return nul;
                    }
                }
            }
        }
    }

    public static final Object findCell(Object on, IokeObject context, String name) {
        return findCell(as(on, context), name);
    }

    public static IokeObject mimic(Object on, IokeObject message, IokeObject context) throws ControlFlow {
        return as(on, context).mimic(message, context);
    }

    public IokeObject mimic(IokeObject message, IokeObject context) throws ControlFlow {
        checkFrozen("mimic!", message, context);

        IokeObject clone = allocateCopy(message, context);
        clone.singleMimics(this, message, context);
        return clone;
    }

    public static boolean isKind(Object on, String kind, IokeObject context) {
        return as(on, context).isKind(kind);
    }

    public static boolean isMimic(Object on, IokeObject potentialMimic, IokeObject context) {
        return as(on, context).isMimic(potentialMimic);
    }

    public static boolean isKind(IokeObject on, String kind) {
        return as(on, on).isKind(kind);
    }

    public static boolean isMimic(IokeObject on, IokeObject potentialMimic) {
        return as(on, on).isMimic(potentialMimic);
    }

    private boolean isKind(String kind) {

        Object c = body.get("kind");

        if(c != null && Text.isText(c) && kind.equals(Text.getText(c))) {
            return true;
        }
        
        if(body.mimic != null) {
            return body.mimic.isKind(kind);
        } else {
            for(int i = 0; i<body.mimicCount; i++) {
                if(body.mimics[i].isKind(kind)) {
                    return true;
                }
            }
        }
        return false;
    }

    private final boolean containsMimic(IokeObject obj) {
        if(body.mimicCount == 1) {
            return obj == body.mimic;
        }

        if(body.mimic != null) {
            return body.mimic == obj;
        } else {
            for(int i = 0; i < body.mimicCount; i++) {
                if(body.mimics[i] == obj) {
                    return true;
                }
            }
        }
        return false;
    }

    private boolean isMimic(IokeObject pot) {
        if(this.body == pot.body || containsMimic(pot)) {
            return true;
        }

        if(body.mimic != null) {
            return body.mimic.isMimic(pot);
        } else {
            for(int i = 0; i<body.mimicCount; i++) {
                if(body.mimics[i].isMimic(pot)) {
                    return true;
                }
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
        Object cell = findCell(this, name);

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
        checkFrozen("removeCell!", m, context);
        if(body.has(name)) {
            Object prev = body.remove(name);
            if(body.hooks != null) {
                Hook.fireCellChanged(this, m, context, name, prev);
                Hook.fireCellRemoved(this, m, context, name, prev);
            }
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
        checkFrozen("undefineCell!", m, context);
        Object prev = body.get(name);
        body.put(name, runtime.nul);
        if(body.hooks != null) {
            if(prev == null) {
                prev = runtime.nil;
            }
            Hook.fireCellChanged(this, m, context, name, prev);
            Hook.fireCellUndefined(this, m, context, name, prev);
        }
    }

    public String getKind(IokeObject message, IokeObject context) throws ControlFlow {
        Object obj = findCell(this, "kind");
        if(IokeObject.data(obj) instanceof Text) {
            return ((Text)IokeObject.data(obj)).getText();
        } else {
            return ((Text)IokeObject.data(Interpreter.getOrActivate(obj, context, message, this))).getText();
        }
    }

    public String getKind() {
        Object obj = findCell(this, "kind");
        if(obj != null && IokeObject.data(obj) instanceof Text) {
            return ((Text)IokeObject.data(obj)).getText();
        } else {
            return null;
        }
    }

    public boolean hasKind() {
        return body.has("kind");
    }

    public static void setCell(Object on, String name, Object value, IokeObject context) {
        as(on, context).setCell(name, value);
    }

    public static void setCell(IokeObject on, String name, Object value) {
        as(on, on).setCell(name, value);
    }

    public void setCell(String name, Object value) {
        body.put(name, value);
    }

    public static void assign(Object on, String name, Object value, IokeObject context, IokeObject message) throws ControlFlow {
        as(on, context).assign(name, value, context, message);
    }

    public final static Pattern SLIGHTLY_BAD_CHARS = Pattern.compile("[!=\\.\\-\\+&|\\{\\[]");

    public final void assign(String name, Object value, IokeObject context, IokeObject message) throws ControlFlow {
        if(isLexical()) {
            Object place = findPlace(name);
            if(place == runtime.nul) {
                place = this;
            }
            IokeObject.setCell(place, name, value, context);
        } else {
            checkFrozen("=", message, context);

            if(!SLIGHTLY_BAD_CHARS.matcher(name).find() && findCell(this, name + "=") != runtime.nul) {
                IokeObject msg = runtime.createMessage(new Message(runtime, name + "=", runtime.createMessage(Message.wrap(as(value, context)))));
                Interpreter.send(msg, context, this);
            } else {
                if(body.hooks != null) {
                    boolean contains = body.has(name);
                    Object prev = context.runtime.nil;
                    if(contains) {
                        prev = body.get(name);
                    }
                    body.put(name, value);
                    if(!contains) {
                        Hook.fireCellAdded(this, message, context, name);
                    }
                    Hook.fireCellChanged(this, message, context, name, prev);
                } else {
                    body.put(name, value);
                }
            }
        }
    }

    public boolean isSymbol() {
        return data.isSymbol();
    }

    public static boolean isTrue(Object on) {
        return !(on instanceof IokeObject) || as(on, null).isTrue();
    }

    public static boolean isMessage(Object obj) {
        return (obj instanceof IokeObject) && as(obj, null).isMessage();
    }

    public boolean isMessage() {
        return data.isMessage();
    }

    public List<IokeObject> getMimics() {
        switch(body.mimicCount) {
        case 0:
            return Arrays.asList();
        case 1:
            return Arrays.asList(body.mimic);
        default:
            return Arrays.asList(body.mimics).subList(0, body.mimicCount);
        }
    }

    private final void transplantActivation(IokeObject mimic) {
        if(!this.isSetActivatable() && mimic.isSetActivatable()) {
            this.setActivatable(mimic.isActivatable());
        }
    }

    private void addMimic(IokeObject mimic) {
        addMimic(body.mimicCount, mimic);
    }

    private void addMimic(int at, IokeObject mimic) {
        switch(body.mimicCount) {
        case 0:
            body.mimic = mimic;
            body.mimicCount = 1;
            break;
        case 1:
            if(at == 0) {
                body.mimics = new IokeObject[]{mimic, body.mimic};
            } else {
                body.mimics = new IokeObject[]{body.mimic, mimic};
            }
            body.mimicCount = 2;
            body.mimic = null;
            break;
        default:
            if(at == 0) {
                int newLen = body.mimicCount + 1;
                IokeObject[] newMimics;
                if(body.mimics.length < newLen) {
                    newMimics = new IokeObject[newLen];
                } else {
                    newMimics = body.mimics;
                }
                System.arraycopy(body.mimics, 0, newMimics, 1, newLen - 1);
                body.mimics = newMimics;
                newMimics[0] = mimic;
                body.mimicCount++;
            } else if(at == body.mimicCount) {
                if(body.mimicCount == body.mimics.length) {
                    IokeObject[] newMimics = new IokeObject[body.mimics.length + 1];
                    System.arraycopy(body.mimics, 0, newMimics, 0, body.mimics.length);
                    body.mimics = newMimics;
                }
                body.mimics[body.mimicCount++] = mimic;
            } else {
                if(body.mimicCount == body.mimics.length) {
                    IokeObject[] newMimics = new IokeObject[body.mimics.length + 1];
                    System.arraycopy(body.mimics, 0, newMimics, 0, at);
                    System.arraycopy(body.mimics, at, newMimics, at+1, body.mimicCount - at);
                    body.mimics = newMimics;
                    body.mimics[at] = mimic;
                } else {
                    System.arraycopy(body.mimics, at, body.mimics, at + 1, body.mimicCount - at);
                    body.mimics[at] = mimic;
                }
                body.mimicCount++;
            }
            break;
        }
    }

    public void singleMimicsWithoutCheck(IokeObject mimic) {
        body.mimic = mimic;
        body.mimicCount = 1;
        transplantActivation(mimic);
    }

    public void mimicsWithoutCheck(IokeObject mimic) {
        if(!containsMimic(mimic)) {
            addMimic(mimic);
            transplantActivation(mimic);
        }
    }

    public void mimicsWithoutCheck(int index, IokeObject mimic) {
        if(!containsMimic(mimic)) {
            addMimic(index, mimic);
            transplantActivation(mimic);
        }
    }

    public void singleMimics(IokeObject mimic, IokeObject message, IokeObject context) throws ControlFlow {
        checkFrozen("mimic!", message, context);

        mimic.data.checkMimic(mimic, message, context);
        body.mimic = mimic;
        body.mimicCount = 1;
        transplantActivation(mimic);
        if(mimic.body.hooks != null) {
            Hook.fireMimicked(mimic, message, context, this);
        }
        if(body.hooks != null) {
            Hook.fireMimicsChanged(this, message, context, mimic);
            Hook.fireMimicAdded(this, message, context, mimic);
        }
    }

    public void mimics(IokeObject mimic, IokeObject message, IokeObject context) throws ControlFlow {
        checkFrozen("mimic!", message, context);

        mimic.data.checkMimic(mimic, message, context);
        if(!containsMimic(mimic)) {
            addMimic(mimic);
            transplantActivation(mimic);
            if(mimic.body.hooks != null) {
                Hook.fireMimicked(mimic, message, context, this);
            }
            if(body.hooks != null) {
                Hook.fireMimicsChanged(this, message, context, mimic);
                Hook.fireMimicAdded(this, message, context, mimic);
            }
        }
    }

    public void mimics(int index, IokeObject mimic, IokeObject message, IokeObject context) throws ControlFlow {
        checkFrozen("prependMimic!", message, context);

        mimic.data.checkMimic(mimic, message, context);
        if(!containsMimic(mimic)) {
            addMimic(index, mimic);
            transplantActivation(mimic);
            if(mimic.body.hooks != null) {
                Hook.fireMimicked(mimic, message, context, this);
            }
            if(body.hooks != null) {
                Hook.fireMimicsChanged(this, message, context, mimic);
                Hook.fireMimicAdded(this, message, context, mimic);
            }
        }
    }

    public void registerMethod(IokeObject m) {
        body.put(((Method)m.data).getName(), m);
    }

    public void aliasMethod(String originalName, String newName, IokeObject message, IokeObject context) throws ControlFlow {
        checkFrozen("aliasMethod", message, context);

        IokeObject io = as(findCell(this, originalName), context);
        IokeObject newObj = io.mimic(null, null);
        newObj.data = new AliasMethod(newName, io.data, io);
        body.put(newName, newObj);
    }

    public void registerMethod(String name, IokeObject m) {
        body.put(name, m);
    }

    public void registerCell(String name, Object o) {
        body.put(name, o);
    }

    public IokeObject negate() {
        return data.negate(this);
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

    public final Object getSelf() {
        if(isLexical()) {
            return ((LexicalContext)this.data).surroundingContext.getSelf();
        } else {
            return this.body.get("self");
        }
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
            if(conversionMethod != null && findCell(this, conversionMethod) != context.runtime.nul) {
                IokeObject msg = context.runtime.newMessage(conversionMethod);
                return Interpreter.send(msg, context, this);
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
            if(conversionMethod != null && findCell(this, conversionMethod) != context.runtime.nul) {
                IokeObject msg = context.runtime.newMessage(conversionMethod);
                return Interpreter.send(msg, context, this);
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
            if(findCell(this, "asRational") != context.runtime.nul) {
                return IokeObject.as(Interpreter.send(context.runtime.asRational, context, this), context);
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
            if(findCell(this, "asDecimal") != context.runtime.nul) {
                return IokeObject.as(Interpreter.send(context.runtime.asDecimal, context, this), context);
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
        if(on instanceof IokeObject) {
            IokeObject ion = (IokeObject)on;
            Runtime runtime = ion.runtime;
            return Text.getText(Interpreter.send(runtime.inspectMessage, ion, ion));
        } else {
            return on.toString();
        }
    }

    public static String notice(Object on) throws ControlFlow {
        if(on instanceof IokeObject) {
            IokeObject ion = (IokeObject)on;
            Runtime runtime = ion.runtime;
            return Text.getText(Interpreter.send(runtime.noticeMessage, ion, ion));
        } else {
            return on.toString();
        }
    }

    public IokeObject convertToText(IokeObject m, IokeObject context, boolean signalCondition) throws ControlFlow {
        IokeObject result = data.convertToText(this, m, context, false);
        if(result == null) {
            if(findCell(this, "asText") != context.runtime.nul) {
                return as(Interpreter.send(context.runtime.asText, context, this), context);
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
            if(findCell(this, "asSymbol") != context.runtime.nul) {
                return as(Interpreter.send(context.runtime.asSymbol, context, this), context);
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

    public String toString() {
        return data.toString(this);
    }

    @Override
    public boolean equals(Object other) {
        try {
            return isEqualTo(other);
        } catch(Exception e) {
            return false;
        } catch(ControlFlow e) {
            return false;
        }
    }

    @Override
    public int hashCode() {
        return iokeHashCode();
    }

    public static boolean equals(Object lhs, Object rhs) throws ControlFlow {
        return ((IokeObject)lhs).isEqualTo(rhs);
    }

    public boolean isEqualTo(Object other) throws ControlFlow {
        return data.isEqualTo(this, other);
    }

    public int iokeHashCode() {
        try {
            return data.hashCode(this);
        } catch(Exception e) {
            return -1;
        } catch(ControlFlow e) {
            return 0;
        }
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

    public int getPositionEnd() throws ControlFlow {
        return data.getPositionEnd(this);
    }

    // TypeChecker
    public Object convertToMimic(Object on, IokeObject message, IokeObject context, boolean signal) throws ControlFlow {
        return convertToThis(on, signal, message, context);
    }
}// IokeObject
