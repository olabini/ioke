/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.test;

import ioke.lang.IokeObject;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Constructors2 {
    private Object data;

    public Constructors2(Test1 obj) {
        this.data = "Constructor(Test1)";
    }

    public Constructors2(Test2 obj) {
        this.data = "Constructor(Test2)";
    }

    public Constructors2(IokeObject obj) {
        this.data = obj;
    }

    public Object getData() {
        return data;
    }
}// Constructors2
