namespace Ioke.Lang {
    using System.Collections;
    using System.Collections.Generic;

    using Ioke.Lang.Util;

    public class Hook : IokeData {
        IList connected;

        public Hook(IList c) {
            this.connected = c;
        }

        void Rewire(IokeObject self) {
            foreach(object io in connected) {
                IokeObject oo = (IokeObject)io;
                if(oo.body.hooks == null) {
                    oo.body.hooks = new SaneList<IokeObject>();
                }
                if(!oo.body.hooks.Contains(self)) {
                    oo.body.hooks.Add(self);
                }
            }
        }

        public static void FireCellAdded(IokeObject on, IokeObject message, IokeObject context, string name) {
            List<IokeObject> hooks = on.body.hooks;
            if(hooks != null) {
                IokeObject sym = context.runtime.GetSymbol(name);
                IokeObject cellAddedMessage = context.runtime.cellAddedMessage;
                foreach(IokeObject h in hooks) {
                    Interpreter.Send(cellAddedMessage, context, h, on, sym);
                }
            }
        }

        public static void FireCellChanged(IokeObject on, IokeObject message, IokeObject context, string name, object prevValue) {
            List<IokeObject> hooks = on.body.hooks;
            if(hooks != null) {
                IokeObject sym = context.runtime.GetSymbol(name);
                IokeObject cellChangedMessage = context.runtime.cellChangedMessage;
                foreach(IokeObject h in hooks) {
                    Interpreter.Send(cellChangedMessage, context, h, on, sym, prevValue);
                }
            }
        }

        public static void FireCellRemoved(IokeObject on, IokeObject message, IokeObject context, string name, object prevValue) {
            List<IokeObject> hooks = on.body.hooks;
            if(hooks != null) {
                IokeObject sym = context.runtime.GetSymbol(name);
                IokeObject cellRemovedMessage = context.runtime.cellRemovedMessage;
                foreach(IokeObject h in hooks) {
                    Interpreter.Send(cellRemovedMessage, context, h, on, sym, prevValue);
                }
            }
        }

        public static void FireCellUndefined(IokeObject on, IokeObject message, IokeObject context, string name, object prevValue) {
            List<IokeObject> hooks = on.body.hooks;
            if(hooks != null) {
                IokeObject sym = context.runtime.GetSymbol(name);
                IokeObject cellUndefinedMessage = context.runtime.cellUndefinedMessage;
                foreach(IokeObject h in hooks) {
                    Interpreter.Send(cellUndefinedMessage, context, h, on, sym, prevValue);
                }
            }
        }

        public static void FireMimicAdded(IokeObject on, IokeObject message, IokeObject context, IokeObject newMimic) {
            List<IokeObject> hooks = on.body.hooks;
            if(hooks != null) {
                IokeObject mimicAddedMessage = context.runtime.mimicAddedMessage;
                foreach(IokeObject h in hooks) {
                    Interpreter.Send(mimicAddedMessage, context, h, on, newMimic);
                }
            }
        }

        public static void FireMimicRemoved(IokeObject on, IokeObject message, IokeObject context, object removedMimic) {
            List<IokeObject> hooks = on.body.hooks;
            if(hooks != null) {
                IokeObject mimicRemovedMessage = context.runtime.mimicRemovedMessage;
                foreach(IokeObject h in hooks) {
                    Interpreter.Send(mimicRemovedMessage, context, h, on, removedMimic);
                }
            }
        }

        public static void FireMimicsChanged(IokeObject on, IokeObject message, IokeObject context, object changedMimic) {
            List<IokeObject> hooks = on.body.hooks;
            if(hooks != null) {
                IokeObject mimicsChangedMessage = context.runtime.mimicsChangedMessage;
                foreach(IokeObject h in hooks) {
                    Interpreter.Send(mimicsChangedMessage, context, h, on, changedMimic);
                }
            }
        }

        public static void FireMimicked(IokeObject on, IokeObject message, IokeObject context, IokeObject mimickingObject) {
            List<IokeObject> hooks = on.body.hooks;
            if(hooks != null) {
                IokeObject mimickedMessage = context.runtime.mimickedMessage;
                foreach(IokeObject h in hooks) {
                    Interpreter.Send(mimickedMessage, context, h, on, mimickingObject);
                }
            }
        }

        public static void Init(Runtime runtime) {
            IokeObject obj = new IokeObject(runtime, "A hook allow you to observe what happens to a specific object. All hooks have Hook in their mimic chain.");
            obj.Kind = "Hook";
            obj.MimicsWithoutCheck(runtime.Origin);
            runtime.IokeGround.RegisterCell("Hook", obj);

            obj.RegisterMethod(runtime.NewNativeMethod("Takes one or more arguments to hook into and returns a new Hook connected to them.",
                                                       new TypeCheckingNativeMethod("into", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithRequiredPositional("firstConnected")
                                                                                    .WithRest("restConnected")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        IokeObject hook = obj.AllocateCopy(context, message);
                                                                                        hook.MimicsWithoutCheck(obj);

                                                                                        IList objs = new SaneArrayList();
                                                                                        foreach(object o in args) {
                                                                                            objs.Add(IokeObject.As(o, context));
                                                                                        }
                                                                                        Hook h = new Hook(objs);
                                                                                        hook.Data = h;
                                                                                        h.Rewire(hook);
                                                                                        return hook;
                                                                                    })));


            obj.RegisterMethod(runtime.NewNativeMethod("returns the objects this hook is connected to",
                                                       new TypeCheckingNativeMethod.WithNoArguments("connectedObjects", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        Hook h = (Hook)IokeObject.dataOf(on);
                                                                                                        IList l = new SaneArrayList(h.connected);
                                                                                                        return method.runtime.NewList(l);
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("Takes one argument and will add that to the list of connected objects",
                                                       new TypeCheckingNativeMethod("hook!", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithRequiredPositional("objectToHookInto")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        Hook h = (Hook)IokeObject.dataOf(on);
                                                                                        h.connected.Add(IokeObject.As(args[0], context));
                                                                                        h.Rewire(IokeObject.As(on, context));
                                                                                        return on;
                                                                                    })));
        }

        public override IokeData CloneData(IokeObject obj, IokeObject m, IokeObject context) {
            return new Hook(new SaneArrayList(connected));
        }
    }
}
