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

    IokeObject allocateCopy() {
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
        registerCell("nil", runtime.nil);
        registerCell("Method", runtime.method);
        registerCell("DefaultMethod", runtime.defaultMethod);
        registerCell("JavaMethod", runtime.javaMethod);
    }

    public String toString() {
        return "Ground";
    }
}// Ground
