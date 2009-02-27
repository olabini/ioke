/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.BufferedReader;
import java.io.Writer;

import java.nio.channels.FileChannel;

import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

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

    public static class IokeFile extends IokeIO {
        private File file;

        public IokeFile(File file) {
            super(null, null);
            this.file = file;

            try {
                if(file != null) {
                    this.writer = new FileWriter(file);
                }
            } catch(IOException e) {
            }
        }

        @Override
        public void init(IokeObject obj) throws ControlFlow {
            final Runtime runtime = obj.runtime;

            obj.setKind("FileSystem File");

            obj.registerMethod(runtime.newJavaMethod("Closes any open stream to this file", new TypeCheckingJavaMethod.WithNoArguments("close", obj) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    try {
                        Writer writer = IokeFile.getWriter(on);
                        if(writer != null) {
                             writer.close();
                        }
                    } catch(IOException e) {
                    }
                    return context.runtime.nil;
                }
            }));
        }
    }

    public static void init(IokeObject obj) throws ControlFlow {
        Runtime runtime = obj.runtime;
        obj.setKind("FileSystem");

        IokeObject file = new IokeObject(runtime, "represents a file in the file system", new IokeFile(null));
        file.mimicsWithoutCheck(runtime.io);
        file.init();
        obj.registerCell("File", file);

        obj.registerMethod(runtime.newJavaMethod("Tries to interpret the given arguments as strings describing file globs, and returns an array containing the result of applying these globs.", new JavaMethod("[]") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRest("globTexts")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());
                    List<String> dirs = FileSystem.glob(context.runtime, Text.getText(args.get(0)));
                    List<Object> result = new ArrayList<Object>();
                    for(String s : dirs) {
                        result.add(context.runtime.newText(s));
                    }
                    return context.runtime.newList(result);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Takes one string argument and returns true if it's the relative or absolute name of a directory, and false otherwise.", new JavaMethod("directory?") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("directoryName")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    String name = Text.getText(args.get(0));
                    File f = null;
                    if(IokeSystem.isAbsoluteFileName(name)) {
                        f = new File(name);
                    } else {
                        f = new File(context.runtime.getCurrentWorkingDirectory(), name);
                    }
                    
                    return f.isDirectory() ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Takes one string argument that should be a file name, and returns a text of the contents of this file.", new JavaMethod("readFully") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("fileName")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    String name = Text.getText(args.get(0));
                    File f = null;
                    if(IokeSystem.isAbsoluteFileName(name)) {
                        f = new File(name);
                    } else {
                        f = new File(context.runtime.getCurrentWorkingDirectory(), name);
                    }
                    StringBuilder sb = new StringBuilder();

                    try {
                        BufferedReader reader = new BufferedReader(new FileReader(f));
                        char[] buf = new char[1024];
                        int read = -1;
                        while((read = reader.read(buf, 0, 1024)) != -1) {
                            sb.append(buf, 0, read);
                        }
                        reader.close();
                    } catch(IOException e) {
                    }
                    
                    return context.runtime.newText(sb.toString());
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Takes one string argument and returns true if it's the relative or absolute name of a file, and false otherwise.", new JavaMethod("file?") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("fileName")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    String name = Text.getText(args.get(0));
                    File f = null;
                    if(IokeSystem.isAbsoluteFileName(name)) {
                        f = new File(name);
                    } else {
                        f = new File(context.runtime.getCurrentWorkingDirectory(), name);
                    }
                    
                    return f.isFile() ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Takes one string argument and returns true if it's the relative or absolute name of something that exists.", new JavaMethod("exists?") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("entryName")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    String name = Text.getText(args.get(0));
                    File f = null;
                    if(IokeSystem.isAbsoluteFileName(name)) {
                        f = new File(name);
                    } else {
                        f = new File(context.runtime.getCurrentWorkingDirectory(), name);
                    }
                    
                    return f.exists() ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Takes one string argument that should be the path of a file or directory, and returns the parent of it - or nil if there is no parent.", new JavaMethod("parentOf") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("entryName")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    String name = Text.getText(args.get(0));
                    File f = null;
                    if(IokeSystem.isAbsoluteFileName(name)) {
                        f = new File(name);
                    } else {
                        f = new File(context.runtime.getCurrentWorkingDirectory(), name);
                    }
                    
                    String parent = f.getParent();
                    if(parent == null) {
                        return context.runtime.nil;
                    }

                    String cwd = context.runtime.getCurrentWorkingDirectory();

                    if(!IokeSystem.isAbsoluteFileName(name) && parent.equals(cwd)) {
                        return context.runtime.nil;
                    }

                    if(parent.startsWith(cwd)) {
                        parent = parent.substring(cwd.length()+1);
                    }

                    return context.runtime.newText(parent);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Takes a file name and a lexical block - opens the file, ensures that it exists and then yields the file to the block. Finally it closes the file after the block has finished executing, and then returns the result of the block.", new JavaMethod("withOpenFile") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("fileName")
                    .withRequiredPositional("code")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    String name = Text.getText(args.get(0));
                    File f = null;
                    if(IokeSystem.isAbsoluteFileName(name)) {
                        f = new File(name);
                    } else {
                        f = new File(context.runtime.getCurrentWorkingDirectory(), name);
                    }

                    try {
                        if(!f.exists()) {
                            f.createNewFile();
                        }
                    } catch(IOException e) {
                    }

                    IokeObject ff = context.runtime.newFile(context, f);
                    Object result = context.runtime.nil;

                    try {
                        result = context.runtime.callMessage.sendTo(context, args.get(1), ff);
                    } finally {
                        context.runtime.closeMessage.sendTo(context, ff);
                    }

                    return result;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Copies a file. Takes two text arguments, where the first is the name of the file to copy and the second is the name of the destination. If the destination is a directory, the file will be copied with the same name, and if it's a filename, the file will get a new name", new JavaMethod("copyFile") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("fileName")
                    .withRequiredPositional("destination")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    String name = Text.getText(args.get(0));
                    File f = null;
                    if(IokeSystem.isAbsoluteFileName(name)) {
                        f = new File(name);
                    } else {
                        f = new File(context.runtime.getCurrentWorkingDirectory(), name);
                    }

                    String name2 = Text.getText(args.get(1));
                    File f2 = null;
                    if(IokeSystem.isAbsoluteFileName(name2)) {
                        f2 = new File(name2);
                    } else {
                        f2 = new File(context.runtime.getCurrentWorkingDirectory(), name2);
                    }

                    if(f2.isDirectory()) {
                        f2 = new File(f2, f.getName());
                    }


                    try {
                        if(!f2.exists()) {
                            f2.createNewFile();
                        }

                        FileChannel srcChannel = new FileInputStream(f).getChannel();
                        FileChannel dstChannel = new FileOutputStream(f2).getChannel();

                        dstChannel.transferFrom(srcChannel, 0, srcChannel.size());
                        srcChannel.close();
                        dstChannel.close();
                    } catch (IOException e) {
                    }

                    return context.runtime.nil;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Takes one string argument and creates a directory with that name. It also takes an optional second argument. If it's true, will try to create all necessary directories inbetween. Default is false. Will signal a condition if the directory already exists, or if there's a file with that name.", new JavaMethod("createDirectory!") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("directoryName")
                    .withOptionalPositional("createPath", "false")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    String name = Text.getText(args.get(0));
                    File f = null;
                    if(IokeSystem.isAbsoluteFileName(name)) {
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
                                                                                           "IO"), context).mimic(message, context);
                        condition.setCell("message", message);
                        condition.setCell("context", context);
                        condition.setCell("receiver", on);
                        condition.setCell("text", runtime.newText(msg));

                        runtime.withReturningRestart("ignore", context, new RunnableWithControlFlow() {
                                public void run() throws ControlFlow {
                                    runtime.errorCondition(condition);
                                }});
                    }

                    if(args.size() > 1 && IokeObject.isTrue(args.get(1))) {
                        f.mkdirs();
                    } else {
                        f.mkdir();
                    }

                    return context.runtime.nil;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Takes one string argument and removes a directory with that name. Will signal a condition if the directory doesn't exist, or if there's a file with that name.", new JavaMethod("removeDirectory!") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("directoryName")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    String name = Text.getText(args.get(0));
                    File f = null;
                    if(IokeSystem.isAbsoluteFileName(name)) {
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
                                                                                           "IO"), context).mimic(message, context);
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
