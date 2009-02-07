/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.test;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Constructors {
    private String data;

    public Constructors() {
        this.data = "Constructors()";
    }

    public Constructors(String s) {
        if(s == null) {
            this.data = "Constructors(null: String)";
        } else {
            this.data = "Constructors(String)";
        }
    }

    public Constructors(int i) {
        this.data = "Constructors(int)";
    }

    public Constructors(long i) {
        this.data = "Constructors(long)";
    }

    public Constructors(short i) {
        this.data = "Constructors(short)";
    }

    public Constructors(char i) {
        this.data = "Constructors(char)";
    }

    public Constructors(boolean i) {
        this.data = "Constructors(boolean)";
    }

    public Constructors(float i) {
        this.data = "Constructors(float)";
    }

    public Constructors(double i) {
        this.data = "Constructors(double)";
    }

    public Constructors(Object o) {
        if(o == null) {
            this.data = "Constructors(null: Object)";
        } else {
            this.data = "Constructors(Object)";
        }
    }

    public String getData() {
        return data;
    }
}// Constructors
