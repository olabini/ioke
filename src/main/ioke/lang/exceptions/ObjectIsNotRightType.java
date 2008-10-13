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
public class ObjectIsNotRightType extends IokeException {
    public ObjectIsNotRightType(Message m, IokeObject from, String type, IokeObject context) {
        super(m, "Object " + from + " can not be converted to: " + type, from, context);
    }
}// ObjectIsNotRightType
