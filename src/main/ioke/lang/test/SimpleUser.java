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
}// SimpleUser
