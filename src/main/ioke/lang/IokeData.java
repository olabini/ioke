/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.exceptions.ControlFlow;
import ioke.lang.exceptions.CantMimicOddballObject;
import ioke.lang.exceptions.NotActivatableException;
import ioke.lang.exceptions.ObjectIsNotRightType;

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
    public boolean isActivatable() {return false;}
    public IokeData cloneData(IokeObject obj, Message m, IokeObject context) {return this;}
    public IokeObject convertToNumber(IokeObject self, Message m, IokeObject context) {
        throw new ObjectIsNotRightType(m, self, "Number", context);
    }
    public IokeObject activate(IokeObject self, IokeObject context, Message message, IokeObject on) throws ControlFlow {
        throw new NotActivatableException(message, "Can't activate " + self + "#" + message.getName() + " on " + on, on, context);
    }
}// IokeData
