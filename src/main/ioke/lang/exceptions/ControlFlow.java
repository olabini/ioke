/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.exceptions;

import java.util.List;

import ioke.lang.Runtime;
import ioke.lang.IokeObject;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class ControlFlow extends Throwable {
    public static class Break extends ControlFlow {
        public Break(Object value) {
            super(value);
        }
    }

    public static class Continue extends ControlFlow {
        public Continue() {
            super(null);
        }
    }

    public static class Return extends ControlFlow {
        public Return(Object value) {
            super(value);
        }
    }

    public static class Restart extends ControlFlow {
        private List<Object> arguments;
        public Restart(Runtime.RestartInfo value, List<Object> arguments) {
            super(value);
            this.arguments = arguments;
        }

        public Runtime.RestartInfo getRestart() {
            return (Runtime.RestartInfo)getValue();
        }

        public List<Object> getArguments() {
            return this.arguments;
        }
    }

    private Object value;

    public ControlFlow(Object value) {
        this.value = value;
    }

    public Object getValue() {
        return value;
    }

    @Override
    public Throwable fillInStackTrace() {
        // we don't need any stack trace
        return this;
    }
}// ControlFlow
