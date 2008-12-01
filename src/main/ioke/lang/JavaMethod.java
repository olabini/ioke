/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.ArrayList;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class JavaMethod extends Method {
    public JavaMethod(String name) {
        super(name);
    }

    @Override
    public void init(IokeObject javaMethod) {
        javaMethod.setKind("JavaMethod");
        javaMethod.registerMethod(javaMethod.runtime.newJavaMethod("returns a list of the keywords this method takes", new JavaMethod("keywords") {
                @Override
                public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) {
                    return context.runtime.newList(new ArrayList<Object>());
                }
            }));
    }


    private String getDominantClassName() {
        String name = getClass().getName();
        int dollar = name.indexOf("$");
        int dot = name.lastIndexOf(".");
        if(dollar == -1) {
            dollar = name.length();
        }
        return name.substring(dot+1, dollar);
    }

    @Override
    public String inspect(Object self) {
        return "method(" + getDominantClassName() + ((name != null) ? ("_" + name) : "") + ")";
    }
}

