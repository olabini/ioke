
namespace Ioke.Lang {
    using System.Collections;
    using System.Collections.Generic;

    using Ioke.Lang.Util;

    public class IokeObject : ITypeChecker {
        public Runtime runtime;
        string documentation;
        IDictionary<string, object> cells;
        IList<IokeObject> mimics;

        public List<IokeObject> hooks;
    
        IokeData data;

        bool frozen = false;
        bool marked = false;

        public IokeObject(Runtime runtime, string documentation) : this(runtime, documentation, IokeData.None) {
        }

        public IokeObject(Runtime runtime, string documentation, IokeData data) {
            this.runtime = runtime;
            this.documentation = documentation;
            this.data = data;

            this.mimics = new SaneList<IokeObject>();
            this.cells = new SaneDictionary<string, object>();
        }

        public IDictionary<string, object> Cells {
            get { return cells; }
        }

        public IokeData Data {
            get { return data; }
            set { this.data = value; }
        }

        public string Documentation {
            get { return documentation; }
            set { this.documentation = value; }
        }

        public static IList<IokeObject> GetMimics(object on, IokeObject context) {
            return As(on, context).mimics;
        }

        public IList<IokeObject> GetMimics() {
            return mimics;
        }

        public IokeObject AllocateCopy(IokeObject m, IokeObject context) {
            return new IokeObject(runtime, null, data.CloneData(this, m, context));
        }

        public void MimicsWithoutCheck(IokeObject mimic) {
            if(!this.mimics.Contains(mimic)) {
                this.mimics.Add(mimic);
            }
        }

        private void CheckFrozen(string modification, IokeObject message, IokeObject context) {
            if(frozen) {
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
                return object.ReferenceEquals(As(one, null).cells, As(two, null).cells);
            } else {
                return object.ReferenceEquals(one, two);
            }
        }

        public void Become(IokeObject other, IokeObject message, IokeObject context) {
            CheckFrozen("become!", message, context);

            this.runtime = other.runtime;
            this.documentation = other.documentation;
            this.cells = other.cells;
            this.mimics = other.mimics;
            this.data = other.data;
            this.frozen = other.frozen;
        }

        public static void RemoveMimic(object on, object other, IokeObject message, IokeObject context) {
            IokeObject me = As(on, context);
            me.CheckFrozen("removeMimic!", message, context);
            me.mimics.Remove(As(other, context));
            if(me.hooks != null) {
                Hook.FireMimicsChanged(me, message, context, other);
                Hook.FireMimicRemoved(me, message, context, other);
            }
        }

        public static void RemoveAllMimics(object on, IokeObject message, IokeObject context) {
            IokeObject me = As(on, context);
            me.CheckFrozen("removeAllMimics!", message, context);
            List<IokeObject> copy = new SaneList<IokeObject>();
            foreach(IokeObject mm in me.mimics) copy.Add(mm);
            foreach(IokeObject mm in copy) {
                me.mimics.Remove(mm);
                Hook.FireMimicsChanged(me, message, context, mm);
                Hook.FireMimicRemoved(me, message, context, mm);
            }
        }

        public static bool IsFrozen(object on) {
            return (on is IokeObject) && As(on, null).frozen;
        }

        public static void Freeze(object on) {
            if(on is IokeObject) {
                As(on,null).frozen = true;
            }

        }

        public static void Thaw(object on) {
            if(on is IokeObject) {
                As(on, null).frozen = false;
            }
        }

        public static IokeData dataOf(object on) {
            return ((IokeObject)on).data;
        }

        public void SetDocumentation(string docs, IokeObject message, IokeObject context) {
            CheckFrozen("documentation=", message, context);

            this.documentation = docs;
        }

        public static object FindCell(object obj, IokeObject m, IokeObject context, string name) {
            return As(obj, context).MarkingFindCell(m, context, name);
        }

        public object FindCell(IokeObject m, IokeObject context, string name) {
            return MarkingFindCell(m, context, name);
        }

        public static void RemoveCell(object on, IokeObject m, IokeObject context, string name) {
            ((IokeObject)on).RemoveCell(m, context, name);
        }

        public static void UndefineCell(object on, IokeObject m, IokeObject context, string name) {
            ((IokeObject)on).UndefineCell(m, context, name);
        }

        public void RemoveCell(IokeObject m, IokeObject context, string name) {
            CheckFrozen("removeCell!", m, context);
            if(cells.ContainsKey(name)) {
                object prev = cells.Remove(name);
                if(hooks != null) {
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
            if(cells.ContainsKey(name)) {
                prev = cells[name];
            }
            cells[name] = runtime.nul;
            if(hooks != null) {
                if(prev == null) {
                    prev = runtime.nil;
                }
                Hook.FireCellChanged(this, m, context, name, prev);
                Hook.FireCellUndefined(this, m, context, name, prev);
            }
        }

        protected virtual object MarkingFindCell(IokeObject m, IokeObject context, string name) {
            if(this.marked) {
                return runtime.nul;
            }

            if(cells.ContainsKey(name)) {
                return cells[name];
            } else {
                this.marked = true;
                try {
                    foreach(IokeObject mimic in mimics) {
                        object cell = mimic.MarkingFindCell(m, context, name);
                        if(cell != runtime.nul) {
                            return cell;
                        }
                    }

                    return runtime.nul;
                } finally {
                    this.marked = false;
                }
            }
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

        /**
         * Finds the first object in the chain where name is available as a cell, or nul if nothing can be found.
         * findPlace is cycle aware and will not loop in an infinite chain. subclasses should copy this behavior.
         */
        public object FindPlace(string name) {
            return MarkingFindPlace(name);
        }

        protected virtual object MarkingFindPlace(string name) {
            if(this.marked) {
                return runtime.nul;
            }
            if(cells.ContainsKey(name)) {
                if(cells[name] == runtime.nul) {
                    return runtime.nul;
                }
                return this;
            } else {
                this.marked = true;
                try {
                    foreach(IokeObject mimic in mimics) {
                        object place = mimic.MarkingFindPlace(name);
                        if(place != runtime.nul) {
                            return place;
                        }
                    }

                    return runtime.nul;
                } finally {
                    this.marked = false;
                }
            }
        }

        public void RegisterMethod(IokeObject m) {
            cells[((Method)m.data).Name] = m;
        }

        public void AliasMethod(string originalName, string newName, IokeObject message, IokeObject context) {
            CheckFrozen("aliasMethod", message, context);

            IokeObject io = As(FindCell(null, null, originalName), context);
            IokeObject newObj = io.Mimic(null, null);
            newObj.data = new AliasMethod(newName, io.data, io);
            cells[newName] = newObj;
        }

        public void RegisterCell(string name, object o) {
            cells[name] = o;
        }

        public static void Assign(object on, string name, object value, IokeObject context, IokeObject message) {
            As(on, context).Assign(name, value, context, message);
        }

        public readonly static System.Text.RegularExpressions.Regex SLIGHTLY_BAD_CHARS = new System.Text.RegularExpressions.Regex("[!=\\.\\-\\+&|\\{\\[]");
        public virtual void Assign(string name, object value, IokeObject context, IokeObject message) {
            CheckFrozen("=", message, context);
            
            if(!SLIGHTLY_BAD_CHARS.Match(name).Success && FindCell(message, context, name + "=") != runtime.nul) {
                IokeObject msg = runtime.CreateMessage(new Message(runtime, name + "=", runtime.CreateMessage(Message.Wrap(As(value, context)))));
                ((Message)IokeObject.dataOf(msg)).SendTo(msg, context, this);
            } else {
                if(hooks != null) {
                    bool contains = cells.ContainsKey(name);
                    object prev = runtime.nil;
                    if(contains) {
                        prev = cells[name];
                    }
                    cells[name] = value;
                    if(!contains) {
                        Hook.FireCellAdded(this, message, context, name);
                    }
                    Hook.FireCellChanged(this, message, context, name, prev);
                } else {
                    cells[name] = value;
                }
            }
        }

        public static object GetCell(object on, IokeObject m, IokeObject context, string name) {
            return ((IokeObject)on).GetCell(m, context, name);
        }

        public virtual object Self {
            get { 
                if(cells.ContainsKey("self"))
                    return this.cells["self"]; 
                return null;
            }
        }

        public object GetCell(IokeObject m, IokeObject context, string name) {
            object cell = this.FindCell(m, context, name);

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
            cells[name] = o;
        }

        public string Kind {
            set { cells["kind"] = runtime.NewText(value); }
        }

        public static object GetRealContext(object o) {
            if(o is IokeObject) {
                return As(o, null).RealContext;
            }
            return o;
        }

        public virtual object RealContext {
            get { return this; }
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

        public static object Perform(object obj, IokeObject ctx, IokeObject message) {
            if(obj is IokeObject) {
                return As(obj, ctx).Perform(ctx, message);
            }
            return null;
        }

        public static IokeObject As(object on, IokeObject context) {
            if(on is IokeObject) {
                return ((IokeObject)on);
            } else {
                return null;
            }
        }

        public static IokeObject Mimic(object on, IokeObject message, IokeObject context) {
            return As(on, context).Mimic(message, context);
        }

        public void Mimics(IokeObject mimic, IokeObject message, IokeObject context) {
            CheckFrozen("mimic!", message, context);

            mimic.data.CheckMimic(mimic, message, context);
            if(!this.mimics.Contains(mimic)) {
                this.mimics.Add(mimic);
                if(mimic.hooks != null) {
                    Hook.FireMimicked(mimic, message, context, this);
                }
                if(hooks != null) {
                    Hook.FireMimicsChanged(this, message, context, mimic);
                    Hook.FireMimicAdded(this, message, context, mimic);
                }
            }
        }

        public void Mimics(int index, IokeObject mimic, IokeObject message, IokeObject context) {
            CheckFrozen("prependMimic!", message, context);

            mimic.data.CheckMimic(mimic, message, context);
            if(!this.mimics.Contains(mimic)) {
                this.mimics.Insert(index, mimic);
                if(mimic.hooks != null) {
                    Hook.FireMimicked(mimic, message, context, this);
                }
                if(hooks != null) {
                    Hook.FireMimicsChanged(this, message, context, mimic);
                    Hook.FireMimicAdded(this, message, context, mimic);
                }
            }
        }

        public IokeObject Mimic(IokeObject message, IokeObject context) {
            CheckFrozen("mimic!", message, context);

            IokeObject clone = AllocateCopy(message, context);
            clone.Mimics(this, message, context);
            return clone;
        }

        public object Perform(IokeObject ctx, IokeObject message) {
            return Perform(ctx, message, message.Name);
        }

        private bool IsApplicable(object pass, IokeObject message, IokeObject ctx) {
            if(pass != null && pass != runtime.nul && As(pass, ctx).FindCell(message, ctx, "applicable?") != runtime.nul) {
                return IsObjectTrue(((Message)IokeObject.dataOf(runtime.isApplicableMessage)).SendTo(runtime.isApplicableMessage, ctx, pass, runtime.CreateMessage(Message.Wrap(message))));
            }
            return true;
        }

        public static object GetOrActivate(object obj, IokeObject context, IokeObject message, object on) {
            if(obj is IokeObject) {
                return As(obj, context).GetOrActivate(context, message, on);
            } else {
                return obj;
            }
        }

        public virtual bool IsActivatable {
            get { return IsObjectTrue(FindCell(null, null, "activatable")); }
        }

        public virtual bool IsTrue {
            get { return data.IsTrue; }
        }

        public virtual bool IsNil {
            get { return data.IsNil; }
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
            object obj = FindCell(null, null, "kind");
            if(IokeObject.dataOf(obj) is Text) {
                return ((Text)IokeObject.dataOf(obj)).GetText();
            } else {
                return ((Text)IokeObject.dataOf(GetOrActivate(obj, context, message, this))).GetText();
            }
        }

        public string GetKind() {
            object obj = FindCell(null, null, "kind");
            if(obj != null && IokeObject.dataOf(obj) is Text) {
                return ((Text)IokeObject.dataOf(obj)).GetText();
            } else {
                return null;
            }
        }

        public bool HasKind {
            get { return cells.ContainsKey("kind"); }
        }

        public object GetOrActivate(IokeObject context, IokeObject message, object on) {
            if(IsActivatable || ((data is AssociatedCode) && message.Arguments.Count > 0)) {
                return Activate(context, message, on);
            } else {
                return this;
            }
        }

        public static object FindSuperCellOn(object obj, IokeObject early, IokeObject message, IokeObject context, string name) {
            return As(obj, context).MarkingFindSuperCell(early, message, context, name, new bool[]{false});
        }

        protected virtual object MarkingFindSuperCell(IokeObject early, IokeObject message, IokeObject context, string name, bool[] found) {
            if(name == null || this.marked) {
                return runtime.nul;
            }

            if(cells.ContainsKey(name)) {
                if(found[0]) {
                    return cells[name];
                }
                if(early == cells[name]) {
                    found[0] = true;
                }
            }

            this.marked = true;
            try {
                foreach(IokeObject mimic in mimics) {
                    object cell = mimic.MarkingFindSuperCell(early, message, context, name, found);
                    if(cell != runtime.nul) {
                        return cell;
                    }
                }

                return runtime.nul;
            } finally {
                this.marked = false;
            }
        }

        public static object Activate(object self, IokeObject context, IokeObject message, object on) {
            return As(self, context).Activate(context, message, on);
        }

        public object Activate(IokeObject context, IokeObject message, object on) {
            return data.Activate(this, context, message, on);
        }

        public object ActivateWithData(IokeObject context, IokeObject message, object on, IDictionary<string, object> d1) {
            return data.ActivateWithData(this, context, message, on, d1);
        }

        public object ActivateWithCall(IokeObject context, IokeObject message, object on, object c) {
            return data.ActivateWithCall(this, context, message, on, c);
        }

        public object ActivateWithCallAndData(IokeObject context, IokeObject message, object on, object c, IDictionary<string, object> d1) {
            return data.ActivateWithCallAndData(this, context, message, on, c, d1);
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

        private class StoreValue : Restart.ArgumentGivingRestart { 
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

        public object Perform(IokeObject ctx, IokeObject message, string name) {
            object cell = this.FindCell(message, ctx, name);
            object passed = null;

            while(cell == runtime.nul && (((cell = passed = this.FindCell(message, ctx, "pass")) == runtime.nul) || !IsApplicable(passed, message, ctx))) {
                IokeObject condition = As(IokeObject.GetCellChain(runtime.Condition, 
                                                                  message, 
                                                                  ctx, 
                                                                  "Error", 
                                                                  "NoSuchCell"), ctx).Mimic(message, ctx);
                condition.SetCell("message", message);
                condition.SetCell("context", ctx);
                condition.SetCell("receiver", this);
                condition.SetCell("cellName", runtime.GetSymbol(name));

                object[] newCell = new object[]{cell};

                runtime.WithRestartReturningArguments(() => {runtime.ErrorCondition(condition);}, ctx, new UseValue(name, newCell), new StoreValue(name, newCell, this));

                cell = newCell[0];
            }

            return GetOrActivate(cell, ctx, message, this);
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
            if(this.marked) {
                return false;
            }

            if(cells.ContainsKey("kind") && kind.Equals(Text.GetText(cells["kind"]))) {
                return true;
            }

            this.marked = true;
            try {
                foreach(IokeObject mimic in mimics) {
                    if(mimic.IsKind(kind)) {
                        return true;
                    }
                }

                return false;
            } finally {
                this.marked = false;
            }
        }

        private bool IsMimic(IokeObject pot) {
            if(this.marked) {
                return false;
            }

            if(this.cells == pot.cells || mimics.Contains(pot)) {
                return true;
            }

            this.marked = true;
            try {
                foreach(IokeObject mimic in mimics) {
                    if(mimic.IsMimic(pot)) {
                        return true;
                    }
                }

                return false;
            } finally {
                this.marked = false;
            }
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
                if(FindCell(m, context, "asRational") != context.runtime.nul) {
                    return IokeObject.As(((Message)IokeObject.dataOf(context.runtime.asRationalMessage)).SendTo(context.runtime.asRationalMessage, context, this), context);
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
                if(FindCell(m, context, "asDecimal") != context.runtime.nul) {
                    return IokeObject.As(((Message)IokeObject.dataOf(context.runtime.asDecimalMessage)).SendTo(context.runtime.asDecimalMessage, context, this), context);
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
                return Text.GetText(((Message)IokeObject.dataOf(runtime.inspectMessage)).SendTo(runtime.inspectMessage, ion, ion));
            } else {
                return on.ToString();
            }
        }

        public static string Notice(object on) {
            if(on is IokeObject) {
                IokeObject ion = (IokeObject)on;
                Runtime runtime = ion.runtime;
                return Text.GetText(((Message)IokeObject.dataOf(runtime.noticeMessage)).SendTo(runtime.noticeMessage, ion, ion));
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
                if(FindCell(m, context, "asSymbol") != context.runtime.nul) {
                    return As(((Message)IokeObject.dataOf(context.runtime.asSymbolMessage)).SendTo(context.runtime.asSymbolMessage, context, this), context);
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
                if(FindCell(m, context, "asText") != context.runtime.nul) {
                    return As(((Message)IokeObject.dataOf(context.runtime.asText)).SendTo(context.runtime.asText, context, this), context);
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
                if(conversionMethod != null && FindCell(message, context, conversionMethod) != context.runtime.nul) {
                    IokeObject msg = context.runtime.NewMessage(conversionMethod);
                    return ((Message)IokeObject.dataOf(msg)).SendTo(msg, context, this);
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
                if(conversionMethod != null && FindCell(message, context, conversionMethod) != context.runtime.nul) {
                    IokeObject msg = context.runtime.NewMessage(conversionMethod);
                    return ((Message)IokeObject.dataOf(msg)).SendTo(msg, context, this);
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
