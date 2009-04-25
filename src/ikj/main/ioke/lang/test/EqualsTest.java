/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.test;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class EqualsTest {
    private String theProperty;

    public void setTheProperty(String val) {
        this.theProperty = val;
    }

    @Override
    public boolean equals(Object other) {
        if(other instanceof EqualsTest) {
            return
                (this.theProperty == null) ? 
                (((EqualsTest)other).theProperty == null) : 
                this.theProperty.equals(((EqualsTest)other).theProperty);
        }
        return false;
    }
}// EqualsTest
