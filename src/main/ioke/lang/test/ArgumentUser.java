/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.test;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class ArgumentUser {
    public static Object useVoidInterface(ArgumentVoidInterface si) {
        si.doSomething("max");
        return si.getData();
    }

    public static String useVoidClass(ArgumentVoidClass si) {
        si.doTheThing("max");
        return si.getData();
    }

    public static Object useDoubleVoidInterface(DoubleArgumentVoidInterface si) {
        si.doSomething("max");
        return si.getData();
    }

    public static Object useDoubleVoidInterface2(DoubleArgumentVoidInterface si) {
        si.doSomething("max", "blex");
        return si.getData();
    }
}// ArgumentUser
