/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.exceptions.IokeException;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Main {
    public static void main(String[] args) throws Exception {
        boolean debug = false;
        try {
            int start = 0;
            if(args[start].equals("-d") || args[start].equals("--debug")) {
                debug = true;
                start++;
            }
            Runtime r = new Runtime();
            r.init();
            r.system.setCurrentProgram(args[start]);
            r.evaluateFile(args[start]);
        } catch(IokeException e) {
            e.reportError(System.err);
            if(debug) {
                e.printStackTrace(System.err);
            }
            System.exit(1);
        }
    }
}// Main
