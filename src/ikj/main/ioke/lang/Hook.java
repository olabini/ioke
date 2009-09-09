/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Hook  {
    public static void init(final Runtime runtime) throws ControlFlow {
        IokeObject obj = new IokeObject(runtime, "A hook allow you to observe what happens to a specific object. All hooks have Hook in their mimic chain.");
        obj.setKind("Hook");
        obj.mimicsWithoutCheck(runtime.origin);
        runtime.iokeGround.registerCell("Hook", obj);
    }
}// Hook
