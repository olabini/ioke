/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.exceptions.CantMimicOddballObject;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Nil extends IokeObject {
    Nil(Runtime runtime) {
        super(runtime);
    }

    public void init() {
        
    }

    IokeObject allocateCopy() {
        throw new CantMimicOddballObject(this);
    }

    public String toString() {
        return "nil";
    }

    public boolean isNil() {
        return true;
    }
}// Nil
