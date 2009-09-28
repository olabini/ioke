/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.mixins;

import ioke.lang.Runtime;
import ioke.lang.IokeObject;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Sequenced {
    public static void init(IokeObject obj) {
        Runtime runtime = obj.runtime;
        obj.setKind("Mixins Sequenced");
    }
}// Sequenced
