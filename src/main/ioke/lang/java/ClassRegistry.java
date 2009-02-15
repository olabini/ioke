/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.java;

import java.util.concurrent.ConcurrentHashMap;
import java.util.Map;

import ioke.lang.Runtime;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class ClassRegistry {
    final Runtime runtime;
    final IokeClassLoader classLoader;
    private final Map<String, String> NAMES = new ConcurrentHashMap<String, String>();

    public ClassRegistry(Runtime runtime) {
        this.runtime = runtime;
        this.classLoader = new IokeClassLoader(runtime.getClass().getClassLoader());
    }

    public void defineClass(String className, String realName, byte[] classData) {
        classLoader.defineClass(className, classData);
        NAMES.put(realName, className);
    }

    public boolean hasImplementation(String name) {
        return NAMES.containsKey(name);
    }

    public Class getImplementation(String name) {
        try {
            return Class.forName(NAMES.get(name), true, classLoader);
        } catch(Exception e) {
            // Shouldn't happen
            return null;
        }
    }
}// ClassRegistry
