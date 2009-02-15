/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.java;

import java.util.Arrays;
import java.util.Comparator;
import java.util.concurrent.ConcurrentHashMap;
import java.util.Map;
import java.util.List;
import java.util.LinkedList;

import java.lang.reflect.Method;
import java.lang.reflect.Modifier;

import org.objectweb.asm.ClassWriter;
import org.objectweb.asm.MethodVisitor;
import static org.objectweb.asm.Opcodes.*;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class JavaIntegration {
    public static Class getOrCreate(Class[] types, ClassRegistry registry) {
        sort(types);
        String name = createCompositeNameFor(types);
        if(!hasImplementation(name, registry)) {
            createImplementationFor(name, types, registry);
        }
        return getImplementationFor(name, registry);
    }

    private static void sort(Class[] types) {
        Arrays.sort(types, new Comparator<Class>() {
                public int compare(Class one, Class two) {
                    return one.getName().compareTo(two.getName());
                }
            });
    }

    private static String createCompositeNameFor(Class[] types) {
        StringBuilder sb = new StringBuilder(types.length*15);
        String sep = "";
        for(Class type : types) {
            sb.append(sep).append(type.getName());
            sep = ",";
        }
        return sb.toString();
    }

    private static boolean hasImplementation(String name, ClassRegistry registry) {
        return registry.hasImplementation(name);
    }

    private static Class getImplementationFor(String name, ClassRegistry registry) {
        return registry.getImplementation(name);
    }

    private static void createImplementationFor(String name, Class[] types, ClassRegistry registry) {
        String className = findFirstUnusedNameFor(types);
        System.err.println("have name: " + className);

        Class superClass = Object.class;
        List<Class> interfaces = new LinkedList<Class>();
        for(Class type : types) {
            if(!type.isInterface()) {
                superClass = type;
            } else {
                interfaces.add(type);
            }
        }

        ClassWriter cw = new ClassWriter(0);
        String[] ifs = new String[interfaces.size() + 1];
        int ix = 0;
        for(Class type : interfaces) {
            ifs[ix++] = p(type);
        }
        ifs[ix] = "ioke/lang/java/IokeJavaIntegrated";

        cw.visit(V1_5, ACC_PUBLIC, p(className), null, p(superClass), ifs);

        implementConstructor(cw, className, superClass);

        if(superClass != Object.class) {
            implementStubMethodsFor(cw, className, superClass);
        }

        for(Class iface : interfaces) {
            implementStubMethodsFor(cw, className, iface);
        }

        cw.visitEnd();

        byte[] b = cw.toByteArray();

        registry.defineClass(className, name, b);
    }

    private static void implementConstructor(ClassWriter cw, String className, Class superClass) {
        MethodVisitor mv = cw.visitMethod(ACC_PUBLIC, "<init>", "()V", null, null);
        mv.visitCode();
        mv.visitVarInsn(ALOAD, 0);
        mv.visitMethodInsn(INVOKESPECIAL, p(superClass), "<init>", "()V");
        mv.visitInsn(RETURN);
        mv.visitMaxs(1,1);
        mv.visitEnd();
    }

    private static void implementStubMethodsFor(ClassWriter cw, String className, Class type) {
        for(Method m : type.getDeclaredMethods()) {
            int modifiers = m.getModifiers();
            if(Modifier.isPublic(modifiers) && !Modifier.isFinal(modifiers)) {
                implementStubMethod(cw, className, type, m);
            }
        }
    }

    private static void implementStubMethod(ClassWriter cw, String className, Class type, Method m) {
        System.err.println("should implement stub method: " + m);
    }

    private static String p(String name) {
        return name.replaceAll("\\.", "/");
    }

    private static String p(Class type) {
        return type.getName().replaceAll("\\.", "/");
    }

    private static final Map<String, String> NAMES = new ConcurrentHashMap<String, String>();

    private static synchronized String findFirstUnusedNameFor(Class[] types) {
        Class mainType = null;
        for(Class type : types) {
            if(!type.isInterface()) {
                mainType = type;
                break;
            }
        }
        if(mainType == null) {
            mainType = types[0];
        }

        int number = 0;
        String baseName = mainType.getName() + "$ioke$";
        String current = baseName + (number++);

        while(NAMES.containsKey(current)) {
            current = baseName + (number++);      
        }

        NAMES.put(current, "dummy");

        return current;
    }
}// JavaIntegration
