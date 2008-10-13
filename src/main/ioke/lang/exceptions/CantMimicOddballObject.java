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
public class CantMimicOddballObject extends IokeException {
    public CantMimicOddballObject(Message m, IokeObject oddball) {
        super(m, "Can't mimic on oddball object: " + oddball, oddball);
    }
}// CantMimicOddballObject
