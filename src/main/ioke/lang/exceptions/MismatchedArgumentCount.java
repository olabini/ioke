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
public class MismatchedArgumentCount extends IokeException {
    public MismatchedArgumentCount(IokeObject m, String expected, int received, Object on, IokeObject context) {
        super(m, m + " expected " + expected + " arguments, but got " + received, on, context);
    }
}// MismatchedArgumentCount
