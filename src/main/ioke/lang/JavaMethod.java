/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

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
    }

    public String inspectName() {
        return getClass().getName();
    }

    @Override
    public String representation(IokeObject self) {
        return inspectName();
    }
}

