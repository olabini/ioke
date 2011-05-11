
namespace Ioke.Lang {
    using System.Collections;
    using System.Collections.Generic;

    using Ioke.Lang.Util;

    public class IokeObject : ITypeChecker {
        public Runtime runtime;
        public IokeData data;
        internal Body body = new Body();

        public static readonly int FALSY_F = 1 << 0;
        public static readonly int NIL_F = 1 << 1;
        public static readonly int FROZEN_F = 1 << 2;
        public static readonly int ACTIVATABLE_F = 1 << 3;
        public static readonly int HAS_ACTIVATABLE_F = 1 << 4;
        public static readonly int LEXICAL_F = 1 << 5;

        public bool IsNil {
            get {
                return (body.flags & NIL_F) != 0;
            }
        }

        public bool IsTrue {
            get {
                return (body.flags & FALSY_F) == 0;
            }
        }

        public void SetFrozen(bool frozen) {
            if (frozen) {
                body.flags |= FROZEN_F;
            } else {
                body.flags &= ~FROZEN_F;
            }
        }

        public bool IsActivatable {
            get {
                return (body.flags & ACTIVATABLE_F) != 0;
            }
        }

        public bool IsFrozen {
            get {
                return (body.flags & FROZEN_F) != 0;
            }
        }

        public bool IsSetActivatable {
            get {
                return (body.flags & HAS_ACTIVATABLE_F) != 0;
            }
        }

        public void SetActivatable(bool activatable) {
            body.flags |= HAS_ACTIVATABLE_F;
            if (activatable) {
                body.flags |= ACTIVATABLE_F;
            } else {
                body.flags &= ~ACTIVATABLE_F;
            }
        }

        public bool IsLexical {
            get {
                return (body.flags & LEXICAL_F) != 0;
            }
        }

        public IokeObject(Runtime runtime, string documentation) : this(runtime, documentation, IokeData.None) {
        }

        public IokeObject(Runtime runtime, string documentation, IokeData data) {
            this.runtime = runtime;
            this.body.documentation = documentation;
            this.data = data;
        }

        public IokeData Data {
            get { return data; }
            set { this.data = value; }
        }

        public string Documentation {
            get { return body.documentation; }
            set { this.body.documentation = value; }
        }

        private bool ContainsMimic(IokeObject obj) {
            if(body.mimicCount == 1) {
                return obj == body.mimic;
            }

            if(body.mimic != null) {
                return body.mimic == obj;
            } else {
                for(int i = 0; i < body.mimicCount; i++) {
                    if(body.mimics[i] == obj) {
                        return true;
                    }
                }
            }
            return false;
        }

        public static IList<IokeObject> GetMimics(object on, IokeObject context) {
            return As(on, context).GetMimics();
        }

        public IList<IokeObject> GetMimics() {
            var result = new SaneList<IokeObject>();
            switch(body.mimicCount) {
            case 0:
                break;
            case 1:
                result.Add(body.mimic);
                break;
            default:
                for(int i=0; i<body.mimicCount; i++) {
                    result.Add(body.mimics[i]);
                }
                break;
            }
            return result;
        }

        public IokeObject AllocateCopy(IokeObject m, IokeObject context) {
            return new IokeObject(runtime, null, data.CloneData(this, m, context));
        }


        public void SingleMimicsWithoutCheck(IokeObject mimic) {
            body.mimic = mimic;
            body.mimicCount = 1;
            TransplantActivation(mimic);
        }

        private void AddMimic(IokeObject mimic) {
            AddMimic(body.mimicCount, mimic);
        }

        private void AddMimic(int at, IokeObject mimic) {
            switch(body.mimicCount) {
            case 0:
                body.mimic = mimic;
                body.mimicCount = 1;
                break;
            case 1:
                if(at == 0) {
                    body.mimics = new IokeObject[]{mimic, body.mimic};
                } else {
                    body.mimics = new IokeObject[]{body.mimic, mimic};
                }
                body.mimicCount = 2;
                body.mimic = null;
                break;
            default:
                if(at == 0) {
                    int newLen = body.mimicCount + 1;
                    IokeObject[] newMimics;
                    if(body.mimics.Length < newLen) {
                        newMimics = new IokeObject[newLen];
                    } else {
                        newMimics = body.mimics;
                    }
                    System.Array.Copy(body.mimics, 0, newMimics, 1, newLen - 1);
                    body.mimics = newMimics;
                    newMimics[0] = mimic;
                    body.mimicCount++;
                } else if(at == body.mimicCount) {
                    if(body.mimicCount == body.mimics.Length) {
                        IokeObject[] newMimics = new IokeObject[body.mimics.Length + 1];
                        System.Array.Copy(body.mimics, 0, newMimics, 0, body.mimics.Length);
                        body.mimics = newMimics;
                    }
                    body.mimics[body.mimicCount++] = mimic;
                } else {
                    if(body.mimicCount == body.mimics.Length) {
                        IokeObject[] newMimics = new IokeObject[body.mimics.Length + 1];
                        System.Array.Copy(body.mimics, 0, newMimics, 0, at);
                        System.Array.Copy(body.mimics, at, newMimics, at+1, body.mimicCount - at);
                        body.mimics = newMimics;
                        body.mimics[at] = mimic;
                    } else {
                        System.Array.Copy(body.mimics, at, body.mimics, at + 1, body.mimicCount - at);
                        body.mimics[at] = mimic;
                    }
                    body.mimicCount++;
                }
                break;
            }
        }

        public void MimicsWithoutCheck(IokeObject mimic) {
            if(!ContainsMimic(mimic)) {
                AddMimic(mimic);
                TransplantActivation(mimic);
            }
        }

        public void MimicsWithoutCheck(int index, IokeObject mimic) {
            if(!ContainsMimic(mimic)) {
                AddMimic(index, mimic);
                TransplantActivation(mimic);
            }
        }

        private void CheckFrozen(string modification, IokeObject message, IokeObject context) {
            if(IsFrozen) {
                IokeObject condition = As(IokeObject.GetCellChain(context.runtime.Condition,
                                                                  message,
                                                                  context,
                                                                  "Error",
                                                                  "ModifyOnFrozen"), context).Mimic(message, context);
                condition.SetCell("message", message);
                condition.SetCell("context", context);
                condition.SetCell("receiver", this);
                condition.SetCell("modification", context.runtime.GetSymbol(modification));
                context.runtime.ErrorCondition(condition);
            }
        }

        public static bool Same(object one, object two) {
            if((one is IokeObject) && (two is IokeObject)) {
                return object.ReferenceEquals(As(one, null).body, As(two, null).body);
            } else {
                return object.ReferenceEquals(one, two);
            }
        }

        public void Become(IokeObject other, IokeObject message, IokeObject context) {
            CheckFrozen("become!", message, context);

            this.runtime = other.runtime;
            this.data = other.data;
            this.body = other.body;
        }








        private int MimicIndex(object other) {
            if(body.mimicCount == 1) {
                return body.mimic == other ? -2 : -1;
            }

            for(int i = 0; i < body.mimicCount; i++) {
                if(body.mimics[i] == other) {
                    return i;
                }
            }
            return -1;
        }

        private void RemoveMimicAt(int index) {
            switch(index) {
            case -2:
                body.mimic = null;
                body.mimicCount--;
                break;
            case 0:
                if(body.mimicCount-- == 2) {
                    body.mimic = body.mimics[1];
                    body.mimics = null;
                } else {
                    IokeObject[] newMimics = new IokeObject[body.mimicCount];
                    System.Array.Copy(body.mimics, 1, newMimics, 0, body.mimicCount);
                    body.mimics = newMimics;
                }
                break;
            default:
                if(index == body.mimicCount - 1) {
                    if(body.mimicCount-- == 2) {
                        body.mimic = body.mimics[0];
                        body.mimics = null;
                    } else {
                        body.mimics[index] = null;
                    }
                } else {
                    IokeObject[] newMimics = new IokeObject[body.mimicCount];
                    System.Array.Copy(body.mimics, 0, newMimics, 0, index);
                    System.Array.Copy(body.mimics, index + 1, newMimics, index, body.mimicCount - (index + 1));
                    body.mimics = newMimics;
                    body.mimicCount--;
                }
                break;
            }
        }

        public static void RemoveMimic(object on, object other, IokeObject message, IokeObject context) {
            IokeObject me = As(on, context);
            me.CheckFrozen("removeMimic!", message, context);
            int ix = me.MimicIndex(other);
            if(ix != -1) {
                me.RemoveMimicAt(ix);
                if(me.body.hooks != null) {
                    Hook.FireMimicsChanged(me, message, context, other);
                    Hook.FireMimicRemoved(me, message, context, other);
                }
            }
        }

        public static void RemoveAllMimics(object on, IokeObject message, IokeObject context) {
            IokeObject me = As(on, context);
            me.CheckFrozen("removeAllMimics!", message, context);

            if(me.body.mimicCount == 1) {
                Hook.FireMimicsChanged(me, message, context, me.body.mimic);
                Hook.FireMimicRemoved(me, message, context, me.body.mimic);
                me.body.mimicCount--;
            } else {
                while(me.body.mimicCount > 0) {
                    Hook.FireMimicsChanged(me, message, context, me.body.mimics[me.body.mimicCount-1]);
                    Hook.FireMimicRemoved(me, message, context, me.body.mimics[me.body.mimicCount-1]);
                    me.body.mimicCount--;
                }
            }

            me.body.mimic = null;
            me.body.mimics = null;
        }


        public static void Freeze(object on) {
            if(on is IokeObject) {
                As(on,null).SetFrozen(true);
            }
        }

        public static void Thaw(object on) {
            if(on is IokeObject) {
                As(on, null).SetFrozen(false);
            }
        }

        public static IokeData dataOf(object on) {
            return ((IokeObject)on).data;
        }

        public void SetDocumentation(string docs, IokeObject message, IokeObject context) {
            CheckFrozen("documentation=", message, context);

            this.body.documentation = docs;
        }


















        public static object FindSuperCellOn(object obj, IokeObject early, IokeObject context, string name) {
            return As(obj, context).MarkingFindSuperCell(early, name, new bool[]{false});
        }

        protected object RealMarkingFindSuperCell(IokeObject early, string name, bool[] found) {
            if(body.Has(name)) {
                if(found[0]) {
                    return body.Get(name);
                }
                if(early == body.Get(name)) {
                    found[0] = true;
                }
            }
        
            if(body.mimicCount == 1) {
                return body.mimic.MarkingFindSuperCell(early, name, found);
            } else {
                for(int i = 0; i<body.mimicCount; i++) {
                    object cell = body.mimics[i].MarkingFindSuperCell(early, name, found);
                    if(cell != runtime.nul) {
                        return cell;
                    }
                }
                return runtime.nul;
            }
        }

        protected object MarkingFindSuperCell(IokeObject early, string name, bool[] found) {
            object nn = RealMarkingFindSuperCell(early, name, found);
            if(nn == runtime.nul && IsLexical) {
                return ((LexicalContext)this.data).surroundingContext.RealMarkingFindSuperCell(early, name, new bool[]{false});
            }
            return nn;
        }

        public static object FindPlace(object obj, string name) {
            return As(obj, null).MarkingFindPlace(name);
        }

        public static object FindPlace(object obj, IokeObject m, IokeObject context, string name) {
            object result = FindPlace(obj, name);
            if(result == m.runtime.nul) {
                IokeObject condition = As(IokeObject.GetCellChain(m.runtime.Condition,
                                                                  m,
                                                                  context,
                                                                  "Error",
                                                                  "NoSuchCell"), context).Mimic(m, context);
                condition.SetCell("message", m);
                condition.SetCell("context", context);
                condition.SetCell("receiver", obj);
                condition.SetCell("cellName", m.runtime.GetSymbol(name));

                m.runtime.WithReturningRestart("ignore", context, () => {condition.runtime.ErrorCondition(condition);});
            }
            return result;
        }

        public object FindPlace(string name) {
            return MarkingFindPlace(name);
        }

        protected object MarkingFindPlace(string name) {
            if(body.Has(name)) {
                if(body.Get(name) == runtime.nul) {
                    if(IsLexical) {
                        return IokeObject.FindPlace(((LexicalContext)this.data).surroundingContext, name);
                    }
                    return runtime.nul;
                }
                return this;
            } else {
                if(body.mimic != null) {
                    object place = body.mimic.MarkingFindPlace(name);
                    if(place != runtime.nul) {
                        return place;
                    }
                } else {
                    for(int i = 0; i<body.mimicCount; i++) {
                        object place = body.mimics[i].MarkingFindPlace(name);
                        if(place != runtime.nul) {
                            return place;
                        }
                    }
                }
                
                if(IsLexical) {
                    return IokeObject.FindPlace(((LexicalContext)this.data).surroundingContext, name);
                }
                return runtime.nul;
            }
        }

        public static object FindCell(IokeObject on, string name) {
            object cell;
            IokeObject nul = on.runtime.nul;
            IokeObject c = on;

            while(true) {
                Body b = c.body;
                if((cell = b.Get(name)) != null) {
                    if(cell == nul && c.IsLexical) {
                        c = ((LexicalContext)c.data).surroundingContext;
                    } else {
                        return cell;
                    }
                } else {
                    if(b.mimic != null) {
                        if(c.IsLexical) {
                            if((cell = FindCell(b.mimic, name)) != nul) {
                                return cell;
                            }
                            c = ((LexicalContext)c.data).surroundingContext;
                        } else {
                            c = b.mimic;
                        }
                    } else {
                        for(int i = 0; i<b.mimicCount; i++) {
                            if((cell = FindCell(b.mimics[i], name)) != nul) {
                                return cell;
                            }
                        }
                        if(c.IsLexical) {
                            c = ((LexicalContext)c.data).surroundingContext;
                        } else {
                            return nul;
                        }
                    }
                }
            }
        }

        public static void RemoveCell(object on, IokeObject m, IokeObject context, string name) {
            ((IokeObject)on).RemoveCell(m, context, name);
        }

        public static void UndefineCell(object on, IokeObject m, IokeObject context, string name) {
            ((IokeObject)on).UndefineCell(m, context, name);
        }

        public void RemoveCell(IokeObject m, IokeObject context, string name) {
            CheckFrozen("removeCell!", m, context);
            if(body.Has(name)) {
                object prev = body.Remove(name);
                if(body.hooks != null) {
                    Hook.FireCellChanged(this, m, context, name, prev);
                    Hook.FireCellRemoved(this, m, context, name, prev);
                }
            } else {
                IokeObject condition = As(IokeObject.GetCellChain(runtime.Condition,
                                                                  m,
                                                                  context,
                                                                  "Error",
                                                                  "NoSuchCell"), context).Mimic(m, context);
                condition.SetCell("message", m);
                condition.SetCell("context", context);
                condition.SetCell("receiver", this);
                condition.SetCell("cellName", runtime.GetSymbol(name));

                runtime.WithReturningRestart("ignore", context, ()=>{runtime.ErrorCondition(condition);});
            }
        }

        public void UndefineCell(IokeObject m, IokeObject context, string name) {
            CheckFrozen("undefineCell!", m, context);
            object prev = runtime.nil;
            if(body.Has(name)) {
                prev = body.Get(name);
            }
            body.Put(name, runtime.nul);
            if(body.hooks != null) {
                if(prev == null) {
                    prev = runtime.nil;
                }
                Hook.FireCellChanged(this, m, context, name, prev);
                Hook.FireCellUndefined(this, m, context, name, prev);
            }
        }


        public void RegisterMethod(IokeObject m) {
            body.Put(((Method)m.data).Name, m);
        }

        public void AliasMethod(string originalName, string newName, IokeObject message, IokeObject context) {
            CheckFrozen("aliasMethod", message, context);

            IokeObject io = As(FindCell(this, originalName), context);
            IokeObject newObj = io.Mimic(null, null);
            newObj.data = new AliasMethod(newName, io.data, io);
            body.Put(newName, newObj);
        }

        public void RegisterCell(string name, object o) {
            body.Put(name, o);
        }

        public static void Assign(object on, string name, object value, IokeObject context, IokeObject message) {
            As(on, context).Assign(name, value, context, message);
        }

        public readonly static System.Text.RegularExpressions.Regex SLIGHTLY_BAD_CHARS = new System.Text.RegularExpressions.Regex("[!=\\.\\-\\+&|\\{\\[]");
        public void Assign(string name, object value, IokeObject context, IokeObject message) {
            if(IsLexical) {
                object place = FindPlace(name);
                if(place == runtime.nul) {
                    place = this;
                }
                IokeObject.SetCell(place, name, value, context);
            } else {
                CheckFrozen("=", message, context);

                if(!SLIGHTLY_BAD_CHARS.Match(name).Success && FindCell(this, name + "=") != runtime.nul) {
                    IokeObject msg = runtime.CreateMessage(new Message(runtime, name + "=", runtime.CreateMessage(Message.Wrap(As(value, context)))));
                    Interpreter.Send(msg, context, this);
                } else {
                    if(body.hooks != null) {
                        bool contains = body.Has(name);
                        object prev = runtime.nil;
                        if(contains) {
                            prev = body.Get(name);
                        }
                        body.Put(name, value);
                        if(!contains) {
                            Hook.FireCellAdded(this, message, context, name);
                        }
                        Hook.FireCellChanged(this, message, context, name, prev);
                    } else {
                        body.Put(name, value);
                    }
                }
            }
        }

        public static object GetCell(object on, IokeObject m, IokeObject context, string name) {
            return ((IokeObject)on).GetCell(m, context, name);
        }

        public object Self {
            get {
                if(IsLexical) {
                    return ((LexicalContext)this.data).surroundingContext.Self;
                } else {
                    return this.body.Get("self");
                }
            }
        }

        public object GetCell(IokeObject m, IokeObject context, string name) {
            object cell = FindCell(this, name);

            while(cell == runtime.nul) {
                IokeObject condition = As(IokeObject.GetCellChain(runtime.Condition,
                                                                  m,
                                                                  context,
                                                                  "Error",
                                                                  "NoSuchCell"), context).Mimic(m, context);
                condition.SetCell("message", m);
                condition.SetCell("context", context);
                condition.SetCell("receiver", this);
                condition.SetCell("cellName", runtime.GetSymbol(name));

                object[] newCell = new object[]{cell};

                runtime.WithRestartReturningArguments(()=>{runtime.ErrorCondition(condition);}, context,
                                                      new UseValue(name, newCell),
                                                      new StoreValue(name, newCell, this));
                cell = newCell[0];
            }

            return cell;
        }

        public static void SetCell(object on, string name, object value, IokeObject context) {
            As(on, context).SetCell(name, value);
        }

        public static object SetCell(object on, IokeObject m, IokeObject context, string name, object value) {
            ((IokeObject)on).SetCell(name, value);
            return value;
        }

        public void SetCell(string name, object o) {
            body.Put(name, o);
        }

        public string Kind {
            set { body.Put("kind", runtime.NewText(value)); }
        }

        public static object GetRealContext(object o) {
            if(o is IokeObject) {
                return As(o, null).RealContext;
            }
            return o;
        }

        public object RealContext {
            get {             
                if(IsLexical) {
                    return ((LexicalContext)this.data).ground;
                } else {
                    return this;
                }
            }
        }

        public virtual void Init() {
            data.Init(this);
        }

        public IList Arguments {
            get { return data.Arguments(this); }
        }

        public string Name {
            get { return data.GetName(this); }
        }

        public string File {
            get { return data.GetFile(this); }
        }

        public int Line {
            get { return data.GetLine(this); }
        }

        public int Position {
            get { return data.GetPosition(this); }
        }

        public override string ToString() {
            return data.ToString(this);
        }

        public static IokeObject As(object on, IokeObject context) {
            if(on is IokeObject) {
                return ((IokeObject)on);
            } else {
                throw new System.Exception("Can't handle non-IokeObjects right now");
            }
        }

        private void TransplantActivation(IokeObject mimic) {
            if(!this.IsSetActivatable && mimic.IsSetActivatable) {
                this.SetActivatable(mimic.IsActivatable);
            }
        }

        public void SingleMimics(IokeObject mimic, IokeObject message, IokeObject context) {
            CheckFrozen("mimic!", message, context);

            mimic.data.CheckMimic(mimic, message, context);
            body.mimic = mimic;
            body.mimicCount = 1;
            TransplantActivation(mimic);
            if(mimic.body.hooks != null) {
                Hook.FireMimicked(mimic, message, context, this);
            }
            if(body.hooks != null) {
                Hook.FireMimicsChanged(this, message, context, mimic);
                Hook.FireMimicAdded(this, message, context, mimic);
            }
        }

        public void Mimics(IokeObject mimic, IokeObject message, IokeObject context) {
            CheckFrozen("mimic!", message, context);

            mimic.data.CheckMimic(mimic, message, context);
            if(!ContainsMimic(mimic)) {
                AddMimic(mimic);
                TransplantActivation(mimic);
                if(mimic.body.hooks != null) {
                    Hook.FireMimicked(mimic, message, context, this);
                }
                if(body.hooks != null) {
                    Hook.FireMimicsChanged(this, message, context, mimic);
                    Hook.FireMimicAdded(this, message, context, mimic);
                }
            }
        }

        public void Mimics(int index, IokeObject mimic, IokeObject message, IokeObject context) {
            CheckFrozen("prependMimic!", message, context);

            mimic.data.CheckMimic(mimic, message, context);
            if(!ContainsMimic(mimic)) {
                AddMimic(index, mimic);
                TransplantActivation(mimic);
                if(mimic.body.hooks != null) {
                    Hook.FireMimicked(mimic, message, context, this);
                }
                if(body.hooks != null) {
                    Hook.FireMimicsChanged(this, message, context, mimic);
                    Hook.FireMimicAdded(this, message, context, mimic);
                }
            }
        }

        public static IokeObject Mimic(object on, IokeObject message, IokeObject context) {
            return As(on, context).Mimic(message, context);
        }

        public IokeObject Mimic(IokeObject message, IokeObject context) {
            CheckFrozen("mimic!", message, context);

            IokeObject clone = AllocateCopy(message, context);
            clone.SingleMimics(this, message, context);
            return clone;
        }

        public virtual bool IsSymbol {
            get { return data.IsSymbol; }
        }

        public virtual bool IsMessage {
            get { return data.IsMessage; }
        }

        public static bool IsObjectMessage(object obj) {
            return (obj is IokeObject) && As(obj, null).IsMessage;
        }

        public static bool IsObjectTrue(object on) {
            return !(on is IokeObject) || As(on, null).IsTrue;
        }

        public string GetKind(IokeObject message, IokeObject context) {
            object obj = FindCell(this, "kind");
            if(IokeObject.dataOf(obj) is Text) {
                return ((Text)IokeObject.dataOf(obj)).GetText();
            } else {
                return ((Text)IokeObject.dataOf(Interpreter.GetOrActivate(obj, context, message, this))).GetText();
            }
        }

        public string GetKind() {
            object obj = FindCell(this, "kind");
            if(obj != null && IokeObject.dataOf(obj) is Text) {
                return ((Text)IokeObject.dataOf(obj)).GetText();
            } else {
                return null;
            }
        }

        public bool HasKind {
            get { return body.Has("kind"); }
        }

        public class UseValue : Restart.ArgumentGivingRestart {
            string variableName;
            object[] place;
            public UseValue(string variableName, object[] place) : base("useValue") {
                this.variableName = variableName;
                this.place = place;
            }

            public override string Report() {
                return "Use value for: " + variableName;
            }

            public override IList<string> ArgumentNames {
                get { return new SaneList<string>() {"newValue"}; }
            }

            public override IokeObject Invoke(IokeObject context, IList arguments) {
                place[0] = arguments[0];
                return context.runtime.nil;
            }
        }

        public class StoreValue : Restart.ArgumentGivingRestart {
            string variableName;
            object[] place;
            IokeObject obj;
            public StoreValue(string variableName, object[] place, IokeObject obj) : base("useValue") {
                this.variableName = variableName;
                this.place = place;
                this.obj = obj;
            }

            public override string Report() {
                return "Store value for: " + variableName;
            }

            public override IList<string> ArgumentNames {
                get { return new SaneList<string>() {"newValue"}; }
            }

            public override IokeObject Invoke(IokeObject context, IList arguments) {
                place[0] = arguments[0];
                obj.SetCell(name, place[0]);
                return context.runtime.nil;
            }
        }

        public static object GetCellChain(object on, IokeObject m, IokeObject c, params string[] names) {
            object current = on;
            foreach(string name in names) {
                current = GetCell(current, m, c, name);
            }
            return current;
        }

        public static bool IsKind(object on, string kind, IokeObject context) {
            return As(on, context).IsKind(kind);
        }

        public static bool IsMimic(object on, IokeObject potentialMimic, IokeObject context) {
            return As(on, context).IsMimic(potentialMimic);
        }

        public static bool IsKind(IokeObject on, string kind) {
            return As(on, on).IsKind(kind);
        }

        public static bool IsMimic(IokeObject on, IokeObject potentialMimic) {
            return As(on, on).IsMimic(potentialMimic);
        }

        private bool IsKind(string kind) {
            if(body.Has("kind") && kind.Equals(Text.GetText(body.Get("kind")))) {
                return true;
            }

            if(body.mimic != null) {
                return body.mimic.IsKind(kind);
            } else {
                for(int i = 0; i<body.mimicCount; i++) {
                    if(body.mimics[i].IsKind(kind)) {
                        return true;
                    }
                }
            }

            return false;
        }


        private bool IsMimic(IokeObject pot) {
            if(this.body == pot.body || ContainsMimic(pot)) {
                return true;
            }

            if(body.mimic != null) {
                return body.mimic.IsMimic(pot);
            } else {
                for(int i = 0; i<body.mimicCount; i++) {
                    if(body.mimics[i].IsMimic(pot)) {
                        return true;
                    }
                }
            }
            return false;
        }

        public static IokeObject ConvertToRational(object on, IokeObject m, IokeObject context, bool signalCondition) {
            return ((IokeObject)on).ConvertToRational(m, context, signalCondition);
        }

        public static IokeObject ConvertToDecimal(object on, IokeObject m, IokeObject context, bool signalCondition) {
            return ((IokeObject)on).ConvertToDecimal(m, context, signalCondition);
        }

        public IokeObject ConvertToRational(IokeObject m, IokeObject context, bool signalCondition) {
            IokeObject result = data.ConvertToRational(this, m, context, false);
            if(result == null) {
                if(FindCell(this, "asRational") != context.runtime.nul) {
                    return IokeObject.As(Interpreter.Send(context.runtime.asRationalMessage, context, this), context);
                }
                if(signalCondition) {
                    return data.ConvertToRational(this, m, context, true);
                }
                return context.runtime.nil;
            }
            return result;
        }

        public IokeObject ConvertToDecimal(IokeObject m, IokeObject context, bool signalCondition) {
            IokeObject result = data.ConvertToDecimal(this, m, context, false);
            if(result == null) {
                if(FindCell(this, "asDecimal") != context.runtime.nul) {
                    return IokeObject.As(Interpreter.Send(context.runtime.asDecimalMessage, context, this), context);
                }
                if(signalCondition) {
                    return data.ConvertToDecimal(this, m, context, true);
                }
                return context.runtime.nil;
            }
            return result;
        }

        public static IokeObject ConvertToNumber(object on, IokeObject m, IokeObject context) {
            return ((IokeObject)on).ConvertToNumber(m, context);
        }

        public IokeObject ConvertToNumber(IokeObject m, IokeObject context) {
            return data.ConvertToNumber(this, m, context);
        }

        public static string Inspect(object on) {
            if(on is IokeObject) {
                IokeObject ion = (IokeObject)on;
                Runtime runtime = ion.runtime;
                return Text.GetText(Interpreter.Send(runtime.inspectMessage, ion, ion));
            } else {
                return on.ToString();
            }
        }

        public static string Notice(object on) {
            if(on is IokeObject) {
                IokeObject ion = (IokeObject)on;
                Runtime runtime = ion.runtime;
                return Text.GetText(Interpreter.Send(runtime.noticeMessage, ion, ion));
            } else {
                return on.ToString();
            }
        }

        public static IokeObject ConvertToText(object on, IokeObject m, IokeObject context, bool signalCondition) {
            return ((IokeObject)on).ConvertToText(m, context, signalCondition);
        }

        public static IokeObject TryConvertToText(object on, IokeObject m, IokeObject context) {
            return ((IokeObject)on).TryConvertToText(m, context);
        }

        public static IokeObject ConvertToRegexp(object on, IokeObject m, IokeObject context) {
            return ((IokeObject)on).ConvertToRegexp(m, context);
        }

        public IokeObject ConvertToRegexp(IokeObject m, IokeObject context) {
            return data.ConvertToRegexp(this, m, context);
        }

        public static IokeObject ConvertToSymbol(object on, IokeObject m, IokeObject context, bool signalCondition) {
            return ((IokeObject)on).ConvertToSymbol(m, context, signalCondition);
        }

        public IokeObject ConvertToSymbol(IokeObject m, IokeObject context, bool signalCondition) {
            IokeObject result = data.ConvertToSymbol(this, m, context, false);
            if(result == null) {
                if(FindCell(this, "asSymbol") != context.runtime.nul) {
                    return As(Interpreter.Send(context.runtime.asSymbolMessage, context, this), context);
                }
                if(signalCondition) {
                    return data.ConvertToSymbol(this, m, context, true);
                }
                return context.runtime.nil;
            }
            return result;
        }

        public IokeObject ConvertToText(IokeObject m, IokeObject context, bool signalCondition) {
            IokeObject result = data.ConvertToText(this, m, context, false);
            if(result == null) {
                if(FindCell(this, "asText") != context.runtime.nul) {
                    return As(Interpreter.Send(context.runtime.asText, context, this), context);
                }
                if(signalCondition) {
                    return data.ConvertToText(this, m, context, true);
                }
                return context.runtime.nil;
            }
            return result;
        }

        public IokeObject TryConvertToText(IokeObject m, IokeObject context) {
            return data.TryConvertToText(this, m, context);
        }

        public static object ConvertTo(string kind, object on, bool signalCondition, string conversionMethod, IokeObject message, IokeObject context) {
            return ((IokeObject)on).ConvertTo(kind, signalCondition, conversionMethod, message, context);
        }

        public static object ConvertTo(object mimic, object on, bool signalCondition, string conversionMethod, IokeObject message, IokeObject context) {
            return ((IokeObject)on).ConvertTo(mimic, signalCondition, conversionMethod, message, context);
        }

        public object ConvertTo(string kind, bool signalCondition, string conversionMethod, IokeObject message, IokeObject context) {
            object result = data.ConvertTo(this, kind, false, conversionMethod, message, context);
            if(result == null) {
                if(conversionMethod != null && FindCell(this, conversionMethod) != context.runtime.nul) {
                    IokeObject msg = context.runtime.NewMessage(conversionMethod);
                    return Interpreter.Send(msg, context, this);
                }
                if(signalCondition) {
                    return data.ConvertTo(this, kind, true, conversionMethod, message, context);
                }
                return context.runtime.nul;
            }
            return result;
        }

        public object ConvertTo(object mimic, bool signalCondition, string conversionMethod, IokeObject message, IokeObject context) {
            object result = data.ConvertTo(this, mimic, false, conversionMethod, message, context);
            if(result == null) {
                if(conversionMethod != null && FindCell(this, conversionMethod) != context.runtime.nul) {
                    IokeObject msg = context.runtime.NewMessage(conversionMethod);
                    return Interpreter.Send(msg, context, this);
                }
                if(signalCondition) {
                    return data.ConvertTo(this, mimic, true, conversionMethod, message, context);
                }
                return context.runtime.nul;
            }
            return result;
        }

        public object ConvertToMimic(object on, IokeObject message, IokeObject context, bool signal) {
            return ConvertToThis(on, signal, message, context);
        }

        public object ConvertToThis(object on, IokeObject message, IokeObject context) {
            return ConvertToThis(on, true, message, context);
        }

        public object ConvertToThis(object on, bool signalCondition, IokeObject message, IokeObject context) {
            if(on is IokeObject) {
                if(IokeObject.dataOf(on).GetType().Equals(data.GetType())) {
                    return on;
                } else {
                    return IokeObject.ConvertTo(this, on, signalCondition, IokeObject.dataOf(on).ConvertMethod, message, context);
                }
            } else {
                if(signalCondition) {
                    throw new System.Exception("oh no. -(: " + message.Name);
                } else {
                    return context.runtime.nul;
                }
            }
        }

        public override bool Equals(object other) {
            try {
                return IsEqualTo(other);
            } catch(System.Exception) {
                return false;
            }
        }

        public override int GetHashCode() {
            return IokeHashCode();
        }

        public new static bool Equals(object lhs, object rhs) {
            return ((IokeObject)lhs).IsEqualTo(rhs);
        }

        public bool IsEqualTo(object other) {
            return data.IsEqualTo(this, other);
        }

        public int IokeHashCode() {
            return data.HashCode(this);
        }
    }
}
