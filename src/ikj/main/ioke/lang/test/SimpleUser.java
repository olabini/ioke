/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.test;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class SimpleUser {
    public static boolean useBooleanObject(SimpleBooleanClass si) {
        return si.doTheThing();
    }

    public static boolean useBooleanInterface(SimpleBooleanInterface si) {
        return si.doSomething();
    }

    public static int useIntObject(SimpleIntClass si) {
        return si.doTheThing();
    }

    public static int useIntInterface(SimpleIntInterface si) {
        return si.doSomething();
    }

    public static short useShortObject(SimpleShortClass si) {
        return si.doTheThing();
    }

    public static short useShortInterface(SimpleShortInterface si) {
        return si.doSomething();
    }

    public static char useCharObject(SimpleCharClass si) {
        return si.doTheThing();
    }

    public static char useCharInterface(SimpleCharInterface si) {
        return si.doSomething();
    }

    public static byte useByteObject(SimpleByteClass si) {
        return si.doTheThing();
    }

    public static byte useByteInterface(SimpleByteInterface si) {
        return si.doSomething();
    }

    public static long useLongObject(SimpleLongClass si) {
        return si.doTheThing();
    }

    public static long useLongInterface(SimpleLongInterface si) {
        return si.doSomething();
    }

    public static float useFloatObject(SimpleFloatClass si) {
        return si.doTheThing();
    }

    public static float useFloatInterface(SimpleFloatInterface si) {
        return si.doSomething();
    }

    public static double useDoubleObject(SimpleDoubleClass si) {
        return si.doTheThing();
    }

    public static double useDoubleInterface(SimpleDoubleInterface si) {
        return si.doSomething();
    }

    public static String useVoidObject(SimpleVoidClass si) {
        si.doTheThing();
        return si.getData();
    }

    public static String useVoidInterface(SimpleVoidInterface si) {
        si.doSomething();
        return si.getData();
    }
}// SimpleUser
