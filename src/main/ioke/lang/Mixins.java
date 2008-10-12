/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.mixins.Comparing;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Mixins extends IokeObject {
    Comparing comparing;
    
    public Mixins(Runtime runtime, String documentation) {
        super(runtime, documentation);
    }

    public void init() {
        comparing = new Comparing(runtime, "allows different objects to be compared, based on the spaceship operator being available");
        // comparing.mimics(base); // Comparing doesn't mimic anything, just like default behavior
        comparing.init();
        registerCell("Comparing", comparing);
    }

    public String toString() {
        return "Mixins";
    }
}// Mixins
