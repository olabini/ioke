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
public class CaseBehavior {
    public static IokeObject transformWhenStatement(Object when, IokeObject context, IokeObject message, IokeObject caseMimic) throws ControlFlow {
        String outerName = Message.name(when);

        if(caseMimic.getCells().containsKey("case:" + outerName)) {
            IokeObject cp = Message.deepCopy(when);
            replaceAllCaseNames(cp, context, message, caseMimic);
            return cp;
        } 

        return IokeObject.as(when, context);
    }

    private static void replaceAllCaseNames(IokeObject when, IokeObject context, IokeObject message, IokeObject caseMimic) throws ControlFlow {
        String theName = "case:" + Message.name(when);
        if(caseMimic.getCells().containsKey(theName)) {
            Message.setName(when, theName);

            for(Object arg : when.getArguments()) {
                replaceAllCaseNames(IokeObject.as(arg, context), context, message, caseMimic);
            }
        }
    }

    public static void init(final IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;
        obj.setKind("DefaultBehavior Case");

        obj.registerMethod(runtime.newJavaMethod("takes one argument that should evaluate to a value, zero or more whenAndThen pairs and one optional else clause. will first evaluate the initial value, then check each whenAndThen pair against this value. if the when part of a pair returns true, then return the result of evaluating the then part. if no pair matches and no else clause is present, returns nil. if an else clause is there, it should be the last one. each whenAndThen pair is comprised of two arguments, where the first is the when argument and the second is the then argument. the when part will be evaluated and the result of this evaluation will be sent a === message with the value as argument.", new JavaMethod("case") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("value")
                    .withRestUnevaluated("whensAndThens")
                    .withOptionalPositionalUnevaluated("elseCode")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);
                    final Runtime runtime = context.runtime;

                    List<Object> args = message.getArguments();
                    int argCount = args.size();
                    int index = 0;
                    Object value = IokeObject.as(args.get(index++), context).evaluateCompleteWithoutExplicitReceiver(context, context.getRealContext());
                    argCount--;

                    while(argCount > 1) {
                        Object when = transformWhenStatement(args.get(index++), context, message, obj).evaluateCompleteWithoutExplicitReceiver(context, context.getRealContext());
                        if(IokeObject.isTrue(runtime.eqqMessage.sendTo(context, when, value))) {
                            return IokeObject.as(args.get(index++), context).evaluateCompleteWithoutExplicitReceiver(context, context.getRealContext());
                        } else {
                            index++;
                        }
                        argCount -= 2;
                    }

                    if(argCount == 1) {
                        return IokeObject.as(args.get(index++), context).evaluateCompleteWithoutExplicitReceiver(context, context.getRealContext());
                    }

                    return runtime.nil;
                }
            }));
        
    }
}
