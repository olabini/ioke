/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class System extends IokeObject {
    public System(Runtime runtime) {
        super(runtime);
    }

    public void init() {
        registerMethod("internal:createText", new JavaMethod(runtime) {
                public IokeObject activate(Message message, IokeObject on) {
                    String s = (String)message.getArg1();
                    
                    return new Text(runtime, s.substring(1, s.length()-1));
                }
            });
    }
}// System
