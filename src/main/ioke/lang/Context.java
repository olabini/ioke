/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Context extends IokeObject {
    IokeObject ground;

    public Context(Runtime runtime, IokeObject ground) {
        super(runtime);
        this.ground = ground;
    }
}// Context
