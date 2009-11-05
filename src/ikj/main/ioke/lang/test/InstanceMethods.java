/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.test;

import ioke.lang.IokeObject;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class InstanceMethods {
    public InstanceMethods() {}

    public String overloaded(String s) {
        if(s == null) {
            return "overloaded(null: String)";
        } else {
            return "overloaded(String)";
        }
    }

    public String overloaded(Object s) {
        if(s == null) {
            return "overloaded(null: Object)";
        } else {
            return "overloaded(Object)";
        }
    }

    public IokeObject simpleTry(IokeObject obj) {
        return obj;
    }

    public String aChar(char i) {
        return "char(" + String.valueOf(i) + ")";
    }

    public String overloaded() {
        return "overloaded()";
    }

    public String overloaded(int i) {
        return "overloaded(int)";
    }

    public String overloaded(char i) {
        return "overloaded(char)";
    }

    public String overloaded(byte i) {
        return "overloaded(byte)";
    }

    public String overloaded(short i) {
        return "overloaded(short)";
    }

    public String overloaded(long i) {
        return "overloaded(long)";
    }

    public String overloaded(float i) {
        return "overloaded(float)";
    }

    public String overloaded(double i) {
        return "overloaded(double)";
    }

    public String overloaded(boolean i) {
        return "overloaded(boolean)";
    }

    public String overloaded(int x, int i) {
        return "overloaded(int, int)";
    }

    public String overloaded(int x, char i) {
        return "overloaded(int, char)";
    }

    public String overloaded(int x, byte i) {
        return "overloaded(int, byte)";
    }

    public String overloaded(int x, short i) {
        return "overloaded(int, short)";
    }

    public String overloaded(int x, long i) {
        return "overloaded(int, long)";
    }

    public String overloaded(int x, float i) {
        return "overloaded(int, float)";
    }

    public String overloaded(int x, double i) {
        return "overloaded(int, double)";
    }

    public String overloaded(int x, boolean i) {
        return "overloaded(int, boolean)";
    }

    public String overloaded(byte x, int i) {
        return "overloaded(byte, int)";
    }

    public String overloaded(byte x, char i) {
        return "overloaded(byte, char)";
    }

    public String overloaded(byte x, byte i) {
        return "overloaded(byte, byte)";
    }

    public String overloaded(byte x, short i) {
        return "overloaded(byte, short)";
    }

    public String overloaded(byte x, long i) {
        return "overloaded(byte, long)";
    }

    public String overloaded(byte x, float i) {
        return "overloaded(byte, float)";
    }

    public String overloaded(byte x, double i) {
        return "overloaded(byte, double)";
    }

    public String overloaded(byte x, boolean i) {
        return "overloaded(byte, boolean)";
    }

    public String overloaded(short x, int i) {
        return "overloaded(short, int)";
    }

    public String overloaded(short x, char i) {
        return "overloaded(short, char)";
    }

    public String overloaded(short x, byte i) {
        return "overloaded(short, byte)";
    }

    public String overloaded(short x, short i) {
        return "overloaded(short, short)";
    }

    public String overloaded(short x, long i) {
        return "overloaded(short, long)";
    }

    public String overloaded(short x, float i) {
        return "overloaded(short, float)";
    }

    public String overloaded(short x, double i) {
        return "overloaded(short, double)";
    }

    public String overloaded(short x, boolean i) {
        return "overloaded(short, boolean)";
    }

    public String overloaded(long x, int i) {
        return "overloaded(long, int)";
    }

    public String overloaded(long x, char i) {
        return "overloaded(long, char)";
    }

    public String overloaded(long x, byte i) {
        return "overloaded(long, byte)";
    }

    public String overloaded(long x, short i) {
        return "overloaded(long, short)";
    }

    public String overloaded(long x, long i) {
        return "overloaded(long, long)";
    }

    public String overloaded(long x, float i) {
        return "overloaded(long, float)";
    }

    public String overloaded(long x, double i) {
        return "overloaded(long, double)";
    }

    public String overloaded(long x, boolean i) {
        return "overloaded(long, boolean)";
    }

    public String overloaded(char x, int i) {
        return "overloaded(char, int)";
    }

    public String overloaded(char x, char i) {
        return "overloaded(char, char)";
    }

    public String overloaded(char x, byte i) {
        return "overloaded(char, byte)";
    }

    public String overloaded(char x, short i) {
        return "overloaded(char, short)";
    }

    public String overloaded(char x, long i) {
        return "overloaded(char, long)";
    }

    public String overloaded(char x, float i) {
        return "overloaded(char, float)";
    }

    public String overloaded(char x, double i) {
        return "overloaded(char, double)";
    }

    public String overloaded(char x, boolean i) {
        return "overloaded(char, boolean)";
    }

    public String overloaded(float x, int i) {
        return "overloaded(float, int)";
    }

    public String overloaded(float x, char i) {
        return "overloaded(float, char)";
    }

    public String overloaded(float x, byte i) {
        return "overloaded(float, byte)";
    }

    public String overloaded(float x, short i) {
        return "overloaded(float, short)";
    }

    public String overloaded(float x, long i) {
        return "overloaded(float, long)";
    }

    public String overloaded(float x, float i) {
        return "overloaded(float, float)";
    }

    public String overloaded(float x, double i) {
        return "overloaded(float, double)";
    }

    public String overloaded(float x, boolean i) {
        return "overloaded(float, boolean)";
    }

    public String overloaded(double x, int i) {
        return "overloaded(double, int)";
    }

    public String overloaded(double x, char i) {
        return "overloaded(double, char)";
    }

    public String overloaded(double x, byte i) {
        return "overloaded(double, byte)";
    }

    public String overloaded(double x, short i) {
        return "overloaded(double, short)";
    }

    public String overloaded(double x, long i) {
        return "overloaded(double, long)";
    }

    public String overloaded(double x, float i) {
        return "overloaded(double, float)";
    }

    public String overloaded(double x, double i) {
        return "overloaded(double, double)";
    }

    public String overloaded(double x, boolean i) {
        return "overloaded(double, boolean)";
    }

    public String overloaded(boolean x, int i) {
        return "overloaded(boolean, int)";
    }

    public String overloaded(boolean x, char i) {
        return "overloaded(boolean, char)";
    }

    public String overloaded(boolean x, byte i) {
        return "overloaded(boolean, byte)";
    }

    public String overloaded(boolean x, short i) {
        return "overloaded(boolean, short)";
    }

    public String overloaded(boolean x, long i) {
        return "overloaded(boolean, long)";
    }

    public String overloaded(boolean x, float i) {
        return "overloaded(boolean, float)";
    }

    public String overloaded(boolean x, double i) {
        return "overloaded(boolean, double)";
    }

    public String overloaded(boolean x, boolean i) {
        return "overloaded(boolean, boolean)";
    }
}// InstanceMethods
