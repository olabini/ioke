/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;

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

    @Override
    public IokeObject getCode() {
        return message;
    }

    @Override
    public String getArgumentsCode() {
        return arguments.getCode(false);
    }

    @Override
    public void init(IokeObject lexicalBlock) {
        lexicalBlock.setKind("LexicalBlock");

        lexicalBlock.registerMethod(lexicalBlock.runtime.newJavaMethod("takes two evaluated arguments, where this first one is a list of messages which will be used as the arguments and the code, and the second is the context where this lexical scope should be created in", new JavaMethod("createFrom") {
                @Override
                public Object activate(IokeObject self, IokeObject dynamicContext, IokeObject message, Object on) throws ControlFlow {
                    Runtime runtime = dynamicContext.runtime;

                    List<Object> positionalArgs = new ArrayList<Object>();
                    DefaultArgumentsDefinition.getEvaluatedArguments(message, dynamicContext, positionalArgs, new HashMap<String, Object>());
                    
                    List<Object> args = IokeList.getList(positionalArgs.get(0));
                    IokeObject ground = IokeObject.as(positionalArgs.get(1));

                    IokeObject code = IokeObject.as(args.get(args.size()-1));

                    DefaultArgumentsDefinition def = DefaultArgumentsDefinition.createFrom(args, 0, args.size()-1, message, on, dynamicContext);
                    return runtime.newLexicalBlock(runtime.lexicalBlock, new LexicalBlock(ground, def, code));
                }
            }));

        lexicalBlock.registerMethod(lexicalBlock.runtime.newJavaMethod("invokes the block with the arguments provided, returning the result of the last expression in the block", new JavaMethod("call") {
                @Override
                public Object activate(IokeObject self, IokeObject dynamicContext, IokeObject message, Object on) throws ControlFlow {
                    return IokeObject.as(on).activate(dynamicContext, message, on);
                }
            }));

        lexicalBlock.registerMethod(lexicalBlock.runtime.newJavaMethod("returns the full code of this lexical block, as a Text", new JavaMethod("code") {
                @Override
                public Object activate(IokeObject self, IokeObject dynamicContext, IokeObject message, Object on) throws ControlFlow {
                    IokeObject obj = IokeObject.as(on);
                    String x = obj.isActivatable() ? "x" : "";
                    
                    String args = ((LexicalBlock)IokeObject.data(on)).arguments.getCode();
                    return context.runtime.newText("fn" + x + "(" + args + Message.code(((LexicalBlock)IokeObject.data(on)).message) + ")");
                }
            }));

        lexicalBlock.registerMethod(lexicalBlock.runtime.newJavaMethod("returns the code for the argument definition", new JavaMethod("argumentsCode") {
                @Override
                public Object activate(IokeObject self, IokeObject dynamicContext, IokeObject message, Object on) throws ControlFlow {
                    return dynamicContext.runtime.newText(((AssociatedCode)IokeObject.data(on)).getArgumentsCode());
                }
            }));

        lexicalBlock.registerMethod(lexicalBlock.runtime.newJavaMethod("returns a list of the keywords this block takes", new JavaMethod("keywords") {
                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) {
                    List<Object> keywords = new ArrayList<Object>();
                    
                    for(String keyword : ((LexicalBlock)IokeObject.data(on)).arguments.getKeywords()) {
                        keywords.add(context.runtime.getSymbol(keyword.substring(0, keyword.length()-1)));
                    }

                    return context.runtime.newList(keywords);
                }
            }));
        lexicalBlock.registerMethod(lexicalBlock.runtime.newJavaMethod("returns the message chain for this block", new JavaMethod("message") {
                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    return ((AssociatedCode)IokeObject.data(on)).getCode();
                }
            }));
        lexicalBlock.registerMethod(lexicalBlock.runtime.newJavaMethod("Returns a text inspection of the object", new JavaMethod("inspect") {
                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) {
                    return context.runtime.newText(LexicalBlock.getInspect(on));
                }
            }));
        lexicalBlock.registerMethod(lexicalBlock.runtime.newJavaMethod("Returns a brief text inspection of the object", new JavaMethod("notice") {
                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) {
                    return context.runtime.newText(LexicalBlock.getNotice(on));
                }
            }));
        lexicalBlock.registerMethod(lexicalBlock.runtime.newJavaMethod("returns idiomatically formatted code for this lexical block", new JavaMethod("formattedCode") {
                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    return context.runtime.newText(((AssociatedCode)IokeObject.data(on)).getFormattedCode(self));
                }
            }));
    }

    @Override
    public Object activate(IokeObject self, IokeObject dynamicContext, IokeObject message, Object on) throws ControlFlow {
        LexicalContext c = new LexicalContext(self.runtime, on, "Lexical activation context", message, this.context);

        arguments.assignArgumentValues(c, dynamicContext, message, on);

        return this.message.evaluateCompleteWith(c, on);
    }

    public static String getInspect(Object on) {
        return ((LexicalBlock)(IokeObject.data(on))).inspect(on);
    }

    public static String getNotice(Object on) {
        return ((LexicalBlock)(IokeObject.data(on))).notice(on);
    }

    @Override
    public String getFormattedCode(Object self) throws ControlFlow {
        String args = arguments == null ? "" : arguments.getCode();
        if(IokeObject.as(self).isActivatable()) {
            return "fnx(" + args + "\n  " + Message.formattedCode(message, 2) + ")";
        } else {
            return "fn(" + args + "\n  " + Message.formattedCode(message, 2) + ")";
        }
    }

    public String inspect(Object self) {
        String args = arguments.getCode();
        if(IokeObject.as(self).isActivatable()) {
            return "fnx(" + args + Message.code(message) + ")";
        } else {
            return "fn(" + args + Message.code(message) + ")";
        }
    }

    public String notice(Object self) {
        if(IokeObject.as(self).isActivatable()) {
            return "fnx(...)";
        } else {
            return "fn(...)";
        }
    }
}// LexicalBlock
