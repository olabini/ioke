/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.exceptions.CantMimicOddballObject;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public abstract class IokeData {
    public final static IokeData None = new IokeData(){};

    public final static IokeData Nil = new IokeData(){
            public void init(IokeObject obj) {
                obj.setKind("nil");
            }

            public IokeData cloneData(IokeObject obj, Message m, IokeObject context) {
                throw new CantMimicOddballObject(m, obj, context);
            }

            public boolean isNil() {
                return true;
            }

            public boolean isTrue() {
                return false;
            }

            public String toString() {
                return "nil";
            }
        };

    public final static IokeData False = new IokeData(){
            public void init(IokeObject obj) {
                obj.setKind("false");
            }

            public IokeData cloneData(IokeObject obj, Message m, IokeObject context) {
                throw new CantMimicOddballObject(m, obj, context);
            }

            public boolean isTrue() {
                return false;
            }

            public String toString() {
                return "false";
            }
        };

    public final static IokeData True = new IokeData(){
            public void init(IokeObject obj) {
                obj.setKind("true");
            }

            public IokeData cloneData(IokeObject obj, Message m, IokeObject context) {
                throw new CantMimicOddballObject(m, obj, context);
            }

            public String toString() {
                return "true";
            }
        };

    public void init(IokeObject obj) {}
    public boolean isNil() {return false;}
    public boolean isTrue() {return true;}
    public IokeData cloneData(IokeObject obj, Message m, IokeObject context) {return this;}
}// IokeData
