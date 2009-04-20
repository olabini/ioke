/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.test;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class StaticJavaBean {
    private static String _fooValue = "foo";
    public static String getFooValue() {
        return _fooValue;
    }

    private static String _quuxValue = "quux";
    public static String getQuuxValue() {
        return _quuxValue;
    }
    public static void setQuuxValue(String quux) {
        _quuxValue = quux;
    }

    private static boolean _barValue = true;
    public static boolean isBarValue() {
        return _barValue;
    }
    public static void setBarValue(boolean bar) {
        _barValue = bar;
    }
}// StaticJavaBean
