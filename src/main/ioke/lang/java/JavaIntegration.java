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
import org.objectweb.asm.Label;
import org.objectweb.asm.Type;
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
//         System.err.println("have name: " + className);

        Class superClass = Object.class;
        List<Class> interfaces = new LinkedList<Class>();
        for(Class type : types) {
            if(!type.isInterface()) {
                superClass = type;
            } else {
                interfaces.add(type);
            }
        }

        ClassWriter cw = new ClassWriter(ClassWriter.COMPUTE_FRAMES);
        String[] ifs = new String[interfaces.size() + 1];
        int ix = 0;
        for(Class type : interfaces) {
            ifs[ix++] = p(type);
        }
        ifs[ix] = "ioke/lang/java/IokeJavaIntegrated";

        cw.visit(V1_5, ACC_PUBLIC, p(className), null, p(superClass), ifs);
        cw.visitField(0, "__real_ioke_proxy", "Lioke/lang/IokeObject;", null, null);

        implementConstructor(cw, className, superClass);
        implementIntegrationMethods(cw, className, superClass);

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
        MethodVisitor mv = cw.visitMethod(ACC_PUBLIC, "<init>", "(Lioke/lang/IokeObject;)V", null, null);
        mv.visitCode();
        mv.visitVarInsn(ALOAD, 0);
        mv.visitInsn(DUP);
        mv.visitMethodInsn(INVOKESPECIAL, p(superClass), "<init>", "()V");
        mv.visitVarInsn(ALOAD, 1);
        mv.visitFieldInsn(PUTFIELD, p(className), "__real_ioke_proxy", "Lioke/lang/IokeObject;");
        mv.visitInsn(RETURN);
        mv.visitMaxs(1,1);
        mv.visitEnd();
    }

    private static void implementIntegrationMethods(ClassWriter cw, String className, Class superClass) {
        MethodVisitor mv = cw.visitMethod(ACC_PUBLIC, "__get_IokeProxy", "()Lioke/lang/IokeObject;", null, null);
        mv.visitCode();
        mv.visitVarInsn(ALOAD, 0);
        mv.visitFieldInsn(GETFIELD, p(className), "__real_ioke_proxy", "Lioke/lang/IokeObject;");
        mv.visitInsn(ARETURN);
        mv.visitMaxs(1,1);
        mv.visitEnd();

        mv = cw.visitMethod(ACC_PUBLIC, "__get_IokeRuntime", "()Lioke/lang/Runtime;", null, null);
        mv.visitCode();
        mv.visitVarInsn(ALOAD, 0);
        mv.visitFieldInsn(GETFIELD, p(className), "__real_ioke_proxy", "Lioke/lang/IokeObject;");
        mv.visitFieldInsn(GETFIELD, "ioke/lang/IokeObject", "runtime", "Lioke/lang/Runtime;");
        mv.visitInsn(ARETURN);
        mv.visitMaxs(1,1);
        mv.visitEnd();
    }

    private static void implementStubMethodsFor(ClassWriter cw, String className, Class type) {
        for(Method m : type.getDeclaredMethods()) {
            int modifiers = m.getModifiers();
            if(Modifier.isPublic(modifiers) && !Modifier.isFinal(modifiers) && !Modifier.isStatic(modifiers)) {
                implementStubMethod(cw, className, type, m);
            }
        }
    }

    private static void loadParameter(MethodVisitor mv, Class parameterType, int position) {
        if(parameterType == Byte.TYPE || parameterType == Integer.TYPE || parameterType == Short.TYPE || parameterType == Character.TYPE || parameterType == Boolean.TYPE) {
            mv.visitVarInsn(ILOAD, position);
        } else if(parameterType == Long.TYPE) {
            mv.visitVarInsn(LLOAD, position);
        } else if(parameterType == Float.TYPE) {
            mv.visitVarInsn(FLOAD, position);
        } else if(parameterType == Double.TYPE) {
            mv.visitVarInsn(DLOAD, position);
        } else {
            mv.visitVarInsn(ALOAD, position);
        }
    }

    private static void loadParameterWithConversion(MethodVisitor mv, Class parameterType, int position) {
        if(parameterType == Byte.TYPE) {
            mv.visitVarInsn(ILOAD, position);
            mv.visitMethodInsn(INVOKESTATIC, "java/lang/Byte", "valueOf", "(B)Ljava/lang/Byte;");
        } else if(parameterType == Integer.TYPE) {
            mv.visitVarInsn(ILOAD, position);
            mv.visitMethodInsn(INVOKESTATIC, "java/lang/Integer", "valueOf", "(I)Ljava/lang/Integer;");
        } else if(parameterType == Short.TYPE) {
            mv.visitVarInsn(ILOAD, position);
            mv.visitMethodInsn(INVOKESTATIC, "java/lang/Short", "valueOf", "(S)Ljava/lang/Short;");
        } else if(parameterType == Character.TYPE) {
            mv.visitVarInsn(ILOAD, position);
            mv.visitMethodInsn(INVOKESTATIC, "java/lang/Character", "valueOf", "(C)Ljava/lang/Character;");
        } else if(parameterType == Long.TYPE) {
            mv.visitVarInsn(LLOAD, position);
            mv.visitMethodInsn(INVOKESTATIC, "java/lang/Long", "valueOf", "(J)Ljava/lang/Long;");
        } else if(parameterType == Float.TYPE) {
            mv.visitVarInsn(FLOAD, position);
            mv.visitMethodInsn(INVOKESTATIC, "java/lang/Float", "valueOf", "(F)Ljava/lang/Float;");
        } else if(parameterType == Double.TYPE) {
            mv.visitVarInsn(DLOAD, position);
            mv.visitMethodInsn(INVOKESTATIC, "java/lang/Double", "valueOf", "(D)Ljava/lang/Double;");
        } else {
            mv.visitVarInsn(ALOAD, position);
        }
    }

    private static final String P_JAVA_INVOCATION_HELPER = p(JavaInvocationHelper.class);

    private static void implementStubMethod(ClassWriter cw, String className, Class type, Method m) {
//         System.err.println("should implement stub method: " + m);
        MethodVisitor mv = cw.visitMethod(ACC_PUBLIC, m.getName(), sig(m), null, null);
        Class retType = m.getReturnType();
        mv.visitCode();

        if(!type.isInterface()) {
            mv.visitVarInsn(ALOAD, 0);
            mv.visitLdcInsn(m.getName());
            mv.visitMethodInsn(INVOKESTATIC, P_JAVA_INVOCATION_HELPER, "hasProxyMethod", "(Lioke/lang/java/IokeJavaIntegrated;Ljava/lang/String;)Z");
            mv.visitInsn(ICONST_0);
            Label els = new Label();
            mv.visitJumpInsn(IF_ICMPNE, els);
            
            mv.visitVarInsn(ALOAD, 0);
            Class[] params = m.getParameterTypes();
            int i=1;
            for(Class pType : params) {
                loadParameter(mv, pType, i++);
            }

            mv.visitMethodInsn(INVOKESPECIAL, p(type), m.getName(), sig(m));

            if(retType == Void.TYPE) {
                mv.visitInsn(RETURN);
            } else if(retType == Byte.TYPE || retType == Integer.TYPE || retType == Short.TYPE || retType == Character.TYPE || retType == Boolean.TYPE) {
                mv.visitInsn(IRETURN);
            } else if(retType == Long.TYPE) {
                mv.visitInsn(LRETURN);
            } else if(retType == Float.TYPE) {
                mv.visitInsn(FRETURN);
            } else if(retType == Double.TYPE) {
                mv.visitInsn(DRETURN);
            } else {
                mv.visitInsn(ARETURN);
            }

            mv.visitLabel(els);
        }

        mv.visitVarInsn(ALOAD, 0);
        Class[] params = m.getParameterTypes();
        int i=1;
        mv.visitIntInsn(BIPUSH, params.length);
        mv.visitTypeInsn(ANEWARRAY, "java/lang/Object");
        for(Class pType : params) {
            mv.visitInsn(DUP);
            mv.visitIntInsn(BIPUSH, i-1); 
            loadParameterWithConversion(mv, pType, i++);
            mv.visitInsn(AASTORE);
        }
        
        mv.visitLdcInsn(m.getName());

        if(retType == Void.TYPE) {
            mv.visitMethodInsn(INVOKESTATIC, P_JAVA_INVOCATION_HELPER, "voidInvocation", "(Lioke/lang/java/IokeJavaIntegrated;[Ljava/lang/Object;Ljava/lang/String;)V");
            mv.visitInsn(RETURN);
        } else if(retType == Byte.TYPE) {
            mv.visitMethodInsn(INVOKESTATIC, P_JAVA_INVOCATION_HELPER, "byteInvocation", "(Lioke/lang/java/IokeJavaIntegrated;[Ljava/lang/Object;Ljava/lang/String;)B");
            mv.visitInsn(IRETURN);
        } else if(retType == Integer.TYPE) {
            mv.visitMethodInsn(INVOKESTATIC, P_JAVA_INVOCATION_HELPER, "intInvocation", "(Lioke/lang/java/IokeJavaIntegrated;[Ljava/lang/Object;Ljava/lang/String;)I");
            mv.visitInsn(IRETURN);
        } else if(retType == Short.TYPE) {
            mv.visitMethodInsn(INVOKESTATIC, P_JAVA_INVOCATION_HELPER, "shortInvocation", "(Lioke/lang/java/IokeJavaIntegrated;[Ljava/lang/Object;Ljava/lang/String;)S");
            mv.visitInsn(IRETURN);
        } else if(retType == Character.TYPE) {
            mv.visitMethodInsn(INVOKESTATIC, P_JAVA_INVOCATION_HELPER, "charInvocation", "(Lioke/lang/java/IokeJavaIntegrated;[Ljava/lang/Object;Ljava/lang/String;)C");
            mv.visitInsn(IRETURN);
        } else if(retType == Boolean.TYPE) {
            mv.visitMethodInsn(INVOKESTATIC, P_JAVA_INVOCATION_HELPER, "booleanInvocation", "(Lioke/lang/java/IokeJavaIntegrated;[Ljava/lang/Object;Ljava/lang/String;)Z");
            mv.visitInsn(IRETURN);
        } else if(retType == Long.TYPE) {
            mv.visitMethodInsn(INVOKESTATIC, P_JAVA_INVOCATION_HELPER, "longInvocation", "(Lioke/lang/java/IokeJavaIntegrated;[Ljava/lang/Object;Ljava/lang/String;)J");
            mv.visitInsn(LRETURN);
        } else if(retType == Float.TYPE) {
            mv.visitMethodInsn(INVOKESTATIC, P_JAVA_INVOCATION_HELPER, "floatInvocation", "(Lioke/lang/java/IokeJavaIntegrated;[Ljava/lang/Object;Ljava/lang/String;)F");
            mv.visitInsn(FRETURN);
        } else if(retType == Double.TYPE) {
            mv.visitMethodInsn(INVOKESTATIC, P_JAVA_INVOCATION_HELPER, "doubleInvocation", "(Lioke/lang/java/IokeJavaIntegrated;[Ljava/lang/Object;Ljava/lang/String;)D");
            mv.visitInsn(DRETURN);
        } else {
            mv.visitLdcInsn(retType.getName());
            mv.visitMethodInsn(INVOKESTATIC, "java/lang/Class", "forName", "(Ljava/lang/String;)Ljava/lang/Class;");
            mv.visitMethodInsn(INVOKESTATIC, P_JAVA_INVOCATION_HELPER, "objectInvocation", "(Lioke/lang/java/IokeJavaIntegrated;[Ljava/lang/Object;Ljava/lang/String;Ljava/lang/Class;)Ljava/lang/Object;");
            mv.visitTypeInsn(CHECKCAST, p(retType));
            mv.visitInsn(ARETURN);
        }
        
        mv.visitMaxs(1,1);
        mv.visitEnd();
    }

    private static String sig(Method m) {
        return Type.getMethodDescriptor(m);
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
