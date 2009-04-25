/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.test;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class ArgumentVoidClass {
    private String data;
    public void doTheThing(String s) {
        data = s + "foo";
    }
    public String getData() {
        return data;
    }
}// ArgumentVoidClass
