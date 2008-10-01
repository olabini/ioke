/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class DefaultBehavior extends IokeObject {
    public DefaultBehavior(Runtime runtime) {
        super(runtime);
    }

    public void init() {
        registerMethod("internal:createText", new JavaMethod(runtime) {
                public IokeObject activate(Context context, Message message, IokeObject on) {
                    String s = (String)message.getArg1();
                    
                    return new Text(runtime, s.substring(1, s.length()-1));
                }
            });

        registerMethod("=", new JavaMethod(runtime) {
                public IokeObject activate(Context context, Message message, IokeObject on) {
                    String name = ((Message)message.getArg1()).getName();
                    IokeObject value = ((Message)message.getArg2()).evaluateCompleteWith(context, context.ground);
                    on.setCell(name, value);
                    return value;
                }
            });

        registerMethod("asString", new JavaMethod(runtime) {
                public IokeObject activate(Context context, Message message, IokeObject on) {
                    return new Text(runtime, on.toString());
                }
            });
    }
}// DefaultBehavior
