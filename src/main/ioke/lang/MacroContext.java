/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.IdentityHashMap;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class MacroContext extends IokeObject {
    Object ground;

    public IokeObject message;
    public IokeObject surroundingContext;

    public MacroContext(Runtime runtime, Object ground, String documentation, IokeObject message, IokeObject surroundingContext) {
        super(runtime, documentation);
        this.ground = IokeObject.getRealContext(ground);
        this.message = message;
        this.surroundingContext = surroundingContext;
        
        if(runtime.macroContext != null) {
            this.mimicsWithoutCheck(runtime.macroContext);
        }

        setCell("self", getRealContext());
        setCell("@", getRealContext());
        setCell("call", runtime.newCallFrom(this, message, surroundingContext, IokeObject.as(ground)));
    }
    
    @Override
    public void init() {
        setKind("MacroContext");
    }

    @Override
    public Object getRealContext() {
        return ground;
    }

    @Override
    public Object findCell(IokeObject m, IokeObject context, String name, IdentityHashMap<IokeObject, Object> visited) {
        Object nn = super.findCell(m, context, name, visited);
        
        if(nn == runtime.nul) {
            return IokeObject.findCell(ground, m, context, name, visited);
        } else {
            return nn;
        }
    }

    @Override
    public String toString() {
        return "MacroContext:" + System.identityHashCode(this) + "<" + ground + ">";
    }
}// MacroContext
