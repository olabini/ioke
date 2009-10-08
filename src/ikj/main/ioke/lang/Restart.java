/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.ArrayList;
import java.util.List;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Restart {
    public static void init(IokeObject restart) throws ControlFlow {
        Runtime runtime = restart.runtime;
        restart.setKind("Restart");

        restart.registerCell("name", runtime.nil);
        restart.registerCell("report", runtime.evaluateString("fn(r, \"restart: \" + r name)", runtime.message, runtime.ground));
        restart.registerCell("test", runtime.evaluateString("fn(c, true)", runtime.message, runtime.ground));
        restart.registerCell("code", runtime.evaluateString("fn()", runtime.message, runtime.ground));
        restart.registerCell("argumentNames", runtime.evaluateString("method(self code argumentNames)", runtime.message, runtime.ground));
    }


    public abstract static class JavaRestart {
        protected String name;
        public String getName() {
            return this.name;
        }

        public abstract List<String> getArgumentNames();

        public String report() {
            return null;
        }

        public abstract IokeObject invoke(IokeObject context, List<Object> arguments) throws ControlFlow;
    }

    public abstract static class ArgumentGivingRestart extends JavaRestart {
        public ArgumentGivingRestart(String name) {
            this.name = name;
        }

        public IokeObject invoke(IokeObject context, List<Object> arguments) throws ControlFlow {
            return context.runtime.newList(arguments);
        }
    }

    public static class DefaultValuesGivingRestart extends JavaRestart {
        private IokeObject value;
        private int repeat;
        public DefaultValuesGivingRestart(String name, IokeObject value, int repeat) {
            this.name = name;
            this.value = value;
            this.repeat = repeat;
        }

        public List<String> getArgumentNames() {
            return new ArrayList<String>();
        }

        public IokeObject invoke(IokeObject context, List<Object> arguments) throws ControlFlow {
            List<Object> result = new ArrayList<Object>();
            for(int i=0; i<repeat; i++) {
                result.add(value);
            }
            return context.runtime.newList(result);
        }
    }
}// Restart
