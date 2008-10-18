/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.List;

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

            public IokeData cloneData(IokeObject obj, IokeObject m, IokeObject context) {
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

            public IokeData cloneData(IokeObject obj, IokeObject m, IokeObject context) {
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

            public IokeData cloneData(IokeObject obj, IokeObject m, IokeObject context) {
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
    public boolean isMessage() {return false;}
    public IokeData cloneData(IokeObject obj, IokeObject m, IokeObject context) {return this;}
    public IokeObject convertToNumber(IokeObject self, IokeObject m, IokeObject context) {
        throw new ObjectIsNotRightType(m, self, "Number", context);
    }
    public IokeObject activate(IokeObject self, IokeObject context, IokeObject message, IokeObject on) throws ControlFlow {
        throw new NotActivatableException(message, "Can't activate " + self + "#" + message.getName() + " on " + on, on, context);
    }

    public IokeObject getEvaluatedArgument(IokeObject message, int index, IokeObject context) throws ControlFlow {
        throw new NotActivatableException(message, "Can't getEvaluatedArgument from " + message, context, context);
    }

    public IokeObject sendTo(IokeObject message, IokeObject context, IokeObject recv) throws ControlFlow {
        throw new NotActivatableException(message, "Can't sendTo on " + message, recv, context);
    }

    public IokeObject sendTo(IokeObject message, IokeObject context, IokeObject recv, IokeObject argument) throws ControlFlow {
        throw new NotActivatableException(message, "Can't sendTo on " + message, recv, context);
    }

    public IokeObject sendTo(IokeObject message, IokeObject context, IokeObject recv, IokeObject arg1, IokeObject arg2) throws ControlFlow {
        throw new NotActivatableException(message, "Can't sendTo on " + message, recv, context);
    }

    public IokeObject evaluateComplete(IokeObject message) throws ControlFlow {
        throw new NotActivatableException(message, "Can't evaluateComplete on " + message, message, message);
    }

    public IokeObject evaluateCompleteWith(IokeObject message, IokeObject ctx, IokeObject ground) throws ControlFlow {
        throw new NotActivatableException(message, "Can't evaluateCompleteWith on " + message, ground, ctx);
    }

    public IokeObject evaluateCompleteWithoutExplicitReceiver(IokeObject message, IokeObject ctx, IokeObject ground) throws ControlFlow {
        throw new NotActivatableException(message, "Can't evaluateCompleteWithoutExplicitReceiver on " + message, ground, ctx);
    }

    public IokeObject evaluateCompleteWith(IokeObject message, IokeObject ground) throws ControlFlow {
        throw new NotActivatableException(message, "Can't evaluateCompleteWith on " + message, ground, ground);
    }

    public List<Object> getArguments(IokeObject self) {
        throw new NotActivatableException(self, "Can't get arguments from " + self, self, self);
    }

    public int getArgumentCount(IokeObject self) {
        throw new NotActivatableException(self, "Can't get argument count from " + self, self, self);
    }

    public String getName(IokeObject self) {
        throw new NotActivatableException(self, "Can't get message name from " + self, self, self);
    }

    public String getFile(IokeObject self) {
        throw new NotActivatableException(self, "Can't get filename from " + self, self, self);
    }

    public int getLine(IokeObject self) {
        throw new NotActivatableException(self, "Can't get line from " + self, self, self);
    }

    public int getPosition(IokeObject self) {
        throw new NotActivatableException(self, "Can't get position from " + self, self, self);
    }
}// IokeData
