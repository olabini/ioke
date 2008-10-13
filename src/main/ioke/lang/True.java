/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.exceptions.CantMimicOddballObject;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class True extends IokeObject {
    True(Runtime runtime, String documentation) {
        super(runtime, documentation);
    }

    public void init() {
        
    }

    IokeObject allocateCopy(Message m, IokeObject context) {
        throw new CantMimicOddballObject(m, this, context);
    }

    public String toString() {
        return "true";
    }
}// True
