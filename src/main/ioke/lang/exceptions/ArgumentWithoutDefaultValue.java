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
public class ArgumentWithoutDefaultValue extends IokeException {
    public ArgumentWithoutDefaultValue(IokeObject m, int index, Object on, IokeObject context) {
        super(m, m.getName() + " got an argument without default value following at least one optional value at " + index, on, context);
    }
}// ArgumentWithoutDefaultValue
