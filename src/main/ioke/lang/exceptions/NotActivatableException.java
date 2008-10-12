/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.exceptions;

import ioke.lang.Message;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class NotActivatableException extends IokeException {
    public NotActivatableException(Message m) {
        super(m);
    }

    public NotActivatableException(Message m, String message) {
        super(m, message);
    }

    public NotActivatableException(Message m, Throwable cause) {
        super(m, cause);
    }

    public NotActivatableException(Message m, String message, Throwable cause) {
        super(m, message, cause);
    }
}// NotActivatableException
