/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.java;

import java.net.URL;
import java.net.URLClassLoader;
import java.security.ProtectionDomain;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class IokeClassLoader extends URLClassLoader {
    private final static ProtectionDomain DEFAULT_DOMAIN = IokeClassLoader.class.getProtectionDomain();

    public IokeClassLoader(ClassLoader parent) {
        super(new URL[0], parent);
    }

    @Override
    public void addURL(URL url) {
        super.addURL(url);
    }

    public Class<?> defineClass(String name, byte[] bytes) {
        return super.defineClass(name, bytes, 0, bytes.length, DEFAULT_DOMAIN);
     }

    public Class<?> defineClass(String name, byte[] bytes, ProtectionDomain domain) {
       return super.defineClass(name, bytes, 0, bytes.length, domain);
    }
}// IokeClassLoader
