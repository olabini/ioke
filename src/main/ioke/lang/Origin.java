/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Origin extends IokeObject {
    public Origin(Runtime runtime) {
        super(runtime);
    }

    IokeObject allocateCopy() {
        return new Origin(runtime);
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

    public String toString() {
        if(this == runtime.origin) {
            return "Origin";
        } else {
            return "#<Origin:" + System.identityHashCode(this) + ">";
        }
    }
}// Origin
