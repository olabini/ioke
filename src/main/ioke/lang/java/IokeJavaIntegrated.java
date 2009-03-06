/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.java;

import ioke.lang.IokeObject;
import ioke.lang.Runtime;

/**
 * Marker interface
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public interface IokeJavaIntegrated {
    public IokeObject __get_IokeProxy();
    public Runtime    __get_IokeRuntime();
}// IokeJavaIntegrated
