/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

/**
 * The Ground serves the same purpose as the Lobby in Self and Io.
 * This is the place where everything is evaluated.
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Ground extends IokeObject {
    Ground(Runtime runtime, String documentation) {
        super(runtime, documentation);
    }

    @Override
    IokeObject allocateCopy(Message m) {
        return new Ground(runtime, documentation);
    }

    public void init() {
        registerCell("Base", runtime.base);
        registerCell("DefaultBehavior", runtime.defaultBehavior);
        registerCell("Ground", runtime.ground);
        registerCell("Origin", runtime.origin);
        registerCell("System", runtime.system);
        registerCell("Runtime", runtime.runtime);
        registerCell("Text", runtime.text);
        registerCell("Number", runtime.number);
        registerCell("nil", runtime.nil);
        registerCell("true", runtime._true);
        registerCell("false", runtime._false);
        registerCell("Method", runtime.method);
        registerCell("DefaultMethod", runtime.defaultMethod);
        registerCell("JavaMethod", runtime.javaMethod);
        registerCell("Mixins", runtime.mixins);
    }

    public String toString() {
        return "Ground";
    }
}// Ground
