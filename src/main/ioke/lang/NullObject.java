/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class NullObject extends IokeObject {
    public NullObject(Runtime runtime) {
        super(runtime);
    }

    public boolean isActivatable() {
        return false;
    }

}// NullObject
