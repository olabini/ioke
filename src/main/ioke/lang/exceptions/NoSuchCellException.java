/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.exceptions;

import ioke.lang.IokeObject;
import ioke.lang.Message;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class NoSuchCellException extends IokeException {
    public NoSuchCellException(IokeObject m, String name, IokeObject on, IokeObject context) {
        super(m, "Object does not respond to '" + name + "'", on, context);
    }
}// NoSuchCellException
