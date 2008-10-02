/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class JavaMethod extends Method {
    public JavaMethod(Runtime runtime, String name, String documentation) {
        super(runtime, name, documentation);
        if(null != runtime.javaMethod) {
            this.mimics(runtime.javaMethod);
        }
    }

    public void init() {
    }

    public String toString() {
        if(this == runtime.javaMethod) {
            return "JavaMethod-origin";
        }
        return "JavaMethod<" + name + ">";
    }
}

