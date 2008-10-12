/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class DefaultBehavior extends IokeObject {
    public DefaultBehavior(Runtime runtime, String documentation) {
        super(runtime, documentation);
    }

    public void init() {
        registerMethod(new JavaMethod(runtime, "", "returns result of evaluating first argument") {
                public IokeObject activate(Context context, Message message, IokeObject on) {
                    return message.getEvaluatedArgument(0, context);
                }
            });

        registerMethod(new JavaMethod(runtime, "internal:createText", "expects one 'strange' argument. creates a new instance of Text with the given Java String backing it.") {
                public IokeObject activate(Context context, Message message, IokeObject on) {
                    String s = (String)message.getArg1();
                    
                    return new Text(runtime, s.substring(1, s.length()-1));
                }
            });

        registerMethod(new JavaMethod(runtime, "internal:createNumber", "expects one 'strange' argument. creates a new instance of Number that represents the number found in the strange argument.") {
                public IokeObject activate(Context context, Message message, IokeObject on) {
                    String s = (String)message.getArg1();
                    return new Number(runtime, s);
                }
            });

        registerMethod(new JavaMethod(runtime, "=", "expects two arguments, the first unevaluated, the second evaluated. assigns the result of evaluating the second argument in the context of the caller, and assigns this result to the name provided by the first argument. the first argument remains unevaluated. the result of the assignment is the value assigned to the name. if the second argument is a method-like object and it's name is not set, that name will be set to the name of the cell.") {
                public IokeObject activate(Context context, Message message, IokeObject on) {
                    String name = ((Message)message.getArg1()).getName();
                    IokeObject value = ((Message)message.getArg2()).evaluateCompleteWith(context, context.ground);
                    on.setCell(name, value);

                    if((value instanceof Method) && (((Method)value).name == null)) {
                        ((Method)value).name = name;
                    }
                    
                    return value;
                }
            });

        registerMethod(new JavaMethod(runtime, "asText", "returns a textual representation of the object called on.") {
                public IokeObject activate(Context context, Message message, IokeObject on) {
                    return new Text(runtime, on.toString());
                }
            });

        registerMethod(new JavaMethod(runtime, "documentation", "returns the documentation text of the object called on. anything can have a documentation text and an object inherits it's documentation string text the object it mimcs - at mimic time.") {
                public IokeObject activate(Context context, Message message, IokeObject on) {
                    return new Text(runtime, on.documentation);
                }
            });

        registerMethod(new JavaMethod(runtime, "getCell", "expects one evaluated text argument and returns the cell that matches that name, without activating even if it's activatable.") {
                public IokeObject activate(Context context, Message message, IokeObject on) {
                    String name = ((Text)(runtime.asText.sendTo(context, ((Message)message.getArguments().get(0)).evaluateCompleteWith(context, context.ground)))).getText();
                    return on.getCell(name);
                }
            });

        registerMethod(new JavaMethod(runtime, "method", "expects any number of unevaluated arguments. if no arguments at all are given, will just return nil. creates a new method based on the arguments. this method will be evaluated using the context of the object it's called on, and thus the definition can not refer to the outside scope where the method is defined. (there are other ways of achieving this). all arguments except the last one is expected to be names of arguments that will be used in the method. there will possible be additions to the format of arguments later on - including named parameters and optional arguments. the actual code is the last argument given.") {
                public IokeObject activate(Context context, Message message, IokeObject on) {
                    List<Object> args = message.getArguments();

                    if(args.size() == 0) {
                        return new JavaMethod(runtime, "nil", "returns nil") {
                            public IokeObject activate(Context context, Message message, IokeObject on) {
                                return runtime.nil;
                            }};
                    }

                    List<String> argNames = new ArrayList<String>(args.size()-1);
                    for(Object obj : args.subList(0, args.size()-1)) {
                        argNames.add(((Message)obj).getName());
                    }

                    return new DefaultMethod(runtime, context, argNames, (Message)args.get(args.size()-1));
                }
            });

        registerMethod(new JavaMethod(runtime, "use", "takes one or more evaluated string argument. will import the files corresponding to each of the strings named based on the Ioke loading behavior that can be found in the documentation for the loadBehavior cell on System.") {
                public IokeObject activate(Context context, Message message, IokeObject on) {
                    
                    
                    return runtime.nil;
                }
            });
    }

    public String toString() {
        return "DefaultBehavior";
    }
}// DefaultBehavior
