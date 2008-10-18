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

            @Override
            public String toString(IokeObject self) {
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

            @Override
            public String toString(IokeObject self) {
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

            @Override
            public String toString(IokeObject self) {
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
    public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
        throw new NotActivatableException(message, "Can't activate " + self + "#" + message.getName() + " on " + on, on, context);
    }

    public Object getEvaluatedArgument(IokeObject message, int index, IokeObject context) throws ControlFlow {
        throw new NotActivatableException(message, "Can't getEvaluatedArgument from " + message, context, context);
    }

    public Object sendTo(IokeObject message, IokeObject context, Object recv) throws ControlFlow {
        throw new NotActivatableException(message, "Can't sendTo on " + message, recv, context);
    }

    public Object sendTo(IokeObject message, IokeObject context, Object recv, Object argument) throws ControlFlow {
        throw new NotActivatableException(message, "Can't sendTo on " + message, recv, context);
    }

    public Object sendTo(IokeObject message, IokeObject context, Object recv, Object arg1, Object arg2) throws ControlFlow {
        throw new NotActivatableException(message, "Can't sendTo on " + message, recv, context);
    }

    public Object evaluateComplete(IokeObject message) throws ControlFlow {
        throw new NotActivatableException(message, "Can't evaluateComplete on " + message, message, message);
    }

    public Object evaluateCompleteWith(IokeObject message, IokeObject ctx, Object ground) throws ControlFlow {
        throw new NotActivatableException(message, "Can't evaluateCompleteWith on " + message, ground, ctx);
    }

    public Object evaluateCompleteWithoutExplicitReceiver(IokeObject message, IokeObject ctx, Object ground) throws ControlFlow {
        throw new NotActivatableException(message, "Can't evaluateCompleteWithoutExplicitReceiver on " + message, ground, ctx);
    }

    public Object evaluateCompleteWith(IokeObject message, Object ground) throws ControlFlow {
        throw new NotActivatableException(message, "Can't evaluateCompleteWith on " + message, ground, null);
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

    public String toString(IokeObject self) {
        Object obj = self.findCell(null, null, "kind");
        int h = System.identityHashCode(self);
        String hash = Integer.toHexString(h).toUpperCase();
        if(obj instanceof NullObject) {
            return "#<???:" + hash + ">";
        }

        String kind = ((Text)IokeObject.data(obj)).getText();
        return "#<" + kind + ":" + hash + ">";
    }
}// IokeData
