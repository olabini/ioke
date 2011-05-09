/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.io.InputStreamReader;
import java.io.StringReader;

import java.util.List;
import java.util.ArrayList;
import java.util.Properties;

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
        " -c, --coverage  collects coverage information and gives that to IKover after program run.\n" +
        "                 there can be many of these provided on the same command line.\n" +
        " -h, --help      help, this message\n" +
        " -Idir           add directory to 'System loadPath'. May be used more than once\n" +
        " --copyright     print the copyright\n" +
        " --version       print current version\n";


    public static void main(String[] args) throws Throwable {
        boolean debug = false;
        String cwd = null;
        boolean coverage = false;
        String argError = null;
        List<String> scripts = new ArrayList<String>();
        List<String> loadDirs = new ArrayList<String>();
        int start = 0;
        boolean done = false;
        boolean readStdin = false;
        boolean printedSomething = false;

        for(;!done && start<args.length;start++) {
            String arg = args[start];
            if(arg.length() > 0) {
                if(arg.charAt(0) != '-') {
                    done = true;
                    break;
                } else {
                    if(arg.equals("--")) {
                        done = true;
                    } else if(arg.equals("-d")) {
                        debug = true;
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
                    } else if(arg.equals("-c") || arg.equals("--coverage")) {
                        coverage = true;
                    } else if(arg.equals("--version")) {
                        System.err.println(getVersion());
                        printedSomething = true;
                    } else if(arg.equals("--copyright")) {
                        System.err.print(COPYRIGHT);
                        printedSomething = true;
                    } else if(arg.equals("-")) {
                        readStdin = true;
                    } else if(arg.charAt(1) == 'C') {
                        if(arg.length() == 2) {
                            cwd = args[++start];
                        } else {
                            cwd = arg.substring(2);
                        }
                    } else {
                        argError = arg;
                    }
                }
            }
        }

        CoverageInterpreter citer = null;
        Interpreter iter = null;
        if(coverage) {
            citer = new CoverageInterpreter();
            iter = citer;
        } else {
            iter = new Interpreter();
        }
        Runtime r = new Runtime(iter);
        try {
            r.init();
            final IokeObject context = r.ground;
            final Message mx = new Message(r, ".", null, true);
            mx.setLine(0);
            mx.setPosition(0);
            mx.setPositionEnd(0);
            final IokeObject message = r.createMessage(mx);
            
            if(debug) {
                r.debug = true;
            }

            if(argError != null) {
                final IokeObject condition = IokeObject.as(IokeObject.getCellChain(r.condition,
                                                                                   message,
                                                                                   context,
                                                                                   "Error",
                                                                                   "CommandLine",
                                                                                   "DontUnderstandOption"), null).mimic(message, context);
                condition.setCell("message", message);
                condition.setCell("context", context);
                condition.setCell("receiver", context);
                condition.setCell("option", r.newText(argError));
                r.errorCondition(condition);
            }

            if(cwd != null) {
                r.setCurrentWorkingDirectory(cwd);
            }

            ((IokeSystem)IokeObject.data(r.system)).setCurrentProgram("-e");

            ((IokeSystem)IokeObject.data(r.system)).addLoadPath(System.getProperty("ioke.lib", ".") + "/ioke");
            ((IokeSystem)IokeObject.data(r.system)).addLoadPath("lib/ioke");

            for(String ss : loadDirs) {
                ((IokeSystem)IokeObject.data(r.system)).addLoadPath(ss);
            }

            for(String script : scripts) {
                r.evaluateStream("-e", new StringReader(script), message, context);
            }

            if(readStdin) {
                ((IokeSystem)IokeObject.data(r.system)).setCurrentProgram("<stdin>");
                r.evaluateStream("<stdin>", new InputStreamReader(System.in, "UTF-8"), message, context);
            }

            if(args.length > start) {
                if(args.length > (start+1)) {
                    for(int i=start+1,j=args.length; i<j; i++) {
                        r.addArgument(args[i]);
                    }
                }
                String file = args[start];
                if(file.startsWith("\"")) {
                    file = file.substring(1, file.length());
                }

                if(file.length() > 1 && file.charAt(file.length()-1) == '"') {
                    file = file.substring(0, file.length()-1);
                }

                ((IokeSystem)IokeObject.data(r.system)).setCurrentProgram(file);
                r.evaluateFile(file, message, context);
            } else {
                if(!readStdin && scripts.size() == 0 && !printedSomething) {
                    r.evaluateString("use(\"builtin/iik\"). IIk mainLoop", message, context);
                }
            }

            if(coverage) {
                citer.stopCovering();
                r.evaluateString("use(\"ikover\")", r.message, r.ground);
                IokeObject ikover = (IokeObject)Interpreter.send(r.newMessage("IKover"), r.ground, r.ground);
                IokeObject iokeCoverageData = citer.iokefiedCoverageData(r);
                Interpreter.send(r.newMessage("addCoverageData"), r.ground, ikover, iokeCoverageData);
                Interpreter.send(r.newMessage("processCoverage"), r.ground, ikover);
            }

            r.tearDown();
        } catch(ControlFlow.Exit e) {
            int exitVal = e.getExitValue();
            try {
                if(coverage) {
                    citer.stopCovering();
                    r.evaluateString("use(\"ikover\")", r.message, r.ground);
                    IokeObject ikover = (IokeObject)Interpreter.send(r.newMessage("IKover"), r.ground, r.ground);
                    IokeObject iokeCoverageData = citer.iokefiedCoverageData(r);
                    Interpreter.send(r.newMessage("addCoverageData"), r.ground, ikover, iokeCoverageData);
                    Interpreter.send(r.newMessage("processCoverage"), r.ground, ikover);
                }

                r.tearDown();
            } catch(ControlFlow.Exit e2) {
                exitVal = e2.getExitValue();
            }
            System.exit(exitVal);
        } catch(ControlFlow e) {
            String name = e.getClass().getName();
            System.err.println("unexpected control flow: " + name.substring(name.indexOf("$") + 1).toLowerCase());
            if(debug) {
                e.printStackTrace(System.err);
            }
            System.exit(1);
        }
    }

    public static String getVersion() {
        try {
            Properties props = new Properties();
            props.load(Main.class.getResourceAsStream("/ioke/lang/version.properties"));

            String version = props.getProperty("ioke.build.versionString");
            String date = props.getProperty("ioke.build.date");
            String commit = props.getProperty("ioke.build.commit");

            return version + " [" + date + " -- " + commit + "]";
        } catch(Exception e) {
        }

        return "";
    }

    private final static String COPYRIGHT =
        "Copyright (c) 2008 Ola Bini, ola.bini@gmail.com\n"+
        "\n"+
        "Permission is hereby granted, free of charge, to any person obtaining a copy\n"+
        "of this software and associated documentation files (the \"Software\"), to deal\n"+
        "in the Software without restriction, including without limitation the rights\n"+
        "to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\n"+
        "copies of the Software, and to permit persons to whom the Software is\n"+
        "furnished to do so, subject to the following conditions:\n"+
        "\n"+
        "The above copyright notice and this permission notice shall be included in\n"+
        "all copies or substantial portions of the Software.\n"+
        "\n"+
        "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n"+
        "IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n"+
        "FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\n"+
        "AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\n"+
        "LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\n"+
        "OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN\n"+
        "THE SOFTWARE.\n";
}// Main
