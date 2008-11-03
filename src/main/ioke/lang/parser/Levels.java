/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.parser;

import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.ArrayList;

import ioke.lang.IokeObject;
import ioke.lang.Message;
import ioke.lang.Runtime;
import ioke.lang.Dict;

/**
 * Based on Levels from Io IoMessage_opShuffle.c
 * 
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Levels {
    public final static int OP_LEVEL_MAX = 32;
    private Runtime runtime;

    private Map<Object, Object> operatorTable;
    private Map<Object, Object> assignOperatorTable;

    public static class Level {
        IokeObject message;
        public static enum Type {Attach, Arg, New, Unused};
        Type type;
        int precedence;
        public Level(Type type) { this.type = type; }
    }

    private List<Level> stack;

    private IokeObject _message;
    private IokeObject _context;

    private int currentLevel;
    private Level[] pool = new Level[OP_LEVEL_MAX];

    public static class OpTable {
        public String name;
        public int precedence;
        public OpTable(String name, int precedence) { this.name = name; this.precedence = precedence; }
    }

    public static OpTable[] defaultOperators = new OpTable[]{
		new OpTable("@",   0),
		new OpTable("@@",  0),
		new OpTable("!",   0),
		new OpTable("'",   0),
		new OpTable("$",   0),
		new OpTable("~",   0),
		new OpTable("#",   0),

		new OpTable("++",   0),
		new OpTable("--",   0),

		new OpTable("**",  1),

		new OpTable("*",   2),
		new OpTable("/",   2),
		new OpTable("%",   2),

		new OpTable("+",   3),
		new OpTable("-",   3),

		new OpTable("<<",  4),
		new OpTable(">>",  4),

		new OpTable("<=>",  5),
		new OpTable(">",   5),
		new OpTable("<",   5),
		new OpTable("<=",  5),
		new OpTable(">=",  5),

		new OpTable("==",  6),
		new OpTable("!=",  6),
		new OpTable("===",  6),

		new OpTable("&",   7),

		new OpTable("^",   8),

		new OpTable("|",   9),

		new OpTable("&&",  10),

		new OpTable("||",  11),

		new OpTable("..",  12),
		new OpTable("...",  12),
		new OpTable("=>",  12),
		new OpTable("<->",  12),
		new OpTable("->",  12),
		new OpTable("<-",  12),

		new OpTable("+=",  13),
		new OpTable("-=",  13),
		new OpTable("*=",  13),
		new OpTable("/=",  13),
		new OpTable("%=",  13),
		new OpTable("and",  13),
		new OpTable("&=",  13),
		new OpTable("&&=",  13),
		new OpTable("^=",  13),
		new OpTable("or",  13),
		new OpTable("|=",  13),
		new OpTable("||=",  13),
		new OpTable("<<=", 13),
		new OpTable(">>=", 13),

		new OpTable("return", 14)
    };
    
    public static interface OpTableCreator {
        Map<Object, Object> create(Runtime runtime);
    }

    public Levels(IokeObject msg, IokeObject context, IokeObject message) {
        this.runtime = context.runtime;
        this._context = context;
        this._message = message;

        IokeObject opTable = IokeObject.as(msg.findCell(_message, _context, "OperatorTable"));
        if(opTable == runtime.nul) {
            opTable = runtime.newFromOrigin();
            runtime.message.setCell("OperatorTable", opTable);
            opTable.setCell("precedenceLevelCount", runtime.newNumber(OP_LEVEL_MAX));
        }
        this.operatorTable = getOpTable(opTable, "operators", new OpTableCreator() {
                public Map<Object, Object> create(Runtime runtime) {
                    Map<Object, Object> table = new HashMap<Object, Object>();
                    for(OpTable ot : defaultOperators) {
                        table.put(runtime.getSymbol(ot.name), runtime.newNumber(ot.precedence));
                    }
                    return table;
                }
            });
        this.assignOperatorTable = getOpTable(opTable, "assignOperators", new OpTableCreator() {
                public Map<Object, Object> create(Runtime runtime) {
                    Map<Object, Object> table = new HashMap<Object, Object>();
                    table.put(runtime.getSymbol("="), runtime.getSymbol("="));
                    return table;
                }
            });
        this.stack = new ArrayList<Level>();
        this.reset();
    }

    public Map<Object, Object> getOpTable(IokeObject opTable, String name, OpTableCreator creator) {
        IokeObject operators = IokeObject.as(opTable.findCell(_message, _context, name));
        if(operators != runtime.nul && (IokeObject.data(operators) instanceof Dict)) {
            return Dict.getMap(operators);
        } else {
            Map<Object, Object> result = creator.create(runtime);
            opTable.setCell(name, runtime.newDict(result));
            return result;
        }
    }

    public void attach(IokeObject msg, List<IokeObject> expressions) {
        String messageName = Message.name(msg);
        IokeObject messageSymbol = runtime.getSymbol(messageName);
        int precedence = levelForOp(messageName, messageSymbol, msg);
        
        int msgArgCount = msg.getArgumentCount();
        
        /*
        // o a = b c . d  becomes  o =(a, b c) . d
        //
        // a      attaching
        // =      msg
        // b c    Message.next(msg)
        */
        if(isAssignOperator(messageSymbol)) {
            Level currentLevel = currentLevel();
            IokeObject attaching = currentLevel.message;
            IokeObject setCellName;
            if(attaching == null && msgArgCount == 0) { // = b .    and not    =(foo, b) .
                // TODO: error here, since = requires a symbol to its left
            }
            if(msgArgCount > 0) {  // x =(foo, 2)
                // TODO: no shuffling needed, arguments already provided to this message
            }





		{
			// a := b ;
			IoSymbol *slotName = DATA(attaching)->name;
			IoSymbol *quotedSlotName = IoSeq_newSymbolWithFormat_(state, "\"%s\"", CSTRING(slotName));
			IoMessage *slotNameMessage = IoMessage_newWithName_returnsValue_(state, quotedSlotName, slotName);

			IoMessage_rawCopySourceLocation(slotNameMessage, attaching);

			// a := b ;  ->  a("a") := b ;
			IoMessage_addArg_(attaching, slotNameMessage);

			setSlotName = Levels_nameForAssignOperator(self, state, messageSymbol, slotName, msg);
		}

		// a("a") := b ;  ->  setSlot("a") := b ;
		DATA(attaching)->name = IoObject_addingRef_(attaching, setSlotName);

		currentLevel->type = ATTACH;



            
            
        } else if(Message.isTerminator(msg)) {
            popDownTo(OP_MAX_LEVEL-1);
            attachAndReplace(currentLevel(), msg);
        } else if(precedence != -1) { // An operator
            
        } else {
            attachAndReplace(currentLevel(), msg);
        }
    }

    public void nextMessage() {
        
    }

    public void reset() {
        currentLevel = 1;
        for(int i=0;i<OP_LEVEL_MAX;i++) {
            pool[i] = new Level(Level.Type.Unused);
        }
        Level level = pool[0];
        level.message = null;
        level.type = Level.Type.New;
        level.precedence = OP_LEVEL_MAX;

        stack.clear();
        stack.add(pool[0]);
    }
}// Levels
