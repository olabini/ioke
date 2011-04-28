/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.io.Reader;
import java.io.StringReader;

import java.util.Arrays;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;

import ioke.lang.parser.IokeParser;

import ioke.lang.exceptions.ControlFlow;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class UseValueRestart extends Restart.ArgumentGivingRestart {
    private final String name;
    private final Object[] newCell;
    
    public UseValueRestart(String name, Object[] newCell) {
        super("useValue");
        this.name = name;
        this.newCell = newCell;
    }

    public String report() {
        return "Use value for: " + name;
    }

    public List<String> getArgumentNames() {
        return new ArrayList<String>(Arrays.asList("newValue"));
    }

    public IokeObject invoke(IokeObject context, List<Object> arguments) throws ControlFlow {
        newCell[0] = arguments.get(0);
        return context.runtime.nil;
    }
}

