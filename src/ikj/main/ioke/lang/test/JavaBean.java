/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.test;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class JavaBean {
    private String _foo;
    private boolean _bar;
    public JavaBean(String f, boolean b) {
        this._foo = f;
        this._bar = b;
    }

    public String getFooValue() {
        return _foo;
    }

    public void setFooValue(String val) {
        this._foo = val;
    }

    public boolean isBarValue() {
        return _bar;
    }

    public void setBarValue(boolean val) {
        this._bar = val;
    }
}// JavaBean
