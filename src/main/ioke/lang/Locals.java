/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Locals {
    public static void init(IokeObject obj) {
        obj.setKind("Locals");
        obj.getMimics().clear();

        obj.setCell("=",         obj.runtime.base.getCells().get("="));
        obj.setCell("cell",      obj.runtime.base.getCells().get("cell"));
        obj.setCell("cell=",     obj.runtime.base.getCells().get("cell="));
        obj.setCell("cells",     obj.runtime.base.getCells().get("cells"));
        obj.setCell("cellNames", obj.runtime.base.getCells().get("cellNames"));

        obj.registerMethod(obj.runtime.newJavaMethod("will pass along the call to the real self object of this context.", 
                                                       new JavaMethod("pass") {
                                                           @Override
                                                           public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                                                               Object selfDelegate = IokeObject.as(on).getCells().get("self");

                                                               if(selfDelegate != null && selfDelegate != on) {
                                                                   return IokeObject.perform(selfDelegate, context, message);
                                                               }

                                                               return context.runtime.nil;
                                                           }}));
    }
}// Locals
