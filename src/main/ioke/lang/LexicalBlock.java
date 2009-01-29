/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class LexicalBlock extends IokeData implements AssociatedCode {
    private DefaultArgumentsDefinition arguments;
    private IokeObject context;
    private IokeObject message;

    public LexicalBlock(IokeObject context, DefaultArgumentsDefinition arguments, IokeObject message) {
        this.context = context;
        this.arguments = arguments;
        this.message = message;
    }

    public LexicalBlock(IokeObject context) {
        this(context, DefaultArgumentsDefinition.empty(), context.runtime.nilMessage);
    }

    public IokeObject getCode() {
        return message;
    }

    public String getArgumentsCode() {
        return arguments.getCode(false);
    }

    @Override
    public void init(IokeObject lexicalBlock) throws ControlFlow {
        lexicalBlock.setKind("LexicalBlock");

        lexicalBlock.registerMethod(lexicalBlock.runtime.newJavaMethod("takes two evaluated arguments, where this first one is a list of messages which will be used as the arguments and the code, and the second is the context where this lexical scope should be created in", new JavaMethod("createFrom") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("messageList")
                    .withRequiredPositional("lexicalContext")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject self, IokeObject dynamicContext, IokeObject message, Object on) throws ControlFlow {
                    Runtime runtime = dynamicContext.runtime;

                    List<Object> positionalArgs = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(dynamicContext, message, on, positionalArgs, new HashMap<String, Object>());
                    
                    List<Object> args = IokeList.getList(positionalArgs.get(0));
                    IokeObject ground = IokeObject.as(positionalArgs.get(1), dynamicContext);

                    IokeObject code = IokeObject.as(args.get(args.size()-1), dynamicContext);

                    DefaultArgumentsDefinition def = DefaultArgumentsDefinition.createFrom(args, 0, args.size()-1, message, on, dynamicContext);
                    return runtime.newLexicalBlock(null, runtime.lexicalBlock, new LexicalBlock(ground, def, code));
                }
            }));

        lexicalBlock.registerMethod(lexicalBlock.runtime.newJavaMethod("invokes the block with the arguments provided, returning the result of the last expression in the block", new JavaMethod("call") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRestUnevaluated("arguments")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject self, IokeObject dynamicContext, IokeObject message, Object on) throws ControlFlow {
                    return IokeObject.as(on, dynamicContext).activate(dynamicContext, message, on);
                }
            }));

        lexicalBlock.registerMethod(lexicalBlock.runtime.newJavaMethod("returns the full code of this lexical block, as a Text", new JavaMethod.WithNoArguments("code") {
                @Override
                public Object activate(IokeObject self, IokeObject dynamicContext, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(dynamicContext, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    IokeObject obj = IokeObject.as(on, dynamicContext);
                    String x = obj.isActivatable() ? "x" : "";
                    
                    String args = ((LexicalBlock)IokeObject.data(on)).arguments.getCode();
                    return context.runtime.newText("fn" + x + "(" + args + Message.code(((LexicalBlock)IokeObject.data(on)).message) + ")");
                }
            }));

        lexicalBlock.registerMethod(lexicalBlock.runtime.newJavaMethod("returns the code for the argument definition", new JavaMethod.WithNoArguments("argumentsCode") {
                @Override
                public Object activate(IokeObject self, IokeObject dynamicContext, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(dynamicContext, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return dynamicContext.runtime.newText(((AssociatedCode)IokeObject.data(on)).getArgumentsCode());
                }
            }));

        lexicalBlock.registerMethod(lexicalBlock.runtime.newJavaMethod("returns a list of the keywords this block takes", new JavaMethod.WithNoArguments("keywords") {
                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    List<Object> keywords = new ArrayList<Object>();
                    
                    for(String keyword : ((LexicalBlock)IokeObject.data(on)).arguments.getKeywords()) {
                        keywords.add(context.runtime.getSymbol(keyword.substring(0, keyword.length()-1)));
                    }

                    return context.runtime.newList(keywords);
                }
            }));

        lexicalBlock.registerMethod(lexicalBlock.runtime.newJavaMethod("returns a list of the argument names the positional arguments this block takes", new JavaMethod.WithNoArguments("argumentNames") {
                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    List<Object> names = new ArrayList<Object>();
                    
                    for(DefaultArgumentsDefinition.Argument arg :  ((LexicalBlock)IokeObject.data(on)).arguments.getArguments()) {
                        if(!(arg instanceof DefaultArgumentsDefinition.KeywordArgument)) {
                            names.add(context.runtime.getSymbol(arg.getName()));
                        }
                    }

                    return context.runtime.newList(names);
                }
            }));

        lexicalBlock.registerMethod(lexicalBlock.runtime.newJavaMethod("returns the message chain for this block", new JavaMethod.WithNoArguments("message") {
                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return ((AssociatedCode)IokeObject.data(on)).getCode();
                }
            }));
        lexicalBlock.registerMethod(lexicalBlock.runtime.newJavaMethod("Returns a text inspection of the object", new JavaMethod.WithNoArguments("inspect") {
                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return context.runtime.newText(LexicalBlock.getInspect(on));
                }
            }));
        lexicalBlock.registerMethod(lexicalBlock.runtime.newJavaMethod("Returns a brief text inspection of the object", new JavaMethod.WithNoArguments("notice") {
                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return context.runtime.newText(LexicalBlock.getNotice(on));
                }
            }));
        lexicalBlock.registerMethod(lexicalBlock.runtime.newJavaMethod("returns idiomatically formatted code for this lexical block", new JavaMethod.WithNoArguments("formattedCode") {
                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return context.runtime.newText(((AssociatedCode)IokeObject.data(on)).getFormattedCode(self));
                }
            }));
    }

    @Override
    public Object activateWithCallAndData(final IokeObject self, IokeObject dynamicContext, IokeObject message, Object on, Object call, Map<String, Object> data) throws ControlFlow {
        LexicalContext c = new LexicalContext(self.runtime, on, "Lexical activation context", message, this.context);

        for(Map.Entry<String, Object> d : data.entrySet()) {
            String s = d.getKey();
            c.setCell(s.substring(0, s.length()-1), d.getValue());
        }
        arguments.assignArgumentValues(c, dynamicContext, message, on, ((Call)IokeObject.data(call)));

        return this.message.evaluateCompleteWith(c, on);
    }

    @Override
    public Object activateWithCall(IokeObject self, IokeObject dynamicContext, IokeObject message, Object on, Object call) throws ControlFlow {
        LexicalContext c = new LexicalContext(self.runtime, on, "Lexical activation context", message, this.context);

        arguments.assignArgumentValues(c, dynamicContext, message, on, ((Call)IokeObject.data(call)));

        return this.message.evaluateCompleteWith(c, on);
    }

    @Override
    public Object activate(IokeObject self, IokeObject dynamicContext, IokeObject message, Object on) throws ControlFlow {
        LexicalContext c = new LexicalContext(self.runtime, on, "Lexical activation context", message, this.context);

        arguments.assignArgumentValues(c, dynamicContext, message, on);

        return this.message.evaluateCompleteWith(c, on);
    }

    @Override
    public Object activateWithData(IokeObject self, IokeObject dynamicContext, IokeObject message, Object on, Map<String, Object> data) throws ControlFlow {
        LexicalContext c = new LexicalContext(self.runtime, on, "Lexical activation context", message, this.context);

        for(Map.Entry<String, Object> d : data.entrySet()) {
            String s = d.getKey();
            c.setCell(s.substring(0, s.length()-1), d.getValue());
        }

        arguments.assignArgumentValues(c, dynamicContext, message, on);

        return this.message.evaluateCompleteWith(c, on);
    }

    public static String getInspect(Object on) {
        return ((LexicalBlock)(IokeObject.data(on))).inspect(on);
    }

    public static String getNotice(Object on) {
        return ((LexicalBlock)(IokeObject.data(on))).notice(on);
    }

    public String getFormattedCode(Object self) throws ControlFlow {
        String args = arguments == null ? "" : arguments.getCode();
        if(IokeObject.as(self, null).isActivatable()) {
            return "fnx(" + args + "\n  " + Message.formattedCode(message, 2) + ")";
        } else {
            return "fn(" + args + "\n  " + Message.formattedCode(message, 2) + ")";
        }
    }

    public String inspect(Object self) {
        String args = arguments.getCode();
        if(IokeObject.as(self, null).isActivatable()) {
            return "fnx(" + args + Message.code(message) + ")";
        } else {
            return "fn(" + args + Message.code(message) + ")";
        }
    }

    public String notice(Object self) {
        if(IokeObject.as(self, null).isActivatable()) {
            return "fnx(...)";
        } else {
            return "fn(...)";
        }
    }
}// LexicalBlock
