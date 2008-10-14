/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.exceptions;

import ioke.lang.IokeObject;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class ControlFlow extends Throwable {
    public static class Break extends ControlFlow {
        public Break(IokeObject value) {
            super(value);
        }
    }

    private IokeObject value;

    public ControlFlow(IokeObject value) {
        this.value = value;
    }

    public IokeObject getValue() {
        return value;
    }

    @Override
    public Throwable fillInStackTrace() {
        // we don't need any stack trace
        return this;
    }
}// ControlFlow
