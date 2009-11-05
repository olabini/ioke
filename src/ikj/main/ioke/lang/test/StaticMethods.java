/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.test;

import ioke.lang.IokeObject;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class StaticMethods {
    public static String simple() {
        return "foo";
    }

    public static String overloaded(String s) {
        if(s == null) {
            return "overloaded(null: String)";
        } else {
            return "overloaded(String)";
        }
    }

    public static String overloaded(Object s) {
        if(s == null) {
            return "overloaded(null: Object)";
        } else {
            return "overloaded(Object)";
        }
    }

    public static IokeObject simpleTry(IokeObject obj) {
        return obj;
    }

    public static String aChar(char i) {
        return "char(" + String.valueOf(i) + ")";
    }

    public static String overloaded() {
        return "overloaded()";
    }

    public static String overloaded(int i) {
        return "overloaded(int)";
    }

    public static String overloaded(char i) {
        return "overloaded(char)";
    }

    public static String overloaded(byte i) {
        return "overloaded(byte)";
    }

    public static String overloaded(short i) {
        return "overloaded(short)";
    }

    public static String overloaded(long i) {
        return "overloaded(long)";
    }

    public static String overloaded(float i) {
        return "overloaded(float)";
    }

    public static String overloaded(double i) {
        return "overloaded(double)";
    }

    public static String overloaded(boolean i) {
        return "overloaded(boolean)";
    }

    public static String overloaded(int x, int i) {
        return "overloaded(int, int)";
    }

    public static String overloaded(int x, char i) {
        return "overloaded(int, char)";
    }

    public static String overloaded(int x, byte i) {
        return "overloaded(int, byte)";
    }

    public static String overloaded(int x, short i) {
        return "overloaded(int, short)";
    }

    public static String overloaded(int x, long i) {
        return "overloaded(int, long)";
    }

    public static String overloaded(int x, float i) {
        return "overloaded(int, float)";
    }

    public static String overloaded(int x, double i) {
        return "overloaded(int, double)";
    }

    public static String overloaded(int x, boolean i) {
        return "overloaded(int, boolean)";
    }

    public static String overloaded(byte x, int i) {
        return "overloaded(byte, int)";
    }

    public static String overloaded(byte x, char i) {
        return "overloaded(byte, char)";
    }

    public static String overloaded(byte x, byte i) {
        return "overloaded(byte, byte)";
    }

    public static String overloaded(byte x, short i) {
        return "overloaded(byte, short)";
    }

    public static String overloaded(byte x, long i) {
        return "overloaded(byte, long)";
    }

    public static String overloaded(byte x, float i) {
        return "overloaded(byte, float)";
    }

    public static String overloaded(byte x, double i) {
        return "overloaded(byte, double)";
    }

    public static String overloaded(byte x, boolean i) {
        return "overloaded(byte, boolean)";
    }

    public static String overloaded(short x, int i) {
        return "overloaded(short, int)";
    }

    public static String overloaded(short x, char i) {
        return "overloaded(short, char)";
    }

    public static String overloaded(short x, short i) {
        return "overloaded(short, short)";
    }

    public static String overloaded(short x, long i) {
        return "overloaded(short, long)";
    }

    public static String overloaded(short x, float i) {
        return "overloaded(short, float)";
    }

    public static String overloaded(short x, double i) {
        return "overloaded(short, double)";
    }

    public static String overloaded(short x, boolean i) {
        return "overloaded(short, boolean)";
    }

    public static String overloaded(long x, int i) {
        return "overloaded(long, int)";
    }

    public static String overloaded(long x, char i) {
        return "overloaded(long, char)";
    }

    public static String overloaded(long x, short i) {
        return "overloaded(long, short)";
    }

    public static String overloaded(long x, long i) {
        return "overloaded(long, long)";
    }

    public static String overloaded(long x, float i) {
        return "overloaded(long, float)";
    }

    public static String overloaded(long x, double i) {
        return "overloaded(long, double)";
    }

    public static String overloaded(long x, boolean i) {
        return "overloaded(long, boolean)";
    }

    public static String overloaded(char x, int i) {
        return "overloaded(char, int)";
    }

    public static String overloaded(char x, char i) {
        return "overloaded(char, char)";
    }

    public static String overloaded(char x, short i) {
        return "overloaded(char, short)";
    }

    public static String overloaded(char x, long i) {
        return "overloaded(char, long)";
    }

    public static String overloaded(char x, float i) {
        return "overloaded(char, float)";
    }

    public static String overloaded(char x, double i) {
        return "overloaded(char, double)";
    }

    public static String overloaded(char x, boolean i) {
        return "overloaded(char, boolean)";
    }

    public static String overloaded(float x, int i) {
        return "overloaded(float, int)";
    }

    public static String overloaded(float x, char i) {
        return "overloaded(float, char)";
    }

    public static String overloaded(float x, short i) {
        return "overloaded(float, short)";
    }

    public static String overloaded(float x, long i) {
        return "overloaded(float, long)";
    }

    public static String overloaded(float x, float i) {
        return "overloaded(float, float)";
    }

    public static String overloaded(float x, double i) {
        return "overloaded(float, double)";
    }

    public static String overloaded(float x, boolean i) {
        return "overloaded(float, boolean)";
    }

    public static String overloaded(double x, int i) {
        return "overloaded(double, int)";
    }

    public static String overloaded(double x, char i) {
        return "overloaded(double, char)";
    }

    public static String overloaded(double x, short i) {
        return "overloaded(double, short)";
    }

    public static String overloaded(double x, long i) {
        return "overloaded(double, long)";
    }

    public static String overloaded(double x, float i) {
        return "overloaded(double, float)";
    }

    public static String overloaded(double x, double i) {
        return "overloaded(double, double)";
    }

    public static String overloaded(double x, boolean i) {
        return "overloaded(double, boolean)";
    }

    public static String overloaded(boolean x, int i) {
        return "overloaded(boolean, int)";
    }

    public static String overloaded(boolean x, char i) {
        return "overloaded(boolean, char)";
    }

    public static String overloaded(boolean x, short i) {
        return "overloaded(boolean, short)";
    }

    public static String overloaded(boolean x, long i) {
        return "overloaded(boolean, long)";
    }

    public static String overloaded(boolean x, float i) {
        return "overloaded(boolean, float)";
    }

    public static String overloaded(boolean x, double i) {
        return "overloaded(boolean, double)";
    }

    public static String overloaded(boolean x, boolean i) {
        return "overloaded(boolean, boolean)";
    }
}// StaticMethods
