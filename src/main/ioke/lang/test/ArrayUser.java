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

    public static String stringUse(String[] arr, int index) {
        return arr[index];
    }

    public static java.util.Map mapUse(java.util.Map[] arr, int index) {
        return arr[index];
    }

    public static Object objectUse(Object[] arr, int index) {
        return arr[index];
    }

    public static Object objectArrUse(Object[][] arr, int index) {
        return arr[index];
    }

    public static String use(byte[] arr) {
        return "byte[]";
    }

    public static String use(short[] arr) {
        return "short[]";
    }

    public static String use(char[] arr) {
        return "char[]";
    }

    public static String use(int[] arr) {
        return "int[]";
    }

    public static String use(long[] arr) {
        return "long[]";
    }

    public static String use(float[] arr) {
        return "float[]";
    }

    public static String use(double[] arr) {
        return "double[]";
    }

    public static String use(boolean[] arr) {
        return "boolean[]";
    }

    public static String use(Object[] arr) {
        return "Object[]";
    }

    public static String use(String[] arr) {
        return "String[]";
    }

    public static String use(java.util.Map[] arr) {
        return "Map[]";
    }

    public static String use(Object[][] arr) {
        return "Object[][]";
    }
}// ArrayUser
