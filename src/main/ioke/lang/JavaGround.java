/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class JavaGround {
    public static void init(IokeObject javaGround) throws ControlFlow {
        Runtime runtime = javaGround.runtime;
        javaGround.setKind("JavaGround");
    }
}
