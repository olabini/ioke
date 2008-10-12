// Copyright (c) 2000  Per M.A. Bothner.
// This is free software;  for terms and warranty disclaimer see ./COPYING.

package gnu.math;
import java.io.*;

/** A Unit that has a name. */

public class NamedUnit extends Unit implements Externalizable
{
  /** The interned name of this Unit, for example "cm". */
  String name;

  /** The value of this Unit is scale*base.
   * The value of this.factor is scale*base.factor, so scale is
   * redundant - were it not for rounding error concerns. */
  double scale;

  /** The value this was initialized from. */
  Unit base;

  /** Next NamedUnit in table bucket. */
  NamedUnit chain;

  public NamedUnit ()
  {
  }

  public NamedUnit (String name, DQuantity value)
  {
    this.name = name.intern();
    scale = value.factor;
    base = value.unt;
    init();
  }

  public NamedUnit (String name, double factor, Unit base)
  {
    this.name = name;
    this.base = base;
    scale = factor;
    init();
  }

  protected void init ()
  {
    factor = scale * base.factor;
    dims = base.dims;
    name = name.intern();
    int hash = name.hashCode();
    int index = (hash & 0x7FFFFFFF) % table.length;
    chain = table[index];
    table[index] = this;
  }

  public String getName() { return name; }

  public static NamedUnit lookup (String name)
  {
    name = name.intern();
    int hash = name.hashCode();
    int index = (hash & 0x7FFFFFFF) % table.length;
    for (NamedUnit unit = table[index];  unit != null;  unit = unit.chain)
      {
	if (unit.name == name)
	  return unit;
      }
    return null;
  }

  public static NamedUnit lookup (String name, double scale, Unit base)
  {
    name = name.intern();
    int hash = name.hashCode();
    int index = (hash & 0x7FFFFFFF) % table.length;
    for (NamedUnit unit = table[index];  unit != null;  unit = unit.chain)
      {
	if (unit.name == name && unit.scale == scale && unit.base == base)
	  return unit;
      }
    return null;
  }

  public static NamedUnit make (String name, double scale, Unit base)
  {
    NamedUnit old = lookup(name, scale, base);
    return old == null ? new NamedUnit(name, scale, base) : old;
  }

  public static NamedUnit make (String name, Quantity value)
  {
    double scale;
    if (value instanceof DQuantity)
      scale = ((DQuantity) value).factor;
    else if (value.imValue() != 0.0)
	  throw new ArithmeticException("defining " + name
					+ " using complex value");
    else
      scale = value.re().doubleValue();
    Unit base = value.unit();
    NamedUnit old = lookup(name, scale, base);
    return old == null ? new NamedUnit(name, scale, base) : old;
  }

  /**
   * @serialData Write the unit name (using writeUTF), followed by
   *   the definition (value) of this unit as a scale followed by a base.
   */

  public void writeExternal(ObjectOutput out) throws IOException
  {
    out.writeUTF(name);
    out.writeDouble(scale);
    out.writeObject(base);
  }

  public void readExternal(ObjectInput in)
    throws IOException, ClassNotFoundException
  {
    name = in.readUTF();
    scale = in.readDouble();
    base = (Unit) in.readObject();
  }

  public Object readResolve() throws ObjectStreamException
  {
    NamedUnit unit = lookup(name, scale, base);
    if (unit != null)
      return unit;
    init();
    return this;
  }
}
