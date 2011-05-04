/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.mixins.Comparing;
import ioke.lang.mixins.Enumerable;
import ioke.lang.mixins.Sequenced;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Mixins {
    public static void init(IokeObject mixins) throws ControlFlow {
        mixins.setKind("Mixins");

        mixins.setCell("=",         mixins.runtime.base.body.get("="));
        mixins.setCell("==",        mixins.runtime.base.body.get("=="));
        mixins.setCell("cell",      mixins.runtime.base.body.get("cell"));
        mixins.setCell("cell=",     mixins.runtime.base.body.get("cell="));
        mixins.setCell("cell?",     mixins.runtime.base.body.get("cell?"));
        mixins.setCell("cells",     mixins.runtime.base.body.get("cells"));
        mixins.setCell("cellNames", mixins.runtime.base.body.get("cellNames"));
        mixins.setCell("mimic",     mixins.runtime.base.body.get("mimic"));

        IokeObject comparing = new IokeObject(mixins.runtime, "allows different objects to be compared, based on the spaceship operator being available");
        comparing.singleMimicsWithoutCheck(mixins);
        Comparing.init(comparing);
        mixins.registerCell("Comparing", comparing);

        IokeObject enumerable = new IokeObject(mixins.runtime, "adds lots of helpful methods that can be done on enumerable methods. based on the 'each' method being available on the self.");
        enumerable.singleMimicsWithoutCheck(mixins);
        Enumerable.init(enumerable);
        mixins.registerCell("Enumerable", enumerable);

        IokeObject sequenced = new IokeObject(mixins.runtime, "something that is sequenced can return a Sequence over itself. it also allows several other methods to be defined in terms of that sequence. A Sequenced object is Enumerable, since all Enumerable operations can be defined in terms of sequencing.");
        sequenced.mimicsWithoutCheck(mixins);
        sequenced.mimicsWithoutCheck(enumerable);
        Sequenced.init(sequenced);
        mixins.registerCell("Sequenced", sequenced);
    }
}// Mixins
