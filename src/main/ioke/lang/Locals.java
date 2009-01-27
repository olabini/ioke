/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.Map;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Locals {
    public static void init(IokeObject obj) throws ControlFlow {
        obj.setKind("Locals");
        obj.getMimics().clear();

        obj.setCell("=",         obj.runtime.base.getCells().get("="));
        Map<String, Object> assgn = IokeObject.as(obj.runtime.defaultBehavior.getCells().get("Assignment"), null).getCells();
        obj.setCell("++",        assgn.get("++"));
        obj.setCell("--",        assgn.get("--"));
        obj.setCell("+=",        assgn.get("+="));
        obj.setCell("-=",        assgn.get("-="));
        obj.setCell("/=",        assgn.get("/="));
        obj.setCell("*=",        assgn.get("*="));
        obj.setCell("%=",        assgn.get("%="));
        obj.setCell("**=",       assgn.get("**="));
        obj.setCell("&=",        assgn.get("&="));
        obj.setCell("|=",        assgn.get("|="));
        obj.setCell("^=",        assgn.get("^="));
        obj.setCell("<<=",       assgn.get("<<="));
        obj.setCell(">>=",       assgn.get(">>="));
        obj.setCell("&&=",       assgn.get("&&="));
        obj.setCell("||=",       assgn.get("||="));
        obj.setCell("cell",      obj.runtime.base.getCells().get("cell"));
        obj.setCell("cell=",     obj.runtime.base.getCells().get("cell="));
        obj.setCell("cells",     obj.runtime.base.getCells().get("cells"));
        obj.setCell("cellNames", obj.runtime.base.getCells().get("cellNames"));
        obj.setCell("removeCell!", obj.runtime.base.getCells().get("removeCell!"));
        obj.setCell("undefineCell!", obj.runtime.base.getCells().get("undefineCell!"));
        obj.setCell("cellOwner?", obj.runtime.base.getCells().get("cellOwner?"));
        obj.setCell("cellOwner", obj.runtime.base.getCells().get("cellOwner"));
        obj.setCell("identity",  obj.runtime.base.getCells().get("identity"));

        obj.registerMethod(obj.runtime.newJavaMethod("will pass along the call to the real self object of this context.", 
                                                       new JavaMethod("pass") {
                                                           private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                                                               .builder()
                                                               .withRestUnevaluated("arguments")
                                                               .getArguments();

                                                           @Override
                                                           public DefaultArgumentsDefinition getArguments() {
                                                               return ARGUMENTS;
                                                           }

                                                           @Override
                                                           public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                                                               Object selfDelegate = IokeObject.as(on, context).getSelf();

                                                               if(selfDelegate != null && selfDelegate != on) {
                                                                   return IokeObject.perform(selfDelegate, context, message);
                                                               }

                                                               return context.runtime.nil;
                                                           }}));

        obj.registerMethod(obj.runtime.newJavaMethod("will return a text representation of the current stack trace", 
                                                       new JavaMethod.WithNoArguments("stackTraceAsText") {
                                                           @Override
                                                           public Object activate(IokeObject method, IokeObject context, IokeObject m, Object on) throws ControlFlow {
                                                               getArguments().checkArgumentCount(context, m, on);
                                                               Runtime runtime = context.runtime;
                                                               StringBuilder sb = new StringBuilder();

                                                               IokeObject current = IokeObject.as(on, context);
                                                               while("Locals".equals(current.getKind())) {
                                                                   IokeObject message = IokeObject.as(IokeObject.getCell(current, m, context, "currentMessage"), context);
                                                                   IokeObject start = message;
                                                                   
                                                                   while(Message.prev(start) != null && Message.prev(start).getLine() == message.getLine()) {
                                                                       start = Message.prev(start);
                                                                   }

                                                                   String s1 = Message.code(start);

                                                                   int ix = s1.indexOf("\n");
                                                                   if(ix > -1) {
                                                                       ix--;
                                                                   }

                                                                   sb.append(String.format(" %-48.48s %s\n", (ix == -1 ? s1 : s1.substring(0,ix)),"[" + message.getFile() + ":" + message.getLine() + ":" + message.getPosition()  + getContextMessageName(IokeObject.as(current.getCells().get("surroundingContext"), context)) + "]"));


                                                                   current = IokeObject.as(IokeObject.findCell(current, m, context, "surroundingContext"), context);
                                                               }

                                                               return runtime.newText(sb.toString());
                                                           }}));
    }

    public static String getContextMessageName(IokeObject ctx) throws ControlFlow {
        if("Locals".equals(ctx.getKind())) {
            return ":in `" + IokeObject.as(ctx.getCells().get("currentMessage"), ctx).getName() + "'";
        } else {
            return "";
        }
    }
}// Locals
