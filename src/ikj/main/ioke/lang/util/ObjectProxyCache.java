package ioke.lang.util;

import java.lang.ref.ReferenceQueue;
import java.lang.ref.SoftReference;
import java.lang.ref.WeakReference;

import java.util.concurrent.locks.ReentrantLock;


/**
 * Stolen from JRuby.
 */
public abstract class ObjectProxyCache<T,A> {
    public static enum ReferenceType { WEAK, SOFT }
    
    private static final int DEFAULT_SEGMENTS = 16; // must be power of 2
    private static final int DEFAULT_SEGMENT_SIZE = 8; // must be power of 2
    private static final float DEFAULT_LOAD_FACTOR = 0.75f;
    private static final int MAX_CAPACITY = 1 << 30;
    private static final int MAX_SEGMENTS = 1 << 16;
    private static final int VULTURE_RUN_FREQ_SECONDS = 5;
    
    private static int _nextId = 0;
    
    private static synchronized int nextId() {
        return ++_nextId;
    }

    private final ReferenceType referenceType;
    private final Segment<T,A>[] segments;
    private final int segmentShift;
    private final int segmentMask;
    private final int id;
    
    public ObjectProxyCache() {
        this(DEFAULT_SEGMENTS, DEFAULT_SEGMENT_SIZE, ReferenceType.WEAK);
    }
    
    public ObjectProxyCache(ReferenceType refType) {
        this(DEFAULT_SEGMENTS, DEFAULT_SEGMENT_SIZE, refType);
    }
    
    
    public ObjectProxyCache(int numSegments, int initialSegCapacity, ReferenceType refType) {
        if (numSegments <= 0 || initialSegCapacity <= 0 || refType == null) {
            throw new IllegalArgumentException();
        }
        this.id = nextId();
        this.referenceType = refType;
        if (numSegments > MAX_SEGMENTS) numSegments = MAX_SEGMENTS;
    
        int sshift = 0;
        int ssize = 1;
        while (ssize < numSegments) {
            ++sshift;
            ssize <<= 1;
        }

        this.segmentShift = 24 - sshift;
        this.segmentMask = ssize - 1;
        this.segments = Segment.newArray(ssize);
    
        if (initialSegCapacity > MAX_CAPACITY)
            initialSegCapacity = MAX_CAPACITY;
        int cap = 1;
        while (cap < initialSegCapacity) cap <<= 1;
    
        for (int i = ssize; --i >= 0; ) {
            segments[i] = new Segment<T,A>(cap, this);
        }
    }
    
    public abstract T allocateProxy(Object javaObject, A allocator);
    
    public T get(Object javaObject) {
        if (javaObject == null) return null;
        int hash = hash(javaObject);
        return segmentFor(hash).get(javaObject, hash);
    }
    
    public T getOrCreate(Object javaObject, A allocator) {
        if (javaObject == null || allocator == null) return null;
        int hash = hash(javaObject);
        return segmentFor(hash).getOrCreate(javaObject, hash, allocator);
    }
    
    public void put(Object javaObject, T proxy) {
        if (javaObject == null || proxy == null) return;
        int hash = hash(javaObject);
        segmentFor(hash).put(javaObject, hash, proxy);
    }
    
    private static int hash(Object javaObject) {
        int h = System.identityHashCode(javaObject);
        h ^= (h >>> 20) ^ (h >>> 12);
        return h ^ (h >>> 7) ^ (h >>> 4);
    }

    private Segment<T,A> segmentFor(int hash) {
        return segments[(hash >>> segmentShift) & segmentMask];
    }
    
    public int size() {
       int size = 0;
       for (Segment<T,A> seg : segments) {
           size += seg.tableSize;
       }
       return size;
    }
    
    public String stats() {
        StringBuilder b = new StringBuilder();
        int n = 0;
        int size = 0;
        int alloc = 0;
        b.append("Segments: ").append(segments.length).append("\n");
        for (Segment<T,A> seg : segments) {
            int ssize = 0;
            int salloc = 0;
            seg.lock();
            try {
                ssize = seg.count();
                salloc = seg.entryTable.length;
            } finally {
                seg.unlock();
            }
            size += ssize;
            alloc += salloc;
            b.append("seg[").append(n++).append("]:  size: ").append(ssize)
                .append("  alloc: ").append(salloc).append("\n");
        }
        b.append("Total: size: ").append(size)
            .append("  alloc: ").append(alloc).append("\n");
        return b.toString();
    }
    
    private static interface EntryRef<T> {
        T get();
        int hash();
    }

    private static final class WeakEntryRef<T> extends WeakReference<T> implements EntryRef<T> {
        final int hash;
        WeakEntryRef(int hash, T rawObject, ReferenceQueue<Object> queue) {
            super(rawObject, queue);
            this.hash = hash;
        }
        public int hash() {
            return hash;
        }
    }

    private static final class SoftEntryRef<T> extends SoftReference<T> implements EntryRef<T> {
        final int hash;
        SoftEntryRef(int hash, T rawObject, ReferenceQueue<Object> queue) {
            super(rawObject, queue);
            this.hash = hash;
        }
        public int hash() {
            return hash;
        }
    }

    static class Entry<T> {
        final EntryRef<Object> objectRef;
        final int hash;
        final EntryRef<T> proxyRef;
        final Entry<T> next;
        
        Entry(Object object, int hash, T proxy, ReferenceType type, Entry<T> next, ReferenceQueue<Object> queue) {
            this.hash = hash;
            this.next = next;
            if (type == ReferenceType.WEAK) {
                this.objectRef = new WeakEntryRef<Object>(hash, object, queue);
                this.proxyRef = new WeakEntryRef<T>(hash, proxy, queue);
            } else {
                this.objectRef = new SoftEntryRef<Object>(hash, object, queue);
                this.proxyRef = new SoftEntryRef<T>(hash, proxy, queue);
            }
        }
        
        Entry(EntryRef<Object> objectRef, int hash, EntryRef<T> proxyRef, Entry<T> next) {
            this.objectRef = objectRef;
            this.hash = hash;
            this.proxyRef = proxyRef;
            this.next = next;
        }
        
        @SuppressWarnings("unchecked")
        static final <T> Entry<T>[] newArray(int size) {
            return new Entry[size];
        }
     }
    
    static class Segment<T,A> extends ReentrantLock {
        final ObjectProxyCache<T,A> cache;
        final ReferenceQueue<Object> referenceQueue = new ReferenceQueue<Object>();
        volatile Entry<T>[] entryTable;
        int tableSize;
        int threshold;

        Segment(int capacity, ObjectProxyCache<T,A> cache) {
            threshold = (int)(capacity * DEFAULT_LOAD_FACTOR);
            entryTable = Entry.newArray(capacity);
            this.cache = cache;
        }
        
        private void expunge() {
            Entry<T>[] table = entryTable;
            ReferenceQueue<Object> queue = referenceQueue;
            EntryRef ref;
            while ((ref = (EntryRef)queue.poll()) != null) {
                int hash;
                for (Entry<T> e = table[(hash = ref.hash()) & (table.length - 1)]; e != null; e = e.next) {
                    if (hash == e.hash && (ref == e.objectRef || ref == e.proxyRef)) {
                        remove(table, hash, e);
                        break;
                    }
                }
            }
        }
        
        private void remove(Entry<T>[] table, int hash, Entry<T> e) {
            int index = hash & (table.length - 1);
            Entry<T> first = table[index];
            for (Entry<T> n = first; n != null; n = n.next) {
                if (n == e) {
                    Entry<T> newFirst = n.next;
                    for (Entry<T> p = first; p != n; p = p.next) {
                        newFirst = new Entry<T>(p.objectRef, p.hash, p.proxyRef, newFirst);
                    }
                    table[index] = newFirst;
                    tableSize--;
                    entryTable = table; // write-volatile
                    return;
                }
            }
        }

        private int count() {
            int count = 0;
            for (Entry<T> e : entryTable) {
                while (e != null) {
                    count++;
                    e = e.next;
                }
            }
            return count;
        }

        private Entry<T>[] rehash() {
            assert tableSize == count() : "tableSize "+tableSize+" != count() "+count();
            Entry<T>[] oldTable = entryTable; // read-volatile
            int oldCapacity;
            if ((oldCapacity = oldTable.length) >= MAX_CAPACITY) {
                return oldTable;
            }
            int newCapacity = oldCapacity << 1;
            int sizeMask = newCapacity - 1;
            threshold = (int)(newCapacity * DEFAULT_LOAD_FACTOR);
            Entry<T>[] newTable = Entry.newArray(newCapacity);
            Entry<T> e;
            for (int i = oldCapacity; --i >= 0; ) {
                if ((e = oldTable[i]) != null) {
                    int idx = e.hash & sizeMask;
                    Entry<T> next;
                    if ((next = e.next) == null) {
                        // Single node in list
                        newTable[idx] = e;
                    } else {
                        // Reuse trailing consecutive sequence at same slot
                        int lastIdx = idx;
                        Entry<T> lastRun = e;
                        for (Entry<T> last = next; last != null; last = last.next) {
                            int k;
                            if ((k = last.hash & sizeMask) != lastIdx) {
                                lastIdx = k;
                                lastRun = last;
                            }
                        }
                        newTable[lastIdx] = lastRun;
                        // Clone all remaining nodes
                        for (Entry<T> p = e; p != lastRun; p = p.next) {
                            int k = p.hash & sizeMask;
                            Entry<T> m = new Entry<T>(p.objectRef, p.hash, p.proxyRef, newTable[k]);
                            newTable[k] = m;
                        }
                    }
                }
            }
            entryTable = newTable; // write-volatile
            return newTable;
        }

        void put(Object object, int hash, T proxy) {
            lock();
            try {
                expunge();
                Entry<T>[] table;
                int potentialNewSize;
                if ((potentialNewSize = tableSize + 1) > threshold) {
                    table = rehash(); // indirect read-/write- volatile
                } else {
                    table = entryTable; // read-volatile
                }
                int index;
                Entry<T> e;
                for (e = table[index = hash & (table.length - 1)]; e != null; e = e.next) {
                    if (hash == e.hash && object == e.objectRef.get()) {
                        if (proxy == e.proxyRef.get()) return;
                        remove(table, hash, e);
                        potentialNewSize--;
                        break;
                    }
                }
                e = new Entry<T>(object, hash, proxy, cache.referenceType, table[index], referenceQueue);
                table[index] = e;
                tableSize = potentialNewSize;
                entryTable = table; // write-volatile
            } finally {
                unlock();
            }
        }

        T getOrCreate(Object object, int hash, A allocator) {
            Entry<T>[] table;
            T proxy;
            for (Entry<T> e = (table = entryTable)[hash & table.length - 1]; e != null; e = e.next) {
                if (hash == e.hash && object == e.objectRef.get()) {
                    if ((proxy = e.proxyRef.get()) != null) return proxy;
                    break;
                }
            }
            lock();
            try {
                expunge();
                int potentialNewSize;
                if ((potentialNewSize = tableSize + 1) > threshold) {
                    table = rehash(); // indirect read-/write- volatile
                } else {
                    table = entryTable; // read-volatile
                }
                int index;
                Entry<T> e;
                for (e = table[index = hash & (table.length - 1)]; e != null; e = e.next) {
                    if (hash == e.hash && object == e.objectRef.get()) {
                        if ((proxy = e.proxyRef.get()) != null) return proxy;
                        // entry exists, proxy has been gc'ed. replace entry.
                        remove(table, hash, e);
                        potentialNewSize--;
                        break;
                    }
                }
                proxy = cache.allocateProxy(object, allocator);
                e = new Entry<T>(object, hash, proxy, cache.referenceType, table[index], referenceQueue);
                table[index] = e;
                tableSize = potentialNewSize;
                entryTable = table; // write-volatile
                return proxy;
            } finally {
                unlock();
            }
        }
        
        T get(Object object, int hash) {
            Entry<T>[] table;
            for (Entry<T> e = (table = entryTable)[hash & table.length - 1]; e != null; e = e.next) {
                if (hash == e.hash && object == e.objectRef.get()) {
                    return e.proxyRef.get();
                }
            }
            return null;
        }

        @SuppressWarnings("unchecked")
        static final <T,A> Segment<T,A>[] newArray(int size) {
            return new Segment[size];
        }
    }
}
