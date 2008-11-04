/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Call extends IokeData {
    public Call() {
    }

    @Override
    public void init(IokeObject obj) {
        final Runtime runtime = obj.runtime;

        obj.setKind("Call");
    }

    public IokeData cloneData(IokeObject obj, IokeObject m, IokeObject context) {
        return new Call();
    }
}// Call
