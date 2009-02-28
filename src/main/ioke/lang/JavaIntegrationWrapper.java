/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class JavaIntegrationWrapper {
    public static JavaWrapper wrapWithMethods(Class<?> clz, IokeObject obj, Runtime runtime) {
        return JavaWrapper.wrapWithMethods(clz, obj, runtime, true);
    }    
}// JavaIntegrationWrapper
