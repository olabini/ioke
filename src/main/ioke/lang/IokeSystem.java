/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class IokeSystem extends IokeObject {
    IokeSystem(Runtime runtime, String documentation) {
        super(runtime, documentation);
    }

    public void init() {
    }

    public String toString() {
        return "System";
    }
}// IokeSystem
