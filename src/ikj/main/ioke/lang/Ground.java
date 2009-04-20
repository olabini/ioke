/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.ArrayList;
import java.util.HashMap;

import ioke.lang.exceptions.ControlFlow;

/**
 * The Ground serves the same purpose as the Lobby in Self and Io.
 * This is the place where everything is evaluated.
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Ground {
    public static void init(IokeObject iokeGround, IokeObject ground) throws ControlFlow {
        Runtime runtime = ground.runtime;
        iokeGround.setKind("IokeGround");
        ground.setKind("Ground");
        iokeGround.registerCell("Base", runtime.base);
        iokeGround.registerCell("DefaultBehavior", runtime.defaultBehavior);
        iokeGround.registerCell("IokeGround", runtime.iokeGround);
        iokeGround.registerCell("Ground", runtime.ground);
        iokeGround.registerCell("Origin", runtime.origin);
        iokeGround.registerCell("System", runtime.system);
        iokeGround.registerCell("Runtime", runtime.runtime);
        iokeGround.registerCell("Text", runtime.text);
        iokeGround.registerCell("Symbol", runtime.symbol);
        iokeGround.registerCell("Number", runtime.number);
        iokeGround.registerCell("nil", runtime.nil);
        iokeGround.registerCell("true", runtime._true);
        iokeGround.registerCell("false", runtime._false);
        iokeGround.registerCell("Arity", runtime.arity);
        iokeGround.registerCell("Method", runtime.method);
        iokeGround.registerCell("DefaultMethod", runtime.defaultMethod);
        iokeGround.registerCell("JavaMethod", runtime.javaMethod);
        iokeGround.registerCell("LexicalBlock", runtime.lexicalBlock);
        iokeGround.registerCell("DefaultMacro", runtime.defaultMacro);
        iokeGround.registerCell("LexicalMacro", runtime.lexicalMacro);
        iokeGround.registerCell("DefaultSyntax", runtime.defaultSyntax);
        iokeGround.registerCell("Mixins", runtime.mixins);
        iokeGround.registerCell("Restart", runtime.restart);
        iokeGround.registerCell("List", runtime.list);
        iokeGround.registerCell("Dict", runtime.dict);
        iokeGround.registerCell("Set", runtime.set);
        iokeGround.registerCell("Range", runtime.range);
        iokeGround.registerCell("Pair", runtime.pair);
        iokeGround.registerCell("DateTime", runtime.dateTime);
        iokeGround.registerCell("Message", runtime.message);
        iokeGround.registerCell("Call", runtime.call);
        iokeGround.registerCell("Condition", runtime.condition);
        iokeGround.registerCell("Rescue", runtime.rescue);
        iokeGround.registerCell("Handler", runtime.handler);
        iokeGround.registerCell("IO", runtime.io);
        iokeGround.registerCell("FileSystem", runtime.fileSystem);
        iokeGround.registerCell("Regexp", runtime.regexp);
        iokeGround.registerCell("JavaGround", runtime.javaGround);

        iokeGround.registerMethod(runtime.newJavaMethod("will return a text representation of the current stack trace", 
                                                    new JavaMethod.WithNoArguments("stackTraceAsText") {
                                                        @Override
                                                        public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                                                            getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());

                                                            return context.runtime.newText("");
                                                        }}));
    }
}// Ground
