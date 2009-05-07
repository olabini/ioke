/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.mixins;

import ioke.lang.Runtime;
import ioke.lang.IokeObject;
import ioke.lang.NativeMethod;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Enumerable {
    public static void init(IokeObject enumerable) {
        Runtime runtime = enumerable.runtime;
        enumerable.setKind("Mixins Enumerable");
    }
}// Enumerable
