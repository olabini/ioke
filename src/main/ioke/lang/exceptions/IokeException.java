/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.exceptions;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class IokeException extends RuntimeException {
    public IokeException() {
        super();
    }

    public IokeException(String message) {
        super(message);
    }

    public IokeException(Throwable cause) {
        super(cause);
    }

    public IokeException(String message, Throwable cause) {
        super(message, cause);
    }
}// IokeException
