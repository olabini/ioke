/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.test;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class SimpleInterfaceUser {
    public static String useObject(SimpleInterface si) {
        try {
            String s = si.doSomething();
            System.err.println("no exception...");
            return s;
        } catch(Throwable e) {
            System.err.println(e);
            throw new RuntimeException(e);
        }
    }
}// SimpleInterfaceUser
