namespace Ioke.Lang {
    using System.Collections;
    using System.Collections.Generic;

    public class Sequence {
        public class IteratorSequence : IokeData {
            private readonly IEnumerator iter;
            private bool hasNext;
            public IteratorSequence(IEnumerator iter) {
                this.iter = iter;
                if(iter != null) {
                    hasNext = iter.MoveNext();
                }
            }

            public override void Init(IokeObject obj) {
                obj.Kind = "Sequence Iterator";
                obj.MimicsWithoutCheck(obj.runtime.Sequence);

                obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the next object from this sequence if it exists. the behavior otherwise is undefined",
                                                           new TypeCheckingNativeMethod.WithNoArguments("next", obj,
                                                                                                        (method, on, args, keywords, context, message) => {
                                                                                                            IteratorSequence iss = (IteratorSequence)IokeObject.dataOf(on);
                                                                                                            object o = iss.iter.Current;
                                                                                                            iss.hasNext = iss.iter.MoveNext();
                                                                                                            return o;
                                                                                                        })));

                obj.RegisterMethod(obj.runtime.NewNativeMethod("returns true if there is another object in this sequence.",
                                                           new TypeCheckingNativeMethod.WithNoArguments("next?", obj,
                                                                                                        (method, on, args, keywords, context, message) => {
                                                                                                            IteratorSequence iss = (IteratorSequence)IokeObject.dataOf(on);
                                                                                                            return iss.hasNext ? method.runtime.True : method.runtime.False;
                                                                                                        })));
            }
        }

        public class Iterator2Sequence : IokeData {
            private readonly Range.RangeIterator iter;
            public Iterator2Sequence(Range.RangeIterator iter) {
                this.iter = iter;
            }

            public override void Init(IokeObject obj) {
                obj.Kind = "Sequence Iterator";
                obj.MimicsWithoutCheck(obj.runtime.Sequence);

                obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the next object from this sequence if it exists. the behavior otherwise is undefined",
                                                           new TypeCheckingNativeMethod.WithNoArguments("next", obj,
                                                                                                        (method, on, args, keywords, context, message) => {
                                                                                                            return ((Iterator2Sequence)IokeObject.dataOf(on)).iter.next();
                                                                                                        })));

                obj.RegisterMethod(obj.runtime.NewNativeMethod("returns true if there is another object in this sequence.",
                                                           new TypeCheckingNativeMethod.WithNoArguments("next?", obj,
                                                                                                        (method, on, args, keywords, context, message) => {
                                                                                                            return ((Iterator2Sequence)IokeObject.dataOf(on)).iter.hasNext() ? method.runtime.True : method.runtime.False;
                                                                                                        })));
            }
        }

        public class KeyValueIteratorSequence : IokeData {
            private readonly IDictionaryEnumerator iter;
            private bool hasNext;
            public KeyValueIteratorSequence(IDictionaryEnumerator iter) {
                this.iter = iter;
                if(iter != null) {
                    hasNext = iter.MoveNext();
                }
            }

            public override void Init(IokeObject obj) {
                obj.Kind = "Sequence KeyValueIterator";
                obj.MimicsWithoutCheck(obj.runtime.Sequence);

                obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the next object from this sequence if it exists. the behavior otherwise is undefined",
                                                           new TypeCheckingNativeMethod.WithNoArguments("next", obj,
                                                                                                        (method, on, args, keywords, context, message) => {
                                                                                                            KeyValueIteratorSequence iss = (KeyValueIteratorSequence)IokeObject.dataOf(on);
                                                                                                            DictionaryEntry o = (DictionaryEntry)iss.iter.Current;
                                                                                                            iss.hasNext = iss.iter.MoveNext();
                                                                                                            return method.runtime.NewPair(o.Key, o.Value);
                                                                                                        })));

                obj.RegisterMethod(obj.runtime.NewNativeMethod("returns true if there is another object in this sequence.",
                                                           new TypeCheckingNativeMethod.WithNoArguments("next?", obj,
                                                                                                        (method, on, args, keywords, context, message) => {
                                                                                                            KeyValueIteratorSequence iss = (KeyValueIteratorSequence)IokeObject.dataOf(on);
                                                                                                            return iss.hasNext ? method.runtime.True : method.runtime.False;
                                                                                                        })));
            }
        }


        public static void Init(IokeObject obj) {
            Runtime runtime = obj.runtime;
            obj.Kind = "Sequence";
            obj.MimicsWithoutCheck(runtime.Origin);
        }
    }
}
