/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Base extends IokeObject {
    public Base(Runtime runtime) {
        super(runtime);
    }

    IokeObject allocateCopy() {
        return new Base(runtime);
    }

    public void init() {
        registerMethod("mimic", new JavaMethod(runtime) {
                public IokeObject activate(Context context, Message message, IokeObject on) {
                    IokeObject clone = on.allocateCopy();
                    clone.mimics(on);
                    return clone;
                }
            });
    }
}// Base
