/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.mixins.Comparing;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Mixins {
    public static void init(IokeObject mixins) {
        mixins.setKind("Mixins");
        IokeObject comparing = new IokeObject(mixins.runtime, "allows different objects to be compared, based on the spaceship operator being available");
        Comparing.init(comparing);
        mixins.registerCell("Comparing", comparing);
    }
}// Mixins
