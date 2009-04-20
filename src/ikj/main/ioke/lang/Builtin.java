/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public abstract class Builtin {
    public abstract Object load(Runtime runtime, IokeObject context, IokeObject message) throws ControlFlow;
}// Builtin
