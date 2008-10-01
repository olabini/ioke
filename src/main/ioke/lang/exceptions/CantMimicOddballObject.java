/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.exceptions;

import ioke.lang.IokeObject;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class CantMimicOddballObject extends IokeException {
    public CantMimicOddballObject(IokeObject oddball) {
        super("Can't mimic on oddball object: " + oddball);
    }
}// CantMimicOddballObject
