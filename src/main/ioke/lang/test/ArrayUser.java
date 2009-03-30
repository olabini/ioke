/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.test;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class ArrayUser {
    public static byte byteUse(byte[] arr, int index) {
        return arr[index];
    }

    public static short shortUse(short[] arr, int index) {
        return arr[index];
    }

    public static char charUse(char[] arr, int index) {
        return arr[index];
    }

    public static int intUse(int[] arr, int index) {
        return arr[index];
    }

    public static long longUse(long[] arr, int index) {
        return arr[index];
    }

    public static float floatUse(float[] arr, int index) {
        return arr[index];
    }

    public static double doubleUse(double[] arr, int index) {
        return arr[index];
    }

    public static boolean booleanUse(boolean[] arr, int index) {
        return arr[index];
    }

    public static Object objectUse(Object[] arr, int index) {
        return arr[index];
    }

    public static Object objectArrUse(Object[][] arr, int index) {
        return arr[index];
    }

    public static String use(byte[] arr, int index) {
        return "byte[]";
    }

    public static String use(short[] arr, int index) {
        return "short[]";
    }

    public static String use(char[] arr, int index) {
        return "char[]";
    }

    public static String use(int[] arr, int index) {
        return "int[]";
    }

    public static String use(long[] arr, int index) {
        return "long[]";
    }

    public static String use(float[] arr, int index) {
        return "float[]";
    }

    public static String use(double[] arr, int index) {
        return "double[]";
    }

    public static String use(boolean[] arr, int index) {
        return "boolean[]";
    }

    public static String use(Object[] arr, int index) {
        return "Object[]";
    }

    public static String use(Object[][] arr, int index) {
        return "Object[][]";
    }
}// ArrayUser
