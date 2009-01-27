/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.Arrays;
import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.HashSet;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class DefinitionsBehavior {
    public static void init(IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;
        obj.setKind("DefaultBehavior Definitions");

        obj.registerMethod(runtime.newJavaMethod("expects any number of unevaluated arguments. if no arguments at all are given, will just return nil. creates a new method based on the arguments. this method will be evaluated using the context of the object it's called on, and thus the definition can not refer to the outside scope where the method is defined. (there are other ways of achieving this). all arguments except the last one is expected to be names of arguments that will be used in the method. there will possible be additions to the format of arguments later on - including named parameters and optional arguments. the actual code is the last argument given.", new JavaMethod("method") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withOptionalPositionalUnevaluated("documentation")
                    .withRestUnevaluated("argumentsAndBody")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    List<Object> args = message.getArguments();

                    if(args.size() == 0) {
                        final Message mx = new Message(context.runtime, "nil", null, Message.Type.MESSAGE);
                        mx.setFile(Message.file(message));
                        mx.setLine(Message.line(message));
                        mx.setPosition(Message.position(message));
                        final IokeObject mmx = context.runtime.createMessage(mx);
                        return runtime.newMethod(null, runtime.defaultMethod, new DefaultMethod(context, DefaultArgumentsDefinition.empty(), mmx));
                    }

                    String doc = null;

                    List<String> argNames = new ArrayList<String>(args.size()-1);
                    int start = 0;
                    if(args.size() > 1 && ((IokeObject)Message.getArg1(message)).getName().equals("internal:createText")) {
                        start++;
                        String s = ((String)((IokeObject)args.get(0)).getArguments().get(0));
                        doc = s;
                    }

                    DefaultArgumentsDefinition def = DefaultArgumentsDefinition.createFrom(args, start, args.size()-1, message, on, context);

                    return runtime.newMethod(doc, runtime.defaultMethod, new DefaultMethod(context, def, (IokeObject)args.get(args.size()-1)));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects one code argument, optionally preceeded by a documentation string. will create a new DefaultMacro based on the code and return it.", new JavaMethod("macro") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withOptionalPositionalUnevaluated("documentation")
                    .withOptionalPositionalUnevaluated("body")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    List<Object> args = message.getArguments();

                    if(args.size() == 0) {
                        final Message mx = new Message(context.runtime, "nil", null, Message.Type.MESSAGE);
                        mx.setFile(Message.file(message));
                        mx.setLine(Message.line(message));
                        mx.setPosition(Message.position(message));
                        final IokeObject mmx = context.runtime.createMessage(mx);

                        return runtime.newMacro(null, runtime.defaultMacro, new DefaultMacro(context, mmx));
                    }

                    String doc = null;

                    int start = 0;
                    if(args.size() > 1 && ((IokeObject)Message.getArg1(message)).getName().equals("internal:createText")) {
                        start++;
                        String s = ((String)((IokeObject)args.get(0)).getArguments().get(0));
                        doc = s;
                    }

                    return runtime.newMacro(doc, runtime.defaultMacro, new DefaultMacro(context, (IokeObject)args.get(start)));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects one code argument, optionally preceeded by a documentation string. will create a new DefaultSyntax based on the code and return it.", new JavaMethod("syntax") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withOptionalPositionalUnevaluated("documentation")
                    .withOptionalPositionalUnevaluated("body")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    List<Object> args = message.getArguments();

                    if(args.size() == 0) {
                        final Message mx = new Message(context.runtime, "nil", null, Message.Type.MESSAGE);
                        mx.setFile(Message.file(message));
                        mx.setLine(Message.line(message));
                        mx.setPosition(Message.position(message));
                        final IokeObject mmx = context.runtime.createMessage(mx);

                        return runtime.newMacro(null, runtime.defaultSyntax, new DefaultSyntax(context, mmx));
                    }

                    String doc = null;

                    int start = 0;
                    if(args.size() > 1 && ((IokeObject)Message.getArg1(message)).getName().equals("internal:createText")) {
                        start++;
                        String s = ((String)((IokeObject)args.get(0)).getArguments().get(0));
                        doc = s;
                    }

                    return runtime.newMacro(doc, runtime.defaultSyntax, new DefaultSyntax(context, (IokeObject)args.get(start)));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects one code argument, optionally preceeded by a documentation string. will create a new LexicalMacro based on the code and return it.", new JavaMethod("lecro") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withOptionalPositionalUnevaluated("documentation")
                    .withOptionalPositionalUnevaluated("body")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    List<Object> args = message.getArguments();

                    if(args.size() == 0) {
                        final Message mx = new Message(context.runtime, "nil", null, Message.Type.MESSAGE);
                        mx.setFile(Message.file(message));
                        mx.setLine(Message.line(message));
                        mx.setPosition(Message.position(message));
                        final IokeObject mmx = context.runtime.createMessage(mx);

                        return runtime.newMacro(null, runtime.lexicalMacro, new LexicalMacro(context, mmx));
                    }

                    String doc = null;

                    int start = 0;
                    if(args.size() > 1 && ((IokeObject)Message.getArg1(message)).getName().equals("internal:createText")) {
                        start++;
                        String s = ((String)((IokeObject)args.get(0)).getArguments().get(0));
                        doc = s;
                    }

                    return runtime.newMacro(doc, runtime.lexicalMacro, new LexicalMacro(context, (IokeObject)args.get(start)));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("creates a new lexical block that can be executed at will, while retaining a reference to the lexical closure it was created in. it will always update variables if they exist. there is currently no way of introducing shadowing variables in the local context. new variables can be created though, just like in a method. a lexical block mimics LexicalBlock, and can take arguments. at the moment these are restricted to required arguments, but support for the same argument types as DefaultMethod will come. same as fn()", new JavaMethod("\u028E") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withOptionalPositionalUnevaluated("documentation")
                    .withRestUnevaluated("argumentsAndBody")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    List<Object> args = message.getArguments();
                    if(args.isEmpty()) {
                        return runtime.newLexicalBlock(null, runtime.lexicalBlock, new LexicalBlock(context, DefaultArgumentsDefinition.empty(), method.runtime.nilMessage));
                    }

                    IokeObject code = IokeObject.as(args.get(args.size()-1), context);

                    DefaultArgumentsDefinition def = DefaultArgumentsDefinition.createFrom(args, 0, args.size()-1, message, on, context);
                    return runtime.newLexicalBlock(null, runtime.lexicalBlock, new LexicalBlock(context, def, code));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("creates a new lexical block that can be executed at will, while retaining a reference to the lexical closure it was created in. it will always update variables if they exist. there is currently no way of introducing shadowing variables in the local context. new variables can be created though, just like in a method. a lexical block mimics LexicalBlock, and can take arguments. at the moment these are restricted to required arguments, but support for the same argument types as DefaultMethod will come.", new JavaMethod("fn") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withOptionalPositionalUnevaluated("documentation")
                    .withRestUnevaluated("argumentsAndBody")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    List<Object> args = message.getArguments();
                    if(args.isEmpty()) {
                        return runtime.newLexicalBlock(null, runtime.lexicalBlock, new LexicalBlock(context, DefaultArgumentsDefinition.empty(), method.runtime.nilMessage));
                    }

                    String doc = null;

                    List<String> argNames = new ArrayList<String>(args.size()-1);
                    int start = 0;
                    if(args.size() > 1 && ((IokeObject)Message.getArg1(message)).getName().equals("internal:createText")) {
                        start++;
                        String s = ((String)((IokeObject)args.get(0)).getArguments().get(0));
                        doc = s;
                    }

                    IokeObject code = IokeObject.as(args.get(args.size()-1), context);

                    DefaultArgumentsDefinition def = DefaultArgumentsDefinition.createFrom(args, start, args.size()-1, message, on, context);
                    return runtime.newLexicalBlock(doc, runtime.lexicalBlock, new LexicalBlock(context, def, code));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Takes two evaluated text or symbol arguments that name the method to alias, and the new name to give it. returns the receiver.", new JavaMethod("aliasMethod") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("oldName")
                    .withRequiredPositional("newName")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    String fromName = Text.getText(runtime.asText.sendTo(context, args.get(0)));
                    String toName = Text.getText(runtime.asText.sendTo(context, args.get(1)));
                    IokeObject.as(on, context).aliasMethod(fromName, toName, message, context);
                    return on;
                }
            }));
    }
}
