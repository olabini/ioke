// Copyright (c) 1997  Per M.A. Bothner.
// This is free software;  for terms and warranty disclaimer see ./COPYING.

package gnu.math;
import java.io.*;

/** A Unit which is the product or ratio of two other Units.
 * @author	Per Bothner
 */

class MulUnit extends Unit implements Externalizable
{
  Unit unit1;
  Unit unit2;
  int power1;
  int power2;
  MulUnit next;

  MulUnit (Unit unit1, int power1, Unit unit2, int power2)
  {
    this.unit1 = unit1;
    this.unit2 = unit2;
    this.power1 = power1;
    this.power2 = power2;
    this.dims = Dimensions.product (unit1.dims, power1, unit2.dims, power2);

    if (power1 == 1)
      factor = unit1.factor;
    else
      factor = Math.pow (unit1.factor, (double) power1);
    if (power2 < 0)
      {
	for (int i = -power2;  --i >= 0; )
	  factor /= unit2.factor;
      }
    else
      {
	for (int i = power2;  --i >= 0; )
	  factor *= unit2.factor;
      }

    next = unit1.products;
    unit1.products = this;
  }

  MulUnit (Unit unit1, Unit unit2, int power2)
  {
    this (unit1, 1, unit2, power2);
  }

  public String toString ()
  {
    StringBuffer str = new StringBuffer(60);
    str.append(unit1);
    if (power1 != 1)
      {
	str.append('^');
	str.append(power1);
      }
    if (power2 != 0)
      {
	str.append('*');
	str.append(unit2);
	if (power2 != 1)
	  {
	    str.append('^');
	    str.append(power2);
	  }
      }
    return str.toString();
  }

  public Unit sqrt ()
  {
    if ((power1 & 1) == 0 && (power2 & 1) == 0)
      return times(unit1, power1 >> 1, unit2, power2 >> 1);
    return super.sqrt();
  }

  static MulUnit lookup (Unit unit1, int power1, Unit unit2, int power2)
  {
    // Search for an existing matching MulUnit.
    for (MulUnit u = unit1.products;  u != null;  u = u.next)
      {
	if (u.unit1 == unit1 && u.unit2 == unit2
	    && u.power1 == power1 && u.power2 == power2)
	  return u;
      }
    return null;
  }

  public static MulUnit make (Unit unit1, int power1, Unit unit2, int power2)
  {
    MulUnit u = lookup(unit1, power1, unit2, power2);
    if (u != null)
      return u;
    return new MulUnit (unit1, power1, unit2, power2);
  }

  /**
   * @serialData
   */

  public void writeExternal(ObjectOutput out) throws IOException
  {
    out.writeObject(unit1);
    out.writeInt(power1);
    out.writeObject(unit2);
    out.writeInt(power2);
  }

  public void readExternal(ObjectInput in)
    throws IOException, ClassNotFoundException
  {
    unit1 = (Unit) in.readObject();
    power1 = in.readInt();
    unit2 = (Unit) in.readObject();
    power2 = in.readInt();
  }

  public Object readResolve() throws ObjectStreamException
  {
    MulUnit u = lookup(unit1, power1, unit2, power2);
    if (u != null)
      return u;
    return this;
  }
}
