/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.exceptions;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class NotActivatableException extends IokeException {
    public NotActivatableException() {
        super();
    }

    public NotActivatableException(String message) {
        super(message);
    }

    public NotActivatableException(Throwable cause) {
        super(cause);
    }

    public NotActivatableException(String message, Throwable cause) {
        super(message, cause);
    }
}// NotActivatableException
