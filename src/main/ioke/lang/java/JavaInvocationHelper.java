/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.java;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class JavaInvocationHelper {
    public static boolean hasProxyMethod(IokeJavaIntegrated object, String name) {
        System.err.println("hasProxyMethod? " + name);
        return true;
    }

    public static void voidInvocation(IokeJavaIntegrated object, Object[] args, String name) {
    }

    public static byte byteInvocation(IokeJavaIntegrated object, Object[] args, String name) {
        return 0;
    }

    public static int intInvocation(IokeJavaIntegrated object, Object[] args, String name) {
        return 0;
    }

    public static short shortInvocation(IokeJavaIntegrated object, Object[] args, String name) {
        return 0;
    }

    public static char charInvocation(IokeJavaIntegrated object, Object[] args, String name) {
        return 0;
    }

    public static boolean booleanInvocation(IokeJavaIntegrated object, Object[] args, String name) {
        return false;
    }

    public static long longInvocation(IokeJavaIntegrated object, Object[] args, String name) {
        return 0;
    }

    public static float floatInvocation(IokeJavaIntegrated object, Object[] args, String name) {
        return 0.0F;
    }

    public static double doubleInvocation(IokeJavaIntegrated object, Object[] args, String name) {
        return 0.0;
    }

    public static Object objectInvocation(IokeJavaIntegrated object, Object[] args, String name) {
        System.err.println("calling " + name + " as object");
        return null;
    }
}// JavaInvocationHelper
