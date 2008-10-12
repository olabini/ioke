// Copyright (c) 1997  Per M.A. Bothner.
// This is free software;  for terms and warranty disclaimer see ./COPYING.

package gnu.math;
import java.io.*;

/** A primitive Unit of measurement (such as a meter).
 * @author Per Bothner
 */

public class BaseUnit extends NamedUnit implements Externalizable
{
  /** The name of the "dimension" this is a base unit for. */
  String dimension;

  /** BaseUnits are numberd with globally unique indexes. */
  static int base_count = 0;

  /** This is an index in the bases array.
   * The index may change if there are insertions in bases. */
  int index;

  /* Array of all existing BaseUnits.
   * This array is kept sorted (according to the compareTo method).
   * The reason is to make it easy to keep the BaseUnits in a Dimensions
   * array to be sorted "lexicographically".  One reason we want to
   * do that is to have a stable serialization representtion. *
  // static BaseUnit[] bases = null;

  /** A name for the dimension bing measured.
   * A meter has the dimension "Length".
   * BaseUnits are considered equal if their name <em>and</em>
   * their dimension are equal.  (In that case they are also identical.)
   * We use dimension as a partial guard against accidental name clashes.
   */
  public String getDimension()
  {
    return dimension;
  }

  /** Name for Unit.Empty. */
  private static final String unitName = "(name)";

  /** Should only be used for serialization, and Unit.Empty. */
  public BaseUnit()
  {
    name = unitName;
    index = 0x7fffffff;
    dims = Dimensions.Empty;
  }

  protected void init()
  {
    this.base = this;
    this.scale = 1.0;
    this.dims = new Dimensions (this);
    super.init();

    this.index = BaseUnit.base_count++;
    /*
    if (bases == null)
      bases = new BaseUnit[10];
    else if (index >= bases.length)
      {
	BaseUnit[] b = new BaseUnit[2 * index];
	System.arraycopy(bases, 0, b, 0, bases.length);
	bases = b;
      }
    bases[index] = this;
    // Make sure bases array is sorted.
    for (int i = index;  --i >= 0; )
      {
	BaseUnit old = bases[i];
	int code = compare(old, this);
	if (code == 0)
	  throw new Error("internal invariant failure");
	if (code > 0)
	  break;
	// Swap old and this, and their index fields.
	bases[i] = this;
	bases[index] = old;
	old.index = index;
	index = i;
      }
    */
  }

  public BaseUnit (String name)
  {
    this.name = name;
    init();
  }

  public BaseUnit (String name, String dimension)
  {
    this.name = name;
    this.dimension = dimension;
    init();
  }

  public int hashCode () { return name.hashCode(); }

  public Unit unit() { return this; }

  /** Look for an existing matching BaseUnit.
   * @param name name of desired BaseUnit, such as "m"
   * @param dimension a name for what the unit measures, such as "Length".
   */
  public static BaseUnit lookup(String name, String dimension)
  {
    name = name.intern();
    if (name == unitName && dimension == null)
      return Unit.Empty;
    int hash = name.hashCode();
    int index = (hash & 0x7FFFFFFF) % table.length;
    for (NamedUnit unit = table[index];  unit != null;  unit = unit.chain)
      {
	if (unit.name == name && unit instanceof BaseUnit)
	  {
	    BaseUnit bunit = (BaseUnit) unit;
	    if (bunit.dimension == dimension)
	      return bunit;
	  }
      }
    return null;
  }

  public static BaseUnit make(String name, String dimension)
  {
    BaseUnit old = lookup(name, dimension);
    return old == null ? new BaseUnit(name, dimension) : old;
  }

  public static int compare (BaseUnit unit1, BaseUnit unit2)
  {
    int code = unit1.name.compareTo(unit2.name);
    if (code != 0)
      return code;
    String dim1 = unit1.dimension;
    String dim2 = unit2.dimension;
    if (dim1 == dim2)
      return 0;
    if (dim1 == null)
      return -1;
    if (dim2 == null)
      return 1;
    return dim1.compareTo(dim2);
  }

  /**
   * @serialData Write the unit name (using writeUTF), followed.
   *   followed by the name of the dimension it is a unit for.
   *   The latter is either null or a String and is written with writeObject.
   */

  public void writeExternal(ObjectOutput out) throws IOException
  {
    out.writeUTF(name);
    out.writeObject(dimension);
  }

  public void readExternal(ObjectInput in)
    throws IOException, ClassNotFoundException
  {
    name = in.readUTF();
    dimension = (String) in.readObject();
  }

  public Object readResolve() throws ObjectStreamException
  {
    BaseUnit unit = lookup(name, dimension);
    if (unit != null)
      return unit;
    init();
    return this;
  }
}
