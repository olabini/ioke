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
    public NotActivatableException(Message m, IokeObject on) {
        super(m, on);
    }

    public NotActivatableException(Message m, String message, IokeObject on) {
        super(m, message, on);
    }

    public NotActivatableException(Message m, Throwable cause, IokeObject on) {
        super(m, cause, on);
    }

    public NotActivatableException(Message m, String message, Throwable cause, IokeObject on) {
        super(m, message, cause, on);
    }
}// NotActivatableException
