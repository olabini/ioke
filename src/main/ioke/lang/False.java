/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.exceptions.CantMimicOddballObject;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class False extends IokeObject {
    False(Runtime runtime, String documentation) {
        super(runtime, documentation);
    }

    public void init() {
        
    }

    public IokeObject allocateCopy(Message m, IokeObject context) {
        throw new CantMimicOddballObject(m, this, context);
    }

    public String toString() {
        return "false";
    }

    public boolean isTrue() {
        return false;
    }
}// False
