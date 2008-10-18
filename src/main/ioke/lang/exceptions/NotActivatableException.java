/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.exceptions;

import ioke.lang.Message;
import ioke.lang.IokeObject;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class NotActivatableException extends IokeException {
    public NotActivatableException(IokeObject m, IokeObject on, IokeObject context) {
        super(m, on, context);
    }

    public NotActivatableException(IokeObject m, String message, IokeObject on, IokeObject context) {
        super(m, message, on, context);
    }

    public NotActivatableException(IokeObject m, Throwable cause, IokeObject on, IokeObject context) {
        super(m, cause, on, context);
    }

    public NotActivatableException(IokeObject m, String message, Throwable cause, IokeObject on, IokeObject context) {
        super(m, message, cause, on, context);
    }
}// NotActivatableException
