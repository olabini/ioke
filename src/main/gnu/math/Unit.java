// Copyright (c) 1997  Per M.A. Bothner.
// This is free software;  for terms and warranty disclaimer see ./COPYING.

package gnu.math;

/* A unit of measurement, either primitive (meter) or derived (kilogram).
 * @author	Per Bothner
 */

public abstract class Unit extends Quantity
{
  Dimensions dims;
  /** The value of this Unit is factor*dims. */
  double factor;
  MulUnit products;

  /** A Unit equivalent to this unit, divided by factor.
      Same as the value of the dimensions() only. */
  Unit base;

  /** A hash table of named Units. */
  static NamedUnit[] table = new NamedUnit[100];

  public final Dimensions dimensions() { return dims; }

  public final double doubleValue() { return factor; }

  public int hashCode () { return dims.hashCode (); }

  public String getName() { return null; }

  static Unit times(Unit unit1, int power1, Unit unit2, int power2)
  {
    // First try various simplifications.
    if (unit1 == unit2)
      {
	power1 += power2;
	unit2 = Unit.Empty;
	power2 = 0;
      }
    if (power1 == 0 || unit1 == Unit.Empty)
      {
	unit1 = unit2;
	power1 = power2;
	unit2 = Unit.Empty;
	power2 = 0;
      }
    if (power2 == 0 || unit2 == Unit.Empty)
      {
	if (power1 == 1)
	  return unit1;
	if (power1 == 0)
	  return Unit.Empty;
      }
    if (unit1 instanceof MulUnit)
      {
	MulUnit munit1 = (MulUnit) unit1;
	if (munit1.unit1 == unit2)
	  return times(unit2, munit1.power1 * power1 + power2,
		       munit1.unit2, munit1.power2 * power1);
	if (munit1.unit2 == unit2)
	  return times(munit1.unit1, munit1.power1 * power1,
		       unit2, munit1.power2 * power1 + power2);
	if (unit2 instanceof MulUnit)
	  {
	    MulUnit munit2 = (MulUnit) unit2;
	    if (munit1.unit1 == munit2.unit1 && munit1.unit2 == munit2.unit2)
	      return times(munit1.unit1,
			   munit1.power1 * power1 + munit2.power1 * power2,
			   munit1.unit2,
			   munit1.power2 * power1 + munit2.power2 * power2);
	    if (munit1.unit1 == munit2.unit2 && munit1.unit2 == munit2.unit1)
	      return times(munit1.unit1,
			   munit1.power1 * power1 + munit2.power2 * power2,
			   munit1.unit2,
			   munit1.power2 * power1 + munit2.power1 * power2);
	  }
      }
    if (unit2 instanceof MulUnit)
      {
	MulUnit munit2 = (MulUnit) unit2;
	if (munit2.unit1 == unit1)
	  return times(unit1, power1 + munit2.power1 * power2,
		       munit2.unit2, munit2.power2 * power2);
	if (munit2.unit2 == unit1)
	  return times(munit2.unit1, munit2.power1 * power2,
		       unit1, power1 + munit2.power2 * power2);
      }

    return MulUnit.make(unit1, power1, unit2, power2);
  }

  public static Unit times(Unit unit1, Unit unit2)
  {
    return times(unit1, 1, unit2, 1);
  }

  public static Unit divide (Unit unit1, Unit unit2)
  {
    return times(unit1, 1, unit2, -1);
  }

  public static Unit pow (Unit unit, int power)
  {
    return times(unit, power, Unit.Empty, 0);
  }

  Unit ()
  {
    factor = 1.0;
  }

  public static NamedUnit make (String name, Quantity value)
  {
    return NamedUnit.make(name, value);
  }

  public static Unit define (String name, DQuantity value)
  {
    return new NamedUnit (name, value);
  }

  public static Unit define (String name, double factor, Unit base)
  {
    return new NamedUnit (name, factor, base);
  }

  public Complex number() { return DFloNum.one(); }
  public boolean isExact () { return false; }
  public final boolean isZero () { return false; }

  public Numeric power (IntNum y)
  {
    if (y.words != null)
      throw new ArithmeticException("Unit raised to bignum power");
    return pow (this, y.ival);
  }

  public Unit sqrt ()
  {
    if (this == Unit.Empty)
      return this;
    throw new RuntimeException ("unimplemented Unit.sqrt");
  }

  public static BaseUnit Empty = new BaseUnit();
  static { Dimensions.Empty.bases[0] = Empty; }

  public static NamedUnit lookup (String name)
  {
    return NamedUnit.lookup(name);
  }

  public String toString (double val)
  {
    String str = Double.toString(val);
    if (this == Unit.Empty)
      return str;
    else
      return str + this.toString();
  }

  public String toString (RealNum val)
  {
    return toString (val.doubleValue());
  }

  /*
  public String toString (Complex val)
  {
    String str = toString(val.re());
    RealNum im = val.im();
    if (im.isZero())
      return str;
    // This conflicts with using '@' for polar notation.
    return  str + "@" + toString(im);
  }
  */

  public String toString ()
  {
    String name = getName();
    if (name != null)
      return name;
    else if (this == Unit.Empty)
      return "unit";
    else
      return Double.toString(factor) + "<unnamed unit>";
  }

  public Unit unit ()
  {
    return this;
  }

  /** A magic factor to indicate units that have the same "dimension"
   * but not a fixed multiple.
   * E.g. "month" and "day", or money of different currencies.
   * Since they have the same dimension, they can be added to get
   * an (unimplemented) combined quantity, but they cannot be compared.
   * No general support yet, but used for time Duration.
   */
  public static double NON_COMBINABLE = 0.0;

  public static final BaseUnit meter = new BaseUnit ("m", "Length");
  public static final BaseUnit duration = new BaseUnit ("duration", "Time");
  public static final BaseUnit gram = new BaseUnit ("g", "Mass");
  public static final Unit cm = define("cm", 0.01, meter);
  public static final Unit mm = define("mm", 0.1, cm);
  public static final Unit in = define("in", 0.0254, meter);
  public static final Unit pt = define("pt", 0.0003527778, meter);
  public static final Unit pica = define("pica", 0.004233333, meter);
  public static final Unit radian = define("rad", 1.0, Unit.Empty);

  public static final NamedUnit date =
    new NamedUnit("date", NON_COMBINABLE, duration);
  public static final NamedUnit second =
    new NamedUnit("s", NON_COMBINABLE, duration);
  public static final NamedUnit month =
    new NamedUnit("month", NON_COMBINABLE, duration);
  public static final Unit minute = define("min", 60.0, second);
  public static final Unit hour = define("hour", 60.0, minute);
}
