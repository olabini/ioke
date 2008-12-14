/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.io.File;
import java.io.IOException;

import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;

import ioke.lang.exceptions.ControlFlow;

import ioke.lang.util.Dir;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class FileSystem {
    public static List<String> glob(Runtime runtime, String text) {
        return Dir.push_glob(runtime.getCurrentWorkingDirectory(), text, 0);
    }

    public static void init(IokeObject obj) {
        Runtime runtime = obj.runtime;
        obj.setKind("FileSystem");

        obj.registerMethod(runtime.newJavaMethod("Tries to interpret the given arguments as strings describing file globs, and returns an array containing the result of applying these globs.", new JavaMethod("[]") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    DefaultArgumentsDefinition.getEvaluatedArguments(message, context, args, new HashMap<String, Object>());
                    List<String> dirs = FileSystem.glob(context.runtime, Text.getText(args.get(0)));
                    List<Object> result = new ArrayList<Object>();
                    for(String s : dirs) {
                        result.add(context.runtime.newText(s));
                    }
                    return context.runtime.newList(result);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Takes one string argument and returns true if it's the relative or absolute name of a directory, and false otherwise.", new JavaMethod("directory?") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    DefaultArgumentsDefinition.getEvaluatedArguments(message, context, args, new HashMap<String, Object>());
                    String name = Text.getText(args.get(0));
                    File f = null;
                    if(name.startsWith("/")) {
                        f = new File(name);
                    } else {
                        f = new File(context.runtime.getCurrentWorkingDirectory(), name);
                    }
                    
                    return f.isDirectory() ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Takes one string argument and returns true if it's the relative or absolute name of a file, and false otherwise.", new JavaMethod("file?") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    DefaultArgumentsDefinition.getEvaluatedArguments(message, context, args, new HashMap<String, Object>());
                    String name = Text.getText(args.get(0));
                    File f = null;
                    if(name.startsWith("/")) {
                        f = new File(name);
                    } else {
                        f = new File(context.runtime.getCurrentWorkingDirectory(), name);
                    }
                    
                    return f.isFile() ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Takes one string argument and returns true if it's the relative or absolute name of something that exists.", new JavaMethod("exists?") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    DefaultArgumentsDefinition.getEvaluatedArguments(message, context, args, new HashMap<String, Object>());
                    String name = Text.getText(args.get(0));
                    File f = null;
                    if(name.startsWith("/")) {
                        f = new File(name);
                    } else {
                        f = new File(context.runtime.getCurrentWorkingDirectory(), name);
                    }
                    
                    return f.exists() ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Takes one string argument and creates a directory with that name. Will signal a condition if the directory already exists, or if there's a file with that name.", new JavaMethod("createDirectory!") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    DefaultArgumentsDefinition.getEvaluatedArguments(message, context, args, new HashMap<String, Object>());
                    String name = Text.getText(args.get(0));
                    File f = null;
                    if(name.startsWith("/")) {
                        f = new File(name);
                    } else {
                        f = new File(context.runtime.getCurrentWorkingDirectory(), name);
                    }

                    final Runtime runtime = context.runtime;
                    if(f.exists()) {
                        String msg = null;
                        if(f.isFile()) {
                            msg = "Can't create directory '" + name + "' since there already exists a file with that name";
                        } else {
                            msg = "Can't create directory '" + name + "' since there already exists a directory with that name";
                        }

                        final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition, 
                                                                                           message, 
                                                                                           context, 
                                                                                           "Error", 
                                                                                           "IO")).mimic(message, context);
                        condition.setCell("message", message);
                        condition.setCell("context", context);
                        condition.setCell("receiver", on);
                        condition.setCell("text", runtime.newText(msg));

                        runtime.withReturningRestart("ignore", context, new RunnableWithControlFlow() {
                                public void run() throws ControlFlow {
                                    runtime.errorCondition(condition);
                                }});
                    }

                    f.mkdir();

                    return context.runtime.nil;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Takes one string argument and removes a directory with that name. Will signal a condition if the directory doesn't exist, or if there's a file with that name.", new JavaMethod("removeDirectory!") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    DefaultArgumentsDefinition.getEvaluatedArguments(message, context, args, new HashMap<String, Object>());
                    String name = Text.getText(args.get(0));
                    File f = null;
                    if(name.startsWith("/")) {
                        f = new File(name);
                    } else {
                        f = new File(context.runtime.getCurrentWorkingDirectory(), name);
                    }

                    final Runtime runtime = context.runtime;
                    if(!f.exists() || f.isFile()) {
                        String msg = null;
                        if(f.isFile()) {
                            msg = "Can't remove directory '" + name + "' since it is a file";
                        } else {
                            msg = "Can't remove directory '" + name + "' since it doesn't exist";
                        }

                        final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition, 
                                                                                           message, 
                                                                                           context, 
                                                                                           "Error", 
                                                                                           "IO")).mimic(message, context);
                        condition.setCell("message", message);
                        condition.setCell("context", context);
                        condition.setCell("receiver", on);
                        condition.setCell("text", runtime.newText(msg));

                        runtime.withReturningRestart("ignore", context, new RunnableWithControlFlow() {
                                public void run() throws ControlFlow {
                                    runtime.errorCondition(condition);
                                }});
                    }

                    f.delete();

                    return context.runtime.nil;
                }
            }));
    }
}// FileSystem
