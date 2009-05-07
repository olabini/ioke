// Copyright (c) 1997  Per M.A. Bothner.
// This is free software;  for terms and warranty disclaimer see ./COPYING.

package gnu.math;

/** A Dimensions object represents the product or ratio of BaseUnits.
 * The idea is that in order to add two Quantities (such as 3mm + 5cm)
 * their Dimensions have to match.  Equal dimensions are also ==.
 * @author Per Bothner.
 */

public class Dimensions
{
  /** The BaseUnits that this dimension is defined in terms of.
   * The BaseUnits are in order of their index, and the last
   * element is Unit.Empty. */
  BaseUnit[] bases;
  
  /** For each baseunit in bases[i], powers[i] is the corresponding exponent.
   * It is never zero (as long as i is less than the index of Unit.Empty). */    
  short[] powers;

  int hash_code;

  /* Points to the next Dimension in the same has bucket of hashTable. */
  private Dimensions chain;

  private static Dimensions[] hashTable = new Dimensions[100];

  public final int hashCode () { return hash_code; }

  private void enterHash (int hash_code)
  {
    this.hash_code = hash_code;
    int index = (hash_code & 0x7FFFFFFF) % hashTable.length;
    chain = hashTable[index];
    hashTable[index] = this;
  }

  /** The empty Dimensions that pure numbers have. */
  public static Dimensions Empty = new Dimensions ();

  // Only used to create Dimensions.Empty. */
  private Dimensions ()
  {
    bases = new BaseUnit[1];
    bases[0] = Unit.Empty;
    enterHash (0);
  }

  /* Only used by BaseUnit constructor. */
  Dimensions (BaseUnit unit)
  {
    bases = new BaseUnit[2];
    powers = new short[1];
    bases[0] = unit;
    bases[1] = Unit.Empty;
    powers[0] = 1;
    enterHash (unit.index);
  }

  /** Create a new Dimensions corresponding to a^mul_a*b^mul_b. */
  private Dimensions (Dimensions a, int mul_a, Dimensions b, int mul_b,
		      int hash_code)
  {
    int a_i = 0, b_i = 0;
    this.hash_code = hash_code;
    for (a_i = 0;  a.bases[a_i] != Unit.Empty;  a_i++) ;
    for (b_i = 0;  b.bases[b_i] != Unit.Empty;  b_i++) ;
    int t_i = a_i + b_i + 1;
    bases = new BaseUnit[t_i];
    powers = new short[t_i];
    a_i = b_i = t_i = 0;
    for (;;)
      {
	BaseUnit a_base = a.bases[a_i];
	BaseUnit b_base = b.bases[b_i];
	int pow;
	if (a_base.index < b_base.index)
	  {
	    pow = a.powers[a_i] * mul_a;
	    a_i++;
	  }
	else if (b_base.index < a_base.index)
	  {
	    a_base = b_base;
	    pow = b.powers[b_i] * mul_b;
	    b_i++;
	  }
	else if (b_base == Unit.Empty)
	  break;
	else
	  {
	    pow = a.powers[a_i] * mul_a + b.powers[b_i] * mul_b;
	    a_i++;  b_i++;
	    if (pow == 0)
	      continue;
	  }
	if ((short) pow != pow)
	  throw new ArithmeticException ("overflow in dimensions");
	bases[t_i] = a_base;
	powers[t_i++] = (short) pow;
      }
    bases[t_i] = Unit.Empty;
    enterHash (hash_code);
  }

  /** True if this == (a^mul_a)*(b^mul_b). */
  private boolean matchesProduct (Dimensions a, int mul_a,
				  Dimensions b, int mul_b)
  {
    int a_i = 0, b_i = 0;
    for (int t_i = 0; ; )
      {
	BaseUnit a_base = a.bases[a_i];
	BaseUnit b_base = b.bases[b_i];
	int pow;
	if (a_base.index < b_base.index)
	  {
	    pow = a.powers[a_i] * mul_a;
	    a_i++;
	  }
	else if (b_base.index < a_base.index)
	  {
	    a_base = b_base;
	    pow = b.powers[b_i] * mul_b;
	    b_i++;
	  }
	else if (b_base == Unit.Empty)
	  return bases[t_i] == b_base;
	else
	  {
	    pow = a.powers[a_i] * mul_a + b.powers[b_i] * mul_b;
	    a_i++;  b_i++;
	    if (pow == 0)
	      continue;
	  }
	if (bases[t_i] != a_base || powers[t_i] != pow)
	  return false;
	t_i++;
      }
  }

  public static Dimensions product (Dimensions a, int mul_a,
				    Dimensions b, int mul_b) 
  {
    int hash = a.hashCode () * mul_a + b.hashCode () * mul_b;
    int index = (hash & 0x7FFFFFFF) % hashTable.length;
    Dimensions dim = hashTable[index];
    for ( ; dim != null;  dim = dim.chain)
      {
	if (dim.hash_code == hash && dim.matchesProduct (a, mul_a, b, mul_b))
	  return dim;
      }
    return new Dimensions (a, mul_a, b, mul_b, hash);
  }

  /** Get the exponent for a BaseUnit in this Dimensions object. */
  public int getPower (BaseUnit unit)
  {
    for (int i = 0; bases[i].index <= unit.index; i++)
      {
	if (bases[i] == unit)
	  return powers[i];
      }
    return 0;
  }

  public String toString ()
  {
    StringBuffer buf = new StringBuffer ();
    for (int i = 0;  bases[i] != Unit.Empty;  i++)
      {
	if (i > 0)
	  buf.append('*');
	buf.append (bases[i]);
	int pow = powers[i];
	if (pow != 1)
	  {
	    buf.append ('^');
	    buf.append (pow);
	  }
      }
    return buf.toString ();
  }
}
