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

            @Override
            public void checkMimic(IokeObject obj, IokeObject m, IokeObject context) {
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

            @Override
            public String inspect(IokeObject self) {
                return "nil";
            }
        };

    public final static IokeData False = new IokeData(){
            public void init(IokeObject obj) {
                obj.setKind("false");
            }

            @Override
            public void checkMimic(IokeObject obj, IokeObject m, IokeObject context) {
                throw new CantMimicOddballObject(m, obj, context);
            }

            public boolean isTrue() {
                return false;
            }

            @Override
            public String toString(IokeObject self) {
                return "false";
            }

            @Override
            public String inspect(IokeObject self) {
                return "false";
            }
        };

    public final static IokeData True = new IokeData(){
            public void init(IokeObject obj) {
                obj.setKind("true");
            }

            @Override
            public void checkMimic(IokeObject obj, IokeObject m, IokeObject context) {
                throw new CantMimicOddballObject(m, obj, context);
            }

            @Override
            public String toString(IokeObject self) {
                return "true";
            }

            @Override
            public String inspect(IokeObject self) {
                return "true";
            }
        };


    public void init(IokeObject obj) throws ControlFlow {}
    public void checkMimic(IokeObject obj, IokeObject m, IokeObject context) {}
    public boolean isNil() {return false;}
    public boolean isTrue() {return true;}
    public boolean isMessage() {return false;}
    public boolean isSymbol() {return false;}

    public IokeObject negate(IokeObject obj) {
        return obj;
    }

    public boolean isEqualTo(IokeObject self, Object other) {
        return self == other;
    }

    public int hashCode(IokeObject self) {
        return System.identityHashCode(self);
    }

    public IokeData cloneData(IokeObject obj, IokeObject m, IokeObject context) {return this;}
    public IokeObject convertToNumber(IokeObject self, IokeObject m, IokeObject context) {
        throw new ObjectIsNotRightType(m, self, "Number", context);
    }
    public IokeObject convertToText(IokeObject self, IokeObject m, IokeObject context) {
        throw new ObjectIsNotRightType(m, self, "Text", context);
    }
    public IokeObject convertToPattern(IokeObject self, IokeObject m, IokeObject context) {
        throw new ObjectIsNotRightType(m, self, "Pattern", context);
    }
    
    private void report(Object self, IokeObject context, IokeObject message, String name) throws ControlFlow {
        IokeObject condition = IokeObject.as(IokeObject.getCellChain(context.runtime.condition, 
                                                                     message, 
                                                                     context, 
                                                                     "Error", 
                                                                     "Invocation",
                                                                     "NotActivatable")).mimic(message, context);
        condition.setCell("message", message);
        condition.setCell("context", context);
        condition.setCell("receiver", self);
        condition.setCell("methodNAme", context.runtime.getSymbol(name));
        context.runtime.errorCondition(condition);
    }

    public Object activate(IokeObject self, IokeObject context, IokeObject message, Object on) throws ControlFlow {
        report(self, context, message, "activate");
        return context.runtime.nil;
    }

    public Object getEvaluatedArgument(IokeObject message, int index, IokeObject context) throws ControlFlow {
        report(context, context, message, "getEvaluatedArgument(" + index + ")");
        return context.runtime.nil;
    }

    public List<Object> getEvaluatedArguments(IokeObject message, IokeObject context) throws ControlFlow {
        report(context, context, message, "getEvaluatedArguments");
        return null;
    }

    public Object sendTo(IokeObject message, IokeObject context, Object recv) throws ControlFlow {
        report(recv, context, message, "sendTo");
        return context.runtime.nil;
    }

    public Object sendTo(IokeObject message, IokeObject context, Object recv, Object argument) throws ControlFlow {
        report(recv, context, message, "sendTo/1");
        return context.runtime.nil;
    }

    public Object sendTo(IokeObject message, IokeObject context, Object recv, Object arg1, Object arg2) throws ControlFlow {
        report(recv, context, message, "sendTo/2");
        return context.runtime.nil;
    }

    public Object sendTo(IokeObject message, IokeObject context, Object recv, List<Object> args) throws ControlFlow {
        report(recv, context, message, "sendTo/n");
        return context.runtime.nil;
    }

    public Object evaluateComplete(IokeObject message) throws ControlFlow {
        report(message, message, message, "evaluateComplete");
        return message.runtime.nil;
    }

    public Object evaluateCompleteWith(IokeObject message, IokeObject ctx, Object ground) throws ControlFlow {
        report(ground, ctx, message, "evaluateCompleteWith");
        return ctx.runtime.nil;
    }

    public Object evaluateCompleteWithReceiver(IokeObject message, IokeObject ctx, Object ground, Object receiver) throws ControlFlow {
        report(receiver, ctx, message, "evaluateCompleteWithReceiver");
        return ctx.runtime.nil;
    }

    public Object evaluateCompleteWithoutExplicitReceiver(IokeObject message, IokeObject ctx, Object ground) throws ControlFlow {
        report(ground, ctx, message, "evaluateCompleteWithoutExplicitReceiver");
        return ctx.runtime.nil;
    }

    public Object evaluateCompleteWith(IokeObject message, Object ground) throws ControlFlow {
        report(ground, IokeObject.as(ground), message, "evaluateCompleteWith");
        return message.runtime.nil;
    }

    public List<Object> getArguments(IokeObject self) throws ControlFlow {
        report(self, self, self, "getArguments");
        return null;
    }

    public int getArgumentCount(IokeObject self) throws ControlFlow {
        report(self, self, self, "getArgumentCount");
        return -1;
    }

    public String getName(IokeObject self) throws ControlFlow {
        report(self, self, self, "getName");
        return null;
    }

    public String getFile(IokeObject self) throws ControlFlow {
        report(self, self, self, "getFile");
        return null;
    }

    public int getLine(IokeObject self) throws ControlFlow {
        report(self, self, self, "getLine");
        return -1;
    }

    public int getPosition(IokeObject self) throws ControlFlow {
        report(self, self, self, "getPosition");
        return -1;
    }

    public String toString(IokeObject self) {
        Object obj = self.findCell(null, null, "kind");
        int h = hashCode(self);
        String hash = Integer.toHexString(h).toUpperCase();
        if(obj instanceof NullObject) {
            return "#<???:" + hash + ">";
        }

        String kind = ((Text)IokeObject.data(obj)).getText();
        return "#<" + kind + ":" + hash + ">";
    }

    public String inspect(IokeObject self) {
        return null;
    }
}// IokeData
