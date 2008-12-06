/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.io.InputStreamReader;
import java.io.StringReader;

import java.util.List;
import java.util.ArrayList;

import ioke.lang.exceptions.ControlFlow;

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
        " -Idir           add directory to 'System loadPath'. May be used more than once\n" +
        " --copyright     print the copyright\n" +
        " --version       print current version\n";


    public static void main(String[] args) throws Throwable {
        Runtime r = new Runtime();
        r.init();
        final IokeObject context = r.ground;
        final Message mx = new Message(r, ".", null, Message.Type.TERMINATOR);
        mx.setLine(0);
        mx.setPosition(0);
        final IokeObject message = r.createMessage(mx);

        boolean debug = false;
        String cwd = null;
        List<String> scripts = new ArrayList<String>();
        List<String> loadDirs = new ArrayList<String>();
        try {
            int start = 0;
            boolean done = false;
            boolean readStdin = false;

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
                        r.debug = true;
                    } else if(arg.startsWith("-e")) {
                        if(arg.length() == 2) {
                            scripts.add(args[++start]);
                        } else {
                            scripts.add(arg.substring(2));
                        }
                    } else if(arg.startsWith("-I")) {
                        if(arg.length() == 2) {
                            loadDirs.add(args[++start]);
                        } else {
                            loadDirs.add(arg.substring(2));
                        }
                    } else if(arg.equals("-h") || arg.equals("--help")) {
                        System.err.print(HELP);
                        return;
                    } else if(arg.equals("-")) {
                        readStdin = true;
                    } else if(arg.charAt(1) == 'C') {
                        if(arg.length() == 2) {
                            cwd = args[++start];
                        } else {
                            cwd = arg.substring(2);
                        }
                    } else {
                        final IokeObject condition = IokeObject.as(IokeObject.getCellChain(r.condition, 
                                                                                           message, 
                                                                                           context, 
                                                                                           "Error", 
                                                                                           "CommandLine", 
                                                                                           "DontUnderstandOption")).mimic(message, context);
                        condition.setCell("message", message);
                        condition.setCell("context", context);
                        condition.setCell("receiver", context);
                        condition.setCell("option", r.newText(arg));
                        r.errorCondition(condition);
                    }
                }
            }

            if(cwd != null) {
                r.setCurrentWorkingDirectory(cwd);
            }

            ((IokeSystem)r.system.data).setCurrentProgram("-e");

            ((IokeSystem)r.system.data).addLoadPath(System.getProperty("ioke.lib", ".") + "/ioke");
            ((IokeSystem)r.system.data).addLoadPath("lib/ioke");

            for(String ss : loadDirs) {
                ((IokeSystem)r.system.data).addLoadPath(ss);
            }

            for(String script : scripts) {
                r.evaluateStream("-e", new StringReader(script), message, context);
            }
            
            if(readStdin) {
                ((IokeSystem)r.system.data).setCurrentProgram("<stdin>");
                r.evaluateStream("<stdin>", new InputStreamReader(System.in), message, context);
            }

            if(args.length > start) { 
                ((IokeSystem)r.system.data).setCurrentProgram(args[start]);
                r.evaluateFile(args[start], message, context);
            } else {
                if(scripts.size() == 0) {
                    r.evaluateString("use(\"builtin/iik\"). IIk mainLoop", message, context);
                }
            }
            r.tearDown();
        } catch(ControlFlow.Exit e) {
            try {
                r.tearDown();
            } catch(ControlFlow.Exit e2) {
            }
            System.exit(1);
        } catch(ControlFlow e) {
            String name = e.getClass().getName();
            System.err.println("unexpected control flow: " + name.substring(name.indexOf("$") + 1).toLowerCase());
            if(debug) {
                e.printStackTrace(System.err);
            }
            System.exit(1);
        }
    }
}// Main
