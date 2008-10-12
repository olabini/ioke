/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.exceptions;

import ioke.lang.IokeObject;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class ObjectIsNotRightType extends IokeException {
    public ObjectIsNotRightType(IokeObject from, String type) {
        super("Object " + from + " can not be converted to: " + type);
    }
}// ObjectIsNotRightType
