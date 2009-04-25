
namespace Ioke.Lang {
    using System;
    using System.Collections;
    using System.Text;

    using Ioke.Lang.Util;

    public class IokeList : IokeData {
        IList list;

        public IokeList() : this(new SaneArrayList()) {
        }

        public IokeList(IList l) {
            this.list = l;
        }

        public static IList GetList(object on) {
            return ((IokeList)(IokeObject.dataOf(on))).list;
        }

        public IList List {
            get { return list; }
            set { this.list = value; }
        }

        public static void Add(object list, object obj) {
            ((IokeList)IokeObject.dataOf(list)).list.Add(obj);
        }

        public static void Add(object list, int index, object obj) {
            ((IokeList)IokeObject.dataOf(list)).list.Insert(index, obj);
        }

        public override void Init(IokeObject obj) {
            Runtime runtime = obj.runtime;

            obj.Kind = "List";
            obj.Mimics(IokeObject.As(runtime.Mixins.GetCell(null, null, "Enumerable"), null), runtime.nul, runtime.nul);

            obj.RegisterMethod(runtime.NewNativeMethod("takes either one or two or three arguments. if one argument is given, it should be a message chain that will be sent to each object in the list. the result will be thrown away. if two arguments are given, the first is an unevaluated name that will be set to each of the values in the list in succession, and then the second argument will be evaluated in a scope with that argument in it. if three arguments is given, the first one is an unevaluated name that will be set to the index of each element, and the other two arguments are the name of the argument for the value, and the actual code. the code will evaluate in a lexical context, and if the argument name is available outside the context, it will be shadowed. the method will return the list.", 
                                                       new NativeMethod("each", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositionalUnevaluated("indexOrArgOrCode")
                                                                        .WithOptionalPositionalUnevaluated("argOrCode")
                                                                        .WithOptionalPositionalUnevaluated("code")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);

                                                                            object onAsList = context.runtime.List.ConvertToThis(on, message, context);
                                                                            var ls = ((IokeList)IokeObject.dataOf(onAsList)).list;
                                                                            switch(message.Arguments.Count) {
                                                                            case 1: {
                                                                                IokeObject code = IokeObject.As(message.Arguments[0], context);
                                                                                
                                                                                foreach(object o in ls) {
                                                                                    ((Message)IokeObject.dataOf(code)).EvaluateCompleteWithReceiver(code, context, context.RealContext, o);
                                                                                }
                                                                                break;
                                                                            }
                                                                            case 2: {
                                                                                LexicalContext c = new LexicalContext(context.runtime, context, "Lexical activation context for List#each", message, context);
                                                                                string name = IokeObject.As(message.Arguments[0], context).Name;
                                                                                IokeObject code = IokeObject.As(message.Arguments[1], context);

                                                                                foreach(object o in ls) {
                                                                                    c.SetCell(name, o);
                                                                                    ((Message)IokeObject.dataOf(code)).EvaluateCompleteWithoutExplicitReceiver(code, c, c.RealContext);
                                                                                }
                                                                                break;
                                                                            }
                                                                            case 3: {
                                                                                LexicalContext c = new LexicalContext(context.runtime, context, "Lexical activation context for List#each", message, context);
                                                                                string iname = IokeObject.As(message.Arguments[0], context).Name;
                                                                                string name = IokeObject.As(message.Arguments[1], context).Name;
                                                                                IokeObject code = IokeObject.As(message.Arguments[2], context);

                                                                                int index = 0;
                                                                                foreach(object o in ls) {
                                                                                    c.SetCell(name, o);
                                                                                    c.SetCell(iname, runtime.NewNumber(index++));
                                                                                    ((Message)IokeObject.dataOf(code)).EvaluateCompleteWithoutExplicitReceiver(code, c, c.RealContext);
                                                                                }
                                                                                break;
                                                                            }
                                                                            }
                                                                            return onAsList;
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("takes one argument, the index of the element to be returned. can be negative, and will in that case return indexed from the back of the list. if the index is outside the bounds of the list, will return nil. the argument can also be a range, and will in that case interpret the first index as where to start, and the second the end. the end can be negative and will in that case be from the end. if the first argument is negative, or after the second, an empty list will be returned. if the end point is larger than the list, the size of the list will be used as the end point.", 
                                                       new TypeCheckingNativeMethod("at", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(runtime.List)
                                                                                    .WithRequiredPositional("index")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        object arg = args[0];

                                                                                        if(IokeObject.dataOf(arg) is Range) {
                                                                                            int first = Number.ExtractInt(Range.GetFrom(arg), message, context); 
                        
                                                                                            if(first < 0) {
                                                                                                return context.runtime.NewList(new SaneArrayList());
                                                                                            }

                                                                                            int last = Number.ExtractInt(Range.GetTo(arg), message, context);
                                                                                            bool inclusive = Range.IsInclusive(arg);

                                                                                            var o = ((IokeList)IokeObject.dataOf(on)).List;
                                                                                            int size = o.Count;

                                                                                            if(last < 0) {
                                                                                                last = size + last;
                                                                                            }

                                                                                            if(last < 0) {
                                                                                                return context.runtime.NewList(new SaneArrayList());
                                                                                            }

                                                                                            if(last >= size) {
                            
                                                                                                last = inclusive ? size-1 : size;
                                                                                            }

                                                                                            if(first > last || (!inclusive && first == last)) {
                                                                                                return context.runtime.NewList(new SaneArrayList());
                                                                                            }
                        
                                                                                            if(!inclusive) {
                                                                                                last--;
                                                                                            }
                                                                                            
                                                                                            var l = new SaneArrayList();
                                                                                            for(int i = first; i<last+1; i++) {
                                                                                                l.Add(o[i]);
                                                                                            }

                                                                                            return context.runtime.NewList(l);
                                                                                        }

                                                                                        if(!(IokeObject.dataOf(arg) is Number)) {
                                                                                            arg = IokeObject.ConvertToNumber(arg, message, context);
                                                                                        }
                                                                                        int index = ((Number)IokeObject.dataOf(arg)).AsNativeInteger();
                                                                                        var o2 = ((IokeList)IokeObject.dataOf(on)).List;
                                                                                        if(index < 0) {
                                                                                            index = o2.Count + index;
                                                                                        }

                                                                                        if(index >= 0 && index < o2.Count) {
                                                                                            return o2[index];
                                                                                        } else {
                                                                                            return context.runtime.nil;
                                                                                        }
                                                                                    })));
            obj.AliasMethod("at", "[]", null, null);


            obj.RegisterMethod(runtime.NewNativeMethod("returns the size of this list", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("size", runtime.List,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        return context.runtime.NewNumber(((IokeList)IokeObject.dataOf(on)).List.Count);
                                                                                                    })));
            obj.AliasMethod("size", "length", null, null);

            obj.RegisterMethod(runtime.NewNativeMethod("Returns a text inspection of the object", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("inspect", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        return method.runtime.NewText(IokeList.GetInspect(on));
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("Returns a brief text inspection of the object", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("notice", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        return method.runtime.NewText(IokeList.GetNotice(on));
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("Compares this object against the argument. The comparison is only based on the elements inside the lists, which are in turn compared using <=>.", 
                                                       new TypeCheckingNativeMethod("<=>", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithRequiredPositional("other")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        var one = IokeList.GetList(on);
                                                                                        object arg = args[0];
                                                                                        if(!(IokeObject.dataOf(arg) is IokeList)) {
                                                                                            return context.runtime.nil;
                                                                                        }
                                                                                        var two = IokeList.GetList(arg);

                                                                                        int len = Math.Min(one.Count, two.Count);
                                                                                        SpaceshipComparator sc = new SpaceshipComparator(context, message);

                                                                                        for(int i = 0; i < len; i++) {
                                                                                            int v = sc.Compare(one[i], two[i]);
                                                                                            if(v != 0) {
                                                                                                return context.runtime.NewNumber(v);
                                                                                            }
                                                                                        }

                                                                                        len = one.Count - two.Count;

                                                                                        if(len == 0) return context.runtime.NewNumber(0);
                                                                                        if(len > 0) return context.runtime.NewNumber(1);
                                                                                        return context.runtime.NewNumber(-1);
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("takes one argument and adds it at the end of the list, and then returns the list", 
                                                       new TypeCheckingNativeMethod("<<", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithRequiredPositional("value")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        IokeList.Add(on, args[0]);
                                                                                        return on;
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("takes one argument and adds it at the end of the list, and then returns the list", 
                                                       new TypeCheckingNativeMethod("append!", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithRequiredPositional("value")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        object value = args[0];
                                                                                        IokeList.Add(on, value);
                                                                                        return on;
                                                                                    })));

            obj.AliasMethod("append!", "push!", null, null);

            obj.RegisterMethod(runtime.NewNativeMethod("takes one argument and adds it at the beginning of the list, and then returns the list", 
                                                       new TypeCheckingNativeMethod("prepend!", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithRequiredPositional("value")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        object value = args[0];
                                                                                        IokeList.Add(on, 0, value);
                                                                                        return on;
                                                                                    })));

            obj.AliasMethod("prepend!", "unshift!", null, null);

            obj.RegisterMethod(runtime.NewNativeMethod("removes the last element from the list and returns it. returns nil if the list is empty.", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("pop!", obj, 
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        var l = ((IokeList)IokeObject.dataOf(on)).List;
                                                                                                        if(l.Count == 0) {
                                                                                                            return context.runtime.nil;
                                                                                                        }
                                                                                                        object result = l[l.Count-1];
                                                                                                        l.RemoveAt(l.Count-1);
                                                                                                        return result;
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("removes the first element from the list and returns it. returns nil if the list is empty.", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("shift!", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        var l = ((IokeList)IokeObject.dataOf(on)).List;
                                                                                                        if(l.Count == 0) {
                                                                                                            return context.runtime.nil;
                                                                                                        }
                                                                                                        object result = l[0];
                                                                                                        l.RemoveAt(0);
                                                                                                        return result;
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("will remove all the entries from the list, and then returns the list", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("clear!", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        ((IokeList)IokeObject.dataOf(on)).List.Clear();
                                                                                                        return on;
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns true if this list is empty, false otherwise", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("empty?", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        return ((IokeList)IokeObject.dataOf(on)).List.Count == 0 ? context.runtime.True : context.runtime.False;
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns true if the receiver includes the evaluated argument, otherwise false", 
                                                       new TypeCheckingNativeMethod("include?", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithRequiredPositional("object")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        return ((IokeList)IokeObject.dataOf(on)).List.Contains(args[0]) ? context.runtime.True : context.runtime.False;
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("adds the elements in the argument list to the current list, and then returns that list", 
                                                       new TypeCheckingNativeMethod("concat!", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithRequiredPositional("otherList").WhichMustMimic(obj)
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        var l = ((IokeList)IokeObject.dataOf(on)).List;
                                                                                        var l2 = ((IokeList)IokeObject.dataOf(args[0])).List;
                                                                                        foreach(object x in l2) l.Add(x);
                                                                                        return on;
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns a new list that contains the receivers elements and the elements of the list sent in as the argument.", 
                                                       new TypeCheckingNativeMethod("+", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithRequiredPositional("otherList").WhichMustMimic(obj)
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        var newList = new SaneArrayList();
                                                                                        newList.AddRange(((IokeList)IokeObject.dataOf(on)).List);
                                                                                        newList.AddRange(((IokeList)IokeObject.dataOf(args[0])).List);
                                                                                        return context.runtime.NewList(newList, IokeObject.As(on, context));
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns a new list that contains all the elements from the receivers list, except for those that are in the argument list", 
                                                       new TypeCheckingNativeMethod("-", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithRequiredPositional("otherList").WhichMustMimic(obj)
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        var newList = new SaneArrayList();
                                                                                        var l = ((IokeList)IokeObject.dataOf(args[0])).List;
                                                                                        foreach(object x in ((IokeList)IokeObject.dataOf(on)).List) {
                                                                                            if(!l.Contains(x)) {
                                                                                                newList.Add(x);
                                                                                            }
                                                                                        }
                                                                                        return context.runtime.NewList(newList, IokeObject.As(on, context));
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns a new sorted version of this list", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("sort", obj,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        object newList = IokeObject.Mimic(on, message, context);
                                                                                                        var ll = ((IokeList)IokeObject.dataOf(newList)).List;
                                                                                                        if(ll is ArrayList) {
                                                                                                            ((ArrayList)ll).Sort(new SpaceshipComparator(context, message));
                                                                                                        } else {
                                                                                                            ArrayList second = new SaneArrayList(ll);
                                                                                                            ((ArrayList)second).Sort(new SpaceshipComparator(context, message));
                                                                                                            ((IokeList)IokeObject.dataOf(newList)).List = second;
                                                                                                        }
                                                                                                        return newList;
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("sorts this list in place and then returns it", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("sort!", obj,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        var ll = ((IokeList)IokeObject.dataOf(on)).List;
                                                                                                        if(ll is ArrayList) {
                                                                                                            ((ArrayList)ll).Sort(new SpaceshipComparator(context, message));
                                                                                                        } else {
                                                                                                            ArrayList second = new SaneArrayList(ll);
                                                                                                            ((ArrayList)second).Sort(new SpaceshipComparator(context, message));
                                                                                                            ((IokeList)IokeObject.dataOf(on)).List = second;
                                                                                                        }
                                                                                                        return on;
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("takes an index and zero or more objects to insert at that point. the index can be negative to index from the end of the list. if the index is positive and larger than the size of the list, the list will be filled with nils inbetween.", 
                                                       new TypeCheckingNativeMethod("insert!", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithRequiredPositional("index").WhichMustMimic(runtime.Number)
                                                                                    .WithRest("objects")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        int index = ((Number)IokeObject.dataOf(args[0])).AsNativeInteger();
                                                                                        var l = ((IokeList)IokeObject.dataOf(on)).List;
                                                                                        int size = l.Count;
                                                                                        if(index < 0) {
                                                                                            index = size + index + 1;
                                                                                        }

                                                                                        if(args.Count>1) {
                                                                                            while(index < 0) {
                                                                                                IokeObject condition = IokeObject.As(IokeObject.GetCellChain(context.runtime.Condition, 
                                                                                                                                                             message, 
                                                                                                                                                             context, 
                                                                                                                                                             "Error", 
                                                                                                                                                             "Index"), context).Mimic(message, context);
                                                                                                condition.SetCell("message", message);
                                                                                                condition.SetCell("context", context);
                                                                                                condition.SetCell("receiver", on);
                                                                                                condition.SetCell("index", context.runtime.NewNumber(index));

                                                                                                
                                                                                                object[] newCell = new object[]{context.runtime.NewNumber(index)};

                                                                                                context.runtime.WithRestartReturningArguments(()=>{context.runtime.ErrorCondition(condition);},
                                                                                                                                              context,
                                                                                                                                              new IokeObject.UseValue("index", newCell));

                                                                                                index = Number.ExtractInt(newCell[0], message, context);
                                                                                                if(index < 0) {
                                                                                                    index = size + index;
                                                                                                }
                                                                                            }

                                                                                            for(int x = (index-size); x>0; x--) {
                                                                                                l.Add(context.runtime.nil);
                                                                                            }
                                                                                            
                                                                                            for(int i=1, j=args.Count; i<j; i++) l.Insert(index + i - 1, args[i]);
                                                                                        }

                                                                                        return on;
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("takes two arguments, the index of the element to set, and the value to set. the index can be negative and will in that case set indexed from the end of the list. if the index is larger than the current size, the list will be expanded with nils. an exception will be raised if a abs(negative index) is larger than the size.", 
                                                       new TypeCheckingNativeMethod("at=", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithRequiredPositional("index")
                                                                                    .WithRequiredPositional("value")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        object arg = args[0];
                                                                                        object value = args[1];
                                                                                        if(!(IokeObject.dataOf(arg) is Number)) {
                                                                                            arg = IokeObject.ConvertToNumber(arg, message, context);
                                                                                        }
                                                                                        int index = ((Number)IokeObject.dataOf(arg)).AsNativeInteger();
                                                                                        var o = ((IokeList)IokeObject.dataOf(on)).List;
                                                                                        if(index < 0) {
                                                                                            index = o.Count + index;
                                                                                        }

                                                                                        while(index < 0) {
                                                                                            IokeObject condition = IokeObject.As(IokeObject.GetCellChain(context.runtime.Condition, 
                                                                                                                                                         message, 
                                                                                                                                                         context, 
                                                                                                                                                         "Error", 
                                                                                                                                                         "Index"), context).Mimic(message, context);
                                                                                            condition.SetCell("message", message);
                                                                                            condition.SetCell("context", context);
                                                                                            condition.SetCell("receiver", on);
                                                                                            condition.SetCell("index", context.runtime.NewNumber(index));

                                                                                            object[] newCell = new object[]{context.runtime.NewNumber(index)};

                                                                                            context.runtime.WithRestartReturningArguments(()=>{context.runtime.ErrorCondition(condition);},
                                                                                                                                          context,
                                                                                                                                          new IokeObject.UseValue("index", newCell));

                                                                                            index = Number.ExtractInt(newCell[0], message, context);
                                                                                            if(index < 0) {
                                                                                                index = o.Count + index;
                                                                                            }
                                                                                        }

                                                                                        if(index >= o.Count) {
                                                                                            int toAdd = (index-o.Count) + 1;
                                                                                            for(int i=0;i<toAdd;i++) {
                                                                                                o.Add(context.runtime.nil);
                                                                                            }
                                                                                        }

                                                                                        o[(int)index] = value;

                                                                                        return value;
                                                                                    })));

            obj.AliasMethod("at=", "[]=", null, null);
        
            obj.RegisterMethod(runtime.NewNativeMethod(
                                                     "takes as argument the index of the element to be removed and returns it. can be " +
                                                     "negative and will in that case index from the back of the list. if the index is " +
                                                     "outside the bounds of the list, will return nil. the argument can also be a range, " +
                                                     "and will in that case remove the sublist beginning at the first index and extending " +
                                                     "to the position in the list specified by the second index (inclusive or exclusive " +
                                                     "depending on the range). the end of the range can be negative and will in that case " +
                                                     "index from the back of the list. if the start of the range is negative, or greater " +
                                                     "than the end, an empty list will be returned. if the end index exceeds the bounds " +
                                                     "of the list, its size will be used instead.", 
                                                     new TypeCheckingNativeMethod("removeAt!", TypeCheckingArgumentsDefinition.builder()
                                                                                  .ReceiverMustMimic(obj)
                                                                                  .WithRequiredPositional("indexOrRange")
                                                                                  .Arguments,
                                                                                  (method, on, args, keywords, context, message) => {
                                                                                      object arg = args[0];

                                                                                      if(IokeObject.dataOf(arg) is Range) {
                                                                                          int first = Number.ExtractInt(Range.GetFrom(arg), message, context); 
                                                                                          if(first < 0) {
                                                                                              return EmptyList(context);
                                                                                          }

                                                                                          int last = Number.ExtractInt(Range.GetTo(arg), message, context);
                                                                                          var receiver = GetList(on);
                                                                                          int size = receiver.Count;

                                                                                          if(last < 0) {
                                                                                              last = size + last;
                                                                                          }

                                                                                          if(last < 0) {
                                                                                              return EmptyList(context);
                                                                                          }

                                                                                          bool inclusive = Range.IsInclusive(arg);
                    
                                                                                          if(last >= size) {                        
                                                                                              last = inclusive ? size-1 : size;
                                                                                          }

                                                                                          if(first > last || (!inclusive && first == last)) {
                                                                                              return EmptyList(context);
                                                                                          }
                    
                                                                                          if(!inclusive) {
                                                                                              last--;
                                                                                          }
                    
                                                                                          var result = new SaneArrayList();
                                                                                          for(int i = 0; i <= last - first; i++) {
                                                                                              result.Add(receiver[first]);
                                                                                              receiver.RemoveAt(first);
                                                                                          }
                    
                                                                                          return CopyList(context, result);
                                                                                      }

                                                                                      if(!(IokeObject.dataOf(arg) is Number)) {
                                                                                          arg = IokeObject.ConvertToNumber(arg, message, context);
                                                                                      }
               
                                                                                      int index = ((Number)IokeObject.dataOf(arg)).AsNativeInteger();
                                                                                      var receiver2 = GetList(on);
                                                                                      int size2 = receiver2.Count;
                                                                                      
                                                                                      if(index < 0) {
                                                                                          index = size2 + index;
                                                                                      }
                                                                                      
                                                                                      if(index >= 0 && index < size2) {
                                                                                          object result = receiver2[(int)index];
                                                                                          receiver2.RemoveAt((int)index);
                                                                                          return result;
                                                                                      } else {
                                                                                          return context.runtime.nil;
                                                                                      }
                                                                                  })));
        
            obj.RegisterMethod(runtime.NewNativeMethod(
                                                     "takes one or more arguments. removes all occurrences of the provided arguments from " +
                                                     "the list and returns the updated list. if an argument is not contained, the list " +
                                                     "remains unchanged. sending this method to an empty list has no effect.", 
                                                     new TypeCheckingNativeMethod("remove!", TypeCheckingArgumentsDefinition.builder()
                                                                                  .ReceiverMustMimic(obj)
                                                                                  .WithRequiredPositional("element")
                                                                                  .WithRest("elements")
                                                                                  .Arguments,
                                                                                  (method, on, args, keywords, context, message) => {
                                                                                      var receiver = GetList(on);
                                                                                      if(receiver.Count == 0) {
                                                                                          return on;
                                                                                      }
                                                                                      foreach(object o in args) {
                                                                                          for(int i = 0, j=receiver.Count; i<j; i++) {
                                                                                              if(o.Equals(receiver[i])) {
                                                                                                  receiver.RemoveAt(i);
                                                                                                  i--;
                                                                                                  j--;
                                                                                              }
                                                                                          }
                                                                                      }
                                                                                      return on;
                                                                                  })));
        
            obj.RegisterMethod(runtime.NewNativeMethod(
                                                     "takes one or more arguments. removes the first occurrence of the provided arguments " +
                                                     "from the list and returns the updated list. if an argument is not contained, the list " +
                                                     "remains unchanged. arguments that are provided multiple times are treated as distinct " +
                                                     "elements. sending this message to an empty list has no effect.", 
                                                     new TypeCheckingNativeMethod("removeFirst!", TypeCheckingArgumentsDefinition.builder()
                                                                                  .ReceiverMustMimic(obj)
                                                                                  .WithRequiredPositional("element")
                                                                                  .WithRest("elements")
                                                                                  .Arguments,
                                                                                  (method, on, args, keywords, context, message) => {
                                                                                      var receiver = GetList(on);
                                                                                      if(receiver.Count == 0) {
                                                                                          return on;
                                                                                      }
                                                                                      foreach(object o in args) {
                                                                                          receiver.Remove(o);
                                                                                      }
                                                                                      return on;
                                                                                  })));

            obj.RegisterMethod(runtime.NewNativeMethod("removes all nils in this list, and then returns the list", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("compact!", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        var list = GetList(on);
                                                                                                        var newList = new SaneArrayList();
                                                                                                        object nil = context.runtime.nil;
                                                                                                        foreach(object o in list) {
                                                                                                            if(o != nil) {
                                                                                                                newList.Add(o);
                                                                                                            }
                                                                                                        }
                                                                                                        SetList(on, newList);
                                                                                                        return on;
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("reverses the elements in this list, then returns it", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("reverse!", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        var list = GetList(on);
                                                                                                        if(list is ArrayList) {
                                                                                                            ((ArrayList)list).Reverse();
                                                                                                        } else {
                                                                                                            ArrayList list2 = new SaneArrayList(list);
                                                                                                            list2.Reverse();
                                                                                                            SetList(on, list2);
                                                                                                        }
                                                                                                        return on;
                                                                                                    })));
            
            obj.RegisterMethod(runtime.NewNativeMethod("flattens all lists in this list recursively, then returns it", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("flatten!", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        SetList(on, Flatten(GetList(on)));
                                                                                                        return on;
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns a text composed of the asText representation of all elements in the list, separated by the separator. the separator defaults to an empty text.", 
                                                       new TypeCheckingNativeMethod("join", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithOptionalPositional("separator", "")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        var list = GetList(on);
                                                                                        string result;
                                                                                        if(list.Count == 0) {
                                                                                            result = "";
                                                                                        } else {
                                                                                            string sep = args.Count > 0 ? Text.GetText(args[0]) : "";
                                                                                            StringBuilder sb = new StringBuilder();
                                                                                            Join(list, sb, sep, context.runtime.asText, context);
                                                                                            result = sb.ToString();
                                                                                        }
                                                                                        return context.runtime.NewText(result);
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("takes one or two arguments, and will then use these arguments as code to transform each element in this list. the transform happens in place. finally the method will return the receiver.", 
                                                       new NativeMethod("map!", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositionalUnevaluated("argOrCode")
                                                                        .WithOptionalPositionalUnevaluated("code")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                            object onAsList = context.runtime.List.ConvertToThis(on, message, context);
                    
                                                                            var ls = ((IokeList)IokeObject.dataOf(onAsList)).list;
                                                                            int size = ls.Count;
                    
                                                                            switch(message.Arguments.Count) {
                                                                            case 1: {
                                                                                IokeObject code = IokeObject.As(message.Arguments[0], context);

                                                                                for(int i = 0; i<size; i++) {
                                                                                    ls[i] = ((Message)IokeObject.dataOf(code)).EvaluateCompleteWithReceiver(code, context, context.RealContext, ls[i]);
                                                                                }
                                                                                break;
                                                                            }
                                                                            case 2: {
                                                                                LexicalContext c = new LexicalContext(context.runtime, context, "Lexical activation context for List#map!", message, context);
                                                                                string name = IokeObject.As(message.Arguments[0], context).Name;
                                                                                IokeObject code = IokeObject.As(message.Arguments[1], context);

                                                                                for(int i = 0; i<size; i++) {
                                                                                    c.SetCell(name, ls[i]);
                                                                                    ls[i] = ((Message)IokeObject.dataOf(code)).EvaluateCompleteWithoutExplicitReceiver(code, c, c.RealContext);
                                                                                }
                                                                                break;
                                                                            }
                                                                            }
                                                                            return on;
                                                                        })));
            
            obj.AliasMethod("map!", "collect!", null, null);

            obj.RegisterMethod(runtime.NewNativeMethod("takes one or two arguments, and will then use these arguments as code to decide what elements should be removed from the list. the method will return the receiver.", 
                                                       new NativeMethod("removeIf!", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositionalUnevaluated("argOrCode")
                                                                        .WithOptionalPositionalUnevaluated("code")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                            object onAsList = context.runtime.List.ConvertToThis(on, message, context);
                    
                                                                            var ls = ((IokeList)IokeObject.dataOf(onAsList)).list;
                    
                                                                            switch(message.Arguments.Count) {
                                                                            case 1: {
                                                                                IokeObject code = IokeObject.As(message.Arguments[0], context);
                                                                                
                                                                                int count = ls.Count;
                                                                                for(int i = 0; i<count; i++) {
                                                                                    object o1 = ls[i];
                                                                                    if(IokeObject.IsObjectTrue(((Message)IokeObject.dataOf(code)).EvaluateCompleteWithReceiver(code, context, context.RealContext, o1))) {
                                                                                        ls.RemoveAt(i);
                                                                                        i--;
                                                                                        count--;
                                                                                    }
                                                                                }
                                                                                break;
                                                                            }
                                                                            case 2: {
                                                                                LexicalContext c = new LexicalContext(context.runtime, context, "Lexical activation context for List#map!", message, context);
                                                                                string name = IokeObject.As(message.Arguments[0], context).Name;
                                                                                IokeObject code = IokeObject.As(message.Arguments[1], context);

                                                                                int count = ls.Count;
                                                                                for(int i = 0; i<count; i++) {
                                                                                    object o2 = ls[i];
                                                                                    c.SetCell(name, o2);
                                                                                    if(IokeObject.IsObjectTrue(((Message)IokeObject.dataOf(code)).EvaluateCompleteWithoutExplicitReceiver(code, c, c.RealContext))) {
                                                                                        ls.RemoveAt(i);
                                                                                        i--;
                                                                                        count--;
                                                                                    }
                                                                                }
                                                                                break;
                                                                            }
                                                                            }
                                                                            return on;
                                                                        })));
        }

        private static IList Flatten(IList list) {
            var result = new SaneArrayList(list.Count*2);
            Flatten(list, result);
            return result;
        }

        private static void Flatten(IList list, IList result) {
            foreach(object l in list) {
                if(l is IokeObject && IokeObject.dataOf(l) is IokeList) {
                    Flatten(GetList(l), result);
                } else {
                    result.Add(l);
                }
            }
        }

        private static void Join(IList list, StringBuilder sb, string sep, IokeObject asText, IokeObject context) {
            string realSep = "";
            foreach(object o in list) {
                sb.Append(realSep);
                if(o is IokeObject && IokeObject.dataOf(o) is IokeList) {
                    Join(GetList(o), sb, sep, asText, context);
                } else {
                    sb.Append(Text.GetText(((Message)IokeObject.dataOf(asText)).SendTo(asText, context, o)));
                }
                realSep = sep;
            }
        }

        public void Add(object obj) {
            list.Add(obj);
        }

        public static void SetList(object on, IList list) {
            ((IokeList)(IokeObject.dataOf(on))).List = list;
        }

        public static string GetInspect(object on) {
            return ((IokeList)(IokeObject.dataOf(on))).Inspect(on);
        }

        public static string GetNotice(object on) {
            return ((IokeList)(IokeObject.dataOf(on))).Notice(on);
        }
    
        public static IokeObject EmptyList(IokeObject context) {
            return context.runtime.NewList(new SaneArrayList());
        }
    
        public static IokeObject CopyList(IokeObject context, IList orig) {
            return context.runtime.NewList(new SaneArrayList(orig));
        }

        public override IokeData CloneData(IokeObject obj, IokeObject m, IokeObject context) {
            return new IokeList(new SaneArrayList(list));
        }

        public override bool IsEqualTo(IokeObject self, object other) {
            return ((other is IokeObject) && 
                    (IokeObject.dataOf(other) is IokeList) &&
                    this.list.Equals(((IokeList)IokeObject.dataOf(other)).list));
        }

        public override int HashCode(IokeObject self) {
            return this.list.GetHashCode();
        }

        public override string ToString() {
            return list.ToString();
        }

        public override string ToString(IokeObject obj) {
            return list.ToString();
        }

        public string Inspect(object obj) {
            StringBuilder sb = new StringBuilder();
            sb.Append("[");
            string sep = "";
            foreach(object o in list) {
                sb.Append(sep).Append(IokeObject.Inspect(o));
                sep = ", ";
            }
            sb.Append("]");
            return sb.ToString();
        }

        public string Notice(object obj) {
            StringBuilder sb = new StringBuilder();
            sb.Append("[");
            string sep = "";
            foreach(object o in list) {
                sb.Append(sep).Append(IokeObject.Notice(o));
                sep = ", ";
            }
            sb.Append("]");
            return sb.ToString();
        }
    }
}
