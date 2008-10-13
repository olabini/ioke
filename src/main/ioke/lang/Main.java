/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Main {
    public static void main(String[] args) throws Exception {
        Runtime r = new Runtime();
        r.init();
        r.system.setCurrentProgram(args[0]);
        r.evaluateFile(args[0]);
    }
}// Main
