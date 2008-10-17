/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.exceptions.IokeException;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Main {
    private final static String HELP = 
        "Usage: ioke [switches] -- [programfile] [arguments]\n" +
        " -Cdirectory     execute with directory as CWD\n" +
        " -d              debug, set debug flag\n" +
        " -h              help, this message\n" +
        " --copyright     print the copyright\n" +
        " --version       print current version\n";


    public static void main(String[] args) throws Throwable {
        boolean debug = false;
        String cwd = null;
        try {
            int start = 0;
            boolean done = false;

            for(;!done && start<args.length;start++) {
                String arg = args[start];
                if(arg.charAt(0) != '-') {
                    done = true;
                    break;
                } else {
                    if(arg.equals("--")) {
                        done = true;
                    } else if(arg.equals("-d")) {
                        debug = true;
                    } else if(arg.equals("-h")) {
                        System.err.print(HELP);
                        return;
                    } else if(arg.charAt(1) == 'C') {
                        if(arg.length() == 2) {
                            cwd = args[++start];
                        } else {
                            cwd = arg.substring(2);
                        }
                    } else {
                        throw new RuntimeException("Don't understand option: " + arg);
                    }
                }
            }

            Runtime r = new Runtime();
            r.init();
            if(cwd != null) {
                r.setCurrentWorkingDirectory(cwd);
            }
            ((IokeSystem)r.system.data).setCurrentProgram(args[start]);
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
