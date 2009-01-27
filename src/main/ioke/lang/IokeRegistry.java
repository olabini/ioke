/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.List;
import java.util.Map;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class IokeRegistry {
    public static IokeObject wrap(Object on, IokeObject context) {
        System.err.println("Weeeeeeh. Wrap.");
        return context.runtime.nil;
    }
}
