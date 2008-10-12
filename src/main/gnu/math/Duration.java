package gnu.math;
import java.io.*;

public class Duration extends Quantity implements Externalizable
{
  public Unit unit;

  /** Number of whole months.  May be negative. */
  int months;

  /** Does not include any leap seconds.
   * I.e. @code{sign * ((24 * days + hours) * 60 + minutes) * 60 + seconds},
   * where {@code hours >= 0 && hours < 24 && minutes >= 0 && minutes < 60
   * && secconds >= 0 && minutes > 60}.
   */
  long seconds;

  /** Number of nanoseconds.
   * We could possibly include leap seconds in here. */
  int nanos;

  public static Duration make (int months, long seconds, int nanos, Unit unit)
  {
    Duration d = new Duration();
    d.months = months;
    d.seconds = seconds;
    d.nanos = nanos;
    d.unit = unit;
    return d;
  }

  public static Duration makeMonths(int months)
  {
    Duration d = new Duration();
    d.unit = Unit.month;
    d.months = months;
    return d;
  }

  public static Duration makeMinutes (int minutes)
  {
    Duration d = new Duration();
    d.unit = Unit.second;
    d.seconds = 60 * minutes;
    return d;
  }

  public static Duration parse (String str, Unit unit)
  {
    Duration d = Duration.valueOf(str, unit);
    if (d == null)
      throw new IllegalArgumentException("not a valid "+unit.getName()+" duration: '"+str+"'");
    return d;
  }

  public static Duration parseDuration (String str)
  {
    return parse(str, Unit.duration);
  }

  public static Duration parseYearMonthDuration (String str)
  {
    return parse(str, Unit.month);
  }


  public static Duration parseDayTimeDuration (String str)
  {
    return parse(str, Unit.second);
  }

  /** Parse a duration lexical value as specified by XML Schama.
   * Return null if invalid syntax.
   */
  public static Duration valueOf (String str, Unit unit)
  {
    str = str.trim();
    int pos = 0;
    int len = str.length();
    boolean negative;
    if (pos < len && str.charAt(pos) == '-')
      {
        negative = true;
        pos++;
      }
    else
      negative = false;
    if (pos + 1 >= len || str.charAt(pos) != 'P')
      return null;
    pos++;
    int months = 0, nanos = 0;
    long seconds = 0;
    long part = scanPart(str, pos);
    pos = ((int) part) >> 16;
    char ch = (char) part;
    if (unit == Unit.second && (ch == 'Y' || ch == 'M'))
      return null;
    if (ch == 'Y')
      {
        months = 12 * (int) (part >> 32);
        pos = ((int) part) >> 16;
        part = scanPart(str, pos);
        ch = (char) part;
      }
    if (ch == 'M')
      {
        months += (part >> 32);
        pos = ((int) part) >> 16;
        part = scanPart(str, pos);
        ch = (char) part;
      }
    if (unit == Unit.month && pos != len)
      return null;
    if (ch == 'D')
      {
        if (unit == Unit.month)
          return null;
        seconds = (long) (24 * 60 * 60) * (int) (part >> 32);
        pos = ((int) part) >> 16;
        part = scanPart (str, pos);
      }
    if (part != (pos << 16))
      return null;
    if (pos == len)
      {
        // No time part
      }
    else if (str.charAt(pos) != 'T' || ++pos == len)
      return null;
    else // saw 'T'
      {
        if (unit == Unit.month)
          return null;
        part = scanPart (str, pos);
        ch = (char) part;
        if (ch == 'H')
          {
            seconds += (60 * 60) * (int) (part >> 32);
            pos = ((int) part) >> 16;
            part = scanPart (str, pos);
            ch = (char) part;
          }
        if (ch == 'M')
          {
            seconds += 60 * (int) (part >> 32);
            pos = ((int) part) >> 16;
            part = scanPart (str, pos);
            ch = (char) part;
          }
        if (ch == 'S' || ch == '.')
          {
            seconds += (int) (part >> 32);
            pos = ((int) part) >> 16;
          }
        if (ch == '.' && pos + 1 < len
            && Character.digit(str.charAt(pos), 10) >= 0)
          {
            int nfrac = 0;
            for (; pos < len; nfrac++)
              {
                ch = str.charAt(pos++);
                int dig = Character.digit(ch, 10);
                if (dig < 0)
                  break;
                if (nfrac < 9)
                  nanos = 10 * nanos + dig;
                else if (nfrac == 9 && dig >= 5)
                  nanos++;
              }
            while (nfrac++ < 9)
              nanos = 10 * nanos;
            if (ch != 'S')
              return null;
          }
      }
    if (pos != len)
      return null;
    Duration d = new Duration();
    if (negative)
      {
        months = -months;
        seconds = -seconds;
        nanos = -nanos;
      }
    d.months = months;
    d.seconds = seconds;
    d.nanos = nanos;
    d.unit = unit;
    return d;
  }

  public Numeric add (Object y, int k)
  {
    if (y instanceof Duration)
      return Duration.add (this, (Duration) y, k);
    if (y instanceof DateTime && k == 1)
      return DateTime.add((DateTime) y, this, 1);
    throw new IllegalArgumentException ();
  }

  public Numeric mul (Object y)
  {
    if (y instanceof RealNum)
      return Duration.times(this, ((RealNum) y).doubleValue());
    return ((Numeric)y).mulReversed (this);
  }

  public Numeric mulReversed (Numeric x)
  {
    if (! (x instanceof RealNum))
      throw new IllegalArgumentException ();
    return Duration.times(this, ((RealNum) x).doubleValue());
  }

  public static double div (Duration dur1, Duration dur2)
  {
    int months1 = dur1.months;
    int months2 = dur2.months;
    double sec1 = (double) dur1.seconds + dur1.nanos * 0.000000001;
    double sec2 = (double) dur2.seconds + dur1.nanos * 0.000000001;
    if (months2 == 0 && sec2 == 0)
      throw new ArithmeticException("divide duration by zero");
    if (months2 == 0)
      {
        if (months1 == 0)
          return sec1 /sec2;
      }
    else if (sec2 == 0)
      {
        if (sec1 == 0)
          return (double) months1 / (double) months2;
      }
    throw new ArithmeticException("divide of incompatible durations");
  }

  public Numeric div (Object y)
  {
    if (y instanceof RealNum)
      {
        double dy = ((RealNum) y).doubleValue();
        if (dy == 0 || Double.isNaN(dy))
          throw new ArithmeticException("divide of duration by 0 or NaN");
        return Duration.times(this, 1.0 / dy);
      }
    if (y instanceof Duration)
      return new DFloNum(div(this, (Duration) y));
    return ((Numeric)y).divReversed (this);
  }

  public static Duration add (Duration x, Duration y, int k)
  {
    long months = (long) x.months + k * (long) y.months;
    // FIXME does not handle leap-seconds represented as multiples of
    // 10^9 in the nanos field.
    long nanos = x.seconds * 1000000000L + (long) x.nanos
      + k * (y.seconds * 1000000000L + y.nanos);
    // FIXME check for overflow
    // FIXME handle inconsistent signs.
    Duration d = new Duration();
    d.months = (int) months;
    d.seconds = (int) (nanos / 1000000000L);
    d.nanos = (int) (nanos % 1000000000L);
    if (x.unit != y.unit || x.unit == Unit.duration)
      throw new ArithmeticException("cannot add these duration types");
    d.unit = x.unit;
    return d;
  }

  public static Duration times (Duration x, double y)
  {
    if (x.unit == Unit.duration)
      throw new IllegalArgumentException("cannot multiply general duration");
    double months = x.months * y;
    if (Double.isInfinite(months) || Double.isNaN(months))
      throw new ArithmeticException("overflow/NaN when multiplying a duration");
    double nanos = (x.seconds * 1000000000L + x.nanos) * y;
    Duration d = new Duration();
    d.months = (int) Math.floor(months + 0.5);
    d.seconds = (int) (nanos / 1000000000L);
    d.nanos = (int) (nanos % 1000000000L);
    d.unit = x.unit;
    return d;
  }

  public static int compare (Duration x, Duration y)
  {
    long months = (long) x.months - (long) y.months;
    long nanos = x.seconds * 1000000000L + (long) x.nanos
      - (y.seconds * 1000000000L + y.nanos);
    if (months < 0 && nanos <= 0)
      return -1;
    if (months > 0 && nanos >= 0)
      return 1;
    if (months == 0)
      return nanos < 0 ? -1 : nanos > 0 ? 1 : 0;
    return -2;
  }

  public int compare (Object obj)
  {
    if (obj instanceof Duration)
      return compare(this, (Duration) obj);
    // Could also compare other Quanties if units match appropriately.  FIXME.
    throw new IllegalArgumentException ();
  }

  public String toString ()
  {
    StringBuffer sbuf = new StringBuffer();
    int m = months;
    long s = seconds;
    int n = nanos;
    boolean neg = m < 0 || s < 0 || n < 0;
    if (neg)
      {
        m = -m;
        s = -s;
        n = -n;
        sbuf.append('-');
      }
    sbuf.append('P');
    int y = m / 12;
    if (y != 0)
      {
        sbuf.append(y);
        sbuf.append('Y');
        m -= y * 12;
      }
    if (m != 0)
      {
        sbuf.append(m);
        sbuf.append('M');
      }
    long d = s / (24 * 60 * 60);
    if (d != 0)
      {
        sbuf.append(d);
        sbuf.append('D');
        s -= 24 * 60 * 60 * d;
      }
    if (s != 0 || n != 0)
      {
        sbuf.append('T');
        long hr = s / (60 * 60);
        if (hr != 0)
          {
            sbuf.append(hr);
            sbuf.append('H');
            s -= 60 * 60 * hr;
          }
        long mn = s / 60;
        if (mn != 0)
          {
            sbuf.append(mn);
            sbuf.append('M');
            s -= 60 * mn;
          }
        if (s != 0 || n != 0)
          {
            sbuf.append(s);
            appendNanoSeconds(n, sbuf);
            sbuf.append('S');
          }
      }
    else if (sbuf.length() == 1)
      sbuf.append(unit == Unit.month ? "0M" : "T0S");
    return sbuf.toString();
  }

  static void appendNanoSeconds (int nanoSeconds, StringBuffer sbuf)
  {
    if (nanoSeconds == 0)
      return;
    sbuf.append('.');
    int pos = sbuf.length();
    sbuf.append(nanoSeconds);
    int len = sbuf.length();
    int pad = pos + 9 - len;
    while (--pad >= 0)
      sbuf.insert(pos, '0');
    len = pos + 9;
    do { --len; } while (sbuf.charAt(len) == '0');
    sbuf.setLength(len+1);
  }

  /** Parse digits following by a terminator char
   * @return {@code (VALUE << 32)|(FOLLOWING_POS<<16)|FOLLOWING_CHAR}.
   * If there are no digits return @code{START<<16}.
   * Otherwise, on overflow or digits followed by end-of-string, return -1.
   */
  private static long scanPart (String str, int start)
  {
    int i = start;
    long val = -1;
    int len = str.length();
    while (i < len)
      {
        char ch = str.charAt(i);
        i++;
        int dig = Character.digit(ch, 10);
        if (dig < 0)
          {
            if (val < 0) return start << 16;
            return (val << 32) | (i << 16) | ((int) ch);
          }
        val = val < 0 ? dig : 10 * val + dig;
        if (val > Integer.MAX_VALUE)
          return -1; // overflow
      }
    return val < 0 ? (start << 16) : -1;
  }

  /** The number of years in the canonical representation. */
  public int getYears ()
  {
    return months / 12;
  }

  public int getMonths()
  {
    return months % 12;
  }

  public int getDays ()
  {
    return (int) (seconds / (24 * 60 * 60));
  }

  public int getHours ()
  {
    return (int) ((seconds / (60 * 60)) % 24);
  }

  public int getMinutes ()
  {
    return (int) ((seconds / 60) % 60);
  }

  public int getSecondsOnly ()
  {
    return (int) (seconds % 60);
  }

  public int getNanoSecondsOnly ()
  {
    return nanos;
  }

  public int getTotalMonths ()
  {
    return months;
  }

  public long getTotalSeconds ()
  {
    return seconds;
  }

  public long getTotalMinutes ()
  {
    return seconds / 60;
  }

  public long getNanoSeconds ()
  {
    return seconds * 1000000000L + nanos;
  }

  public boolean isZero ()
  {
    return months == 0 && seconds == 0 && nanos == 0;
  }

  public boolean isExact ()
  {
    return false;
  }

  public void writeExternal(ObjectOutput out) throws IOException
  {
    out.writeInt(months);
    out.writeLong(seconds);
    out.writeInt(nanos);
    out.writeObject(unit);
  }

  public void readExternal(ObjectInput in)
    throws IOException, ClassNotFoundException
  {
    months = in.readInt();
    seconds = in.readLong();
    nanos = in.readInt();
    unit = (Unit) in.readObject();
  }

  public Unit unit() { return unit; }
  public Complex number ()
  {
    throw new Error("number needs to be implemented!");
  }

  public int hashCode ()
  {
    return months ^ (int) seconds ^ nanos;
  }

  /** Compare for equality.
   * Ignores unit.
   */
  public static boolean equals (Duration x, Duration y)
  {
    return x.months == y.months
      && x.seconds == y.seconds
      && x.nanos == y.nanos;
  }

  /** Compare for equality.
   * Ignores unit.
   */
  public boolean equals (Object obj)
  {
    if (obj == null || ! (obj instanceof Duration))
      return false;
    return Duration.equals (this, (Duration) obj);
  }
}
