/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

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
    }
}// FileSystem
