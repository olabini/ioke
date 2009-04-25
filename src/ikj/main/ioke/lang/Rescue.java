/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Rescue {
    public static void init(IokeObject obj) throws ControlFlow {
        Runtime runtime = obj.runtime;
        obj.setKind("Rescue");
    }
}// Rescue
