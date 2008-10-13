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
    public MismatchedArgumentCount(Message m, int expected, int received, IokeObject on) {
        super(m, m.getName() + " expected " + expected + " arguments, but got " + received, on);
    }
}// MismatchedArgumentCount
