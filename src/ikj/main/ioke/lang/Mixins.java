/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.mixins.Comparing;
import ioke.lang.mixins.Enumerable;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Mixins {
    public static void init(IokeObject mixins) throws ControlFlow {
        mixins.setKind("Mixins");

        mixins.setCell("=",         mixins.runtime.base.getCells().get("="));
        mixins.setCell("==",        mixins.runtime.base.getCells().get("=="));
        mixins.setCell("cell",      mixins.runtime.base.getCells().get("cell"));
        mixins.setCell("cell=",     mixins.runtime.base.getCells().get("cell="));
        mixins.setCell("cell?",     mixins.runtime.base.getCells().get("cell?"));
        mixins.setCell("cells",     mixins.runtime.base.getCells().get("cells"));
        mixins.setCell("cellNames", mixins.runtime.base.getCells().get("cellNames"));
        mixins.setCell("mimic",     mixins.runtime.base.getCells().get("mimic"));

        IokeObject comparing = new IokeObject(mixins.runtime, "allows different objects to be compared, based on the spaceship operator being available");
        comparing.mimicsWithoutCheck(mixins);
        Comparing.init(comparing);
        mixins.registerCell("Comparing", comparing);

        IokeObject enumerable = new IokeObject(mixins.runtime, "adds lots of helpful methods that can be done on enumerable methods. based on the 'each' method being available on the self.");
        enumerable.mimicsWithoutCheck(mixins);
        Enumerable.init(enumerable);
        mixins.registerCell("Enumerable", enumerable);
    }
}// Mixins
