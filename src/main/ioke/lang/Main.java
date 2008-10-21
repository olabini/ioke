/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.io.InputStreamReader;
import java.io.StringReader;

import java.util.List;
import java.util.ArrayList;

import ioke.lang.exceptions.ControlFlow;
import ioke.lang.exceptions.IokeException;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Main {
    private final static String HELP = 
        "Usage: ioke [switches] -- [programfile] [arguments]\n" +
        " -Cdirectory     execute with directory as CWD\n" +
        " -d              debug, set debug flag\n" +
        " -e script       execute the script. if provided, no program file is necessary.\n" +
        "                 there can be many of these provided on the same command line.\n" +
        " -h, --help      help, this message\n" +
        " --copyright     print the copyright\n" +
        " --version       print current version\n";


    public static void main(String[] args) throws Throwable {
        boolean debug = false;
        String cwd = null;
        List<String> scripts = new ArrayList<String>();
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
                    } else if(arg.equals("-e")) {
                        if(arg.length() == 2) {
                            scripts.add(args[++start]);
                        } else {
                            scripts.add(arg.substring(2));
                        }
                    } else if(arg.equals("-h") || arg.equals("--help")) {
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

            ((IokeSystem)r.system.data).setCurrentProgram("-e");

            for(String script : scripts) {
                r.evaluateStream("-e", new StringReader(script));
            }

            if(args.length > start) { 
                ((IokeSystem)r.system.data).setCurrentProgram(args[start]);
                r.evaluateFile(args[start]);
            } else {
                if(scripts.size() == 0) {
                    ((IokeSystem)r.system.data).setCurrentProgram("<stdin>");
                    r.evaluateStream("<stdin>", new InputStreamReader(System.in));
                }
            }
        } catch(ControlFlow e) {
            String name = e.getClass().getName();
            System.err.println("unexpected control flow: " + name.substring(name.indexOf("$") + 1).toLowerCase());
            if(debug) {
                e.printStackTrace(System.err);
            }
            System.exit(1);
        } catch(IokeException e) {
            e.reportError(System.err);
            if(debug) {
                e.printStackTrace(System.err);
            }
            System.exit(1);
        }
    }
}// Main
