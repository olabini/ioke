// Copyright (c) 2006  Per M.A. Bothner.
// This is free software;  for terms and warranty disclaimer see ../../COPYING.

package gnu.math;
import java.util.Date;
import java.util.Calendar;
import java.util.TimeZone;
import java.util.GregorianCalendar;
import gnu.math.IntNum;

/**
 * Represents a date and/or time.
 * Similar functionality as java.util.Calendar (and uses GregorianCalendar
 * internally) but supports arithmetic.
 * Can be for XML Schema date/time types, specifically as used in XPath/Xquery..
 */

public class DateTime extends Quantity implements Cloneable
{
  Unit unit = Unit.date;

  /** Fractional seconds, in units of nanoseconds. */
  int nanoSeconds;
  GregorianCalendar calendar;
  int mask;

  /*
  static final int REFERENCE_YEAR = 1972;
  static final int REFERENCE_MONTH = 0; // January
  static final int REFERENCE_DAY = 0; // January 1
  */

  static final int YEAR_COMPONENT = 1;
  static final int MONTH_COMPONENT = 2;
  static final int DAY_COMPONENT = 3;
  static final int HOURS_COMPONENT = 4;
  static final int MINUTES_COMPONENT = 5;
  static final int SECONDS_COMPONENT = 6;
  static final int TIMEZONE_COMPONENT = 7;

  public static final int YEAR_MASK = 1 << YEAR_COMPONENT;
  public static final int MONTH_MASK = 1 << MONTH_COMPONENT;
  public static final int DAY_MASK = 1 << DAY_COMPONENT;
  public static final int HOURS_MASK = 1 << HOURS_COMPONENT;
  public static final int MINUTES_MASK = 1 << MINUTES_COMPONENT;
  public static final int SECONDS_MASK = 1 << SECONDS_COMPONENT;
  public static final int TIMEZONE_MASK = 1 << TIMEZONE_COMPONENT;
  public static final int DATE_MASK = YEAR_MASK|MONTH_MASK|DAY_MASK;
  public static final int TIME_MASK = HOURS_MASK|MINUTES_MASK|SECONDS_MASK;

  public int components() { return mask & ~TIMEZONE_MASK; }

  public DateTime cast (int newComponents)
  {
    int oldComponents = mask & ~TIMEZONE_MASK;
    if (newComponents == oldComponents)
      return this;
    DateTime copy
      = new DateTime(newComponents, (GregorianCalendar) calendar.clone());
    if ((newComponents & ~oldComponents) != 0
        // Special case: Casting xs:date to xs:dateTime *is* allowed.
        && ! (oldComponents == DATE_MASK
              && newComponents == (DATE_MASK|TIME_MASK)))
      throw new ClassCastException("cannot cast DateTime - missing conponents");
    if (isZoneUnspecified())
      copy.mask &= ~TIMEZONE_MASK;
    else
      copy.mask |= TIMEZONE_MASK;
    int extraComponents = oldComponents & ~newComponents;
    if ((extraComponents & TIME_MASK) != 0)
      {
        copy.calendar.clear(Calendar.HOUR_OF_DAY); 
        copy.calendar.clear(Calendar.MINUTE);
        copy.calendar.clear(Calendar.SECOND);
      }
    else
      copy.nanoSeconds = nanoSeconds;
    if ((extraComponents & YEAR_MASK) != 0)
      {
        copy.calendar.clear(Calendar.YEAR);
        copy.calendar.clear(Calendar.ERA);
      }
    if ((extraComponents & MONTH_MASK) != 0)
      copy.calendar.clear(Calendar.MONTH);
    if ((extraComponents & DAY_MASK) != 0)
      copy.calendar.clear(Calendar.DATE);
    return copy;
  }

  private static final Date minDate = new Date(Long.MIN_VALUE);

  public DateTime (int mask)
  {
    calendar = new GregorianCalendar();
    // Never use Julian calendar.
    calendar.setGregorianChange(minDate);
    calendar.clear();
    this.mask = mask;
  }

  public DateTime (int mask, GregorianCalendar calendar)
  {
    this.calendar = calendar;
    this.mask = mask;
  }

  public static DateTime parse (String value, int mask)
  {
    DateTime result = new DateTime(mask);
    value = value.trim();
    int len = value.length();
    int pos = 0;
    boolean wantDate = (mask & DATE_MASK) != 0;
    boolean wantTime = (mask & TIME_MASK) != 0;
    if (wantDate)
      {
        pos = result.parseDate(value, pos, mask);
        if (wantTime)
          {
            if (pos < 0 || pos >= len || value.charAt(pos) != 'T')
              pos = -1;
            else
              pos++;
          }
      }
    if (wantTime)
      pos = result.parseTime(value, pos);
    pos = result.parseZone(value, pos);
    if (pos != len)
      throw new NumberFormatException("Unrecognized date/time '"+value+'\'');
    return result;
  }

  int parseDate(String str, int start, int mask)
  {
    if (start < 0)
      return start;
    int len = str.length();
    boolean negYear = false;
    if (start < len && str.charAt(start) == '-')
      {
        start++;
        negYear = true;
      }
    int pos = start;
    int part, year, month;
    if ((mask & YEAR_MASK) == 0)
      {
        if (! negYear)
          return -1;
        year = -1;
      }
    else
      {
        part = parseDigits(str, pos);
        year = part >> 16;
        pos = part & 0xffff;
        if (pos != start+4 && (pos <=start+4 || str.charAt(start) == '0'))
          return -1;
        if (negYear || year == 0)
          {
            calendar.set(Calendar.ERA, GregorianCalendar.BC);
            calendar.set(Calendar.YEAR, year+1);
          }
        else
          calendar.set(Calendar.YEAR, year);
      }
    if ((mask & (MONTH_MASK|DAY_MASK)) == 0)
      return pos;
    if (pos >= len || str.charAt(pos) != '-')
      return -1;
    start = ++pos;
    if ((mask & MONTH_MASK) != 0)
      {
        part = parseDigits(str, start);
        month = part >> 16;
        pos = part & 0xffff;
        if (month <= 0 || month > 12 || pos != start + 2)
          return -1;
        calendar.set(Calendar.MONTH, month-1);
        if ((mask & DAY_MASK) == 0)
          return pos;
      }
    else
      month = -1;
    if (pos >= len || str.charAt(pos) != '-')
      return -1;
    start = pos+1;
    part = parseDigits(str, start);
    int day = part >> 16;
    pos = part & 0xffff;
    if (day > 0 && pos == start+2)
      {
        int maxDay;
        if ((mask & MONTH_MASK) == 0)
          maxDay = 31;
        else
          maxDay = daysInMonth(month-1, (mask & YEAR_MASK) != 0 ? year : 2000);
        if (day <= maxDay)
          {
            calendar.set(Calendar.DATE, day);
            return pos;
          }
      }
    return -1;
  }

  public static boolean isLeapYear (int year)
  {
    return (year % 4) == 0 && ((year % 100) != 0 || (year % 400) == 0);
  }

  public static int daysInMonth (int month, int year)
  {
    switch (month)
      {
      case Calendar.APRIL:
      case Calendar.JUNE:
      case Calendar.SEPTEMBER:
      case Calendar.NOVEMBER:
        return 30;
      case Calendar.FEBRUARY:
        return isLeapYear(year) ? 29 : 28;
      default:
        return 31;
      }
  }

  public static TimeZone GMT = TimeZone.getTimeZone("GMT");

  int parseZone(String str, int start)
  {
    if (start < 0)
      return start;
    int part = parseZoneMinutes(str, start);
    if (part == 0)
      return -1;
    if (part == start)
      return start;
    int minutes = part >> 16;
    TimeZone zone;
    int pos = part & 0xffff;
    if (minutes == 0)
      zone = GMT;
    else
      zone = TimeZone.getTimeZone("GMT"+ str.substring(start, pos));
    calendar.setTimeZone(zone);
    mask |= TIMEZONE_MASK;
    return pos;
  }

  /** Return (MINUTES<<16)|END_POS if time-zone indicator was seen.
   * Returns START otherwise, or 0 on an error. */
  int parseZoneMinutes(String str, int start)
  {
    int len = str.length();
    if (start == len || start < 0)
      return start;
    char ch = str.charAt(start);
    if (ch == 'Z')
      return start+1;
    if (ch != '+' && ch != '-')
      return start;
    start++;
    int part = parseDigits(str, start);
    int hour = part >> 16;
    if (hour > 14)
      return 0;
    int minute = 60 * hour;
    int pos = part & 0xffff;
    if (pos != start+2)
      return 0;
    if (pos < len)
      {
        if (str.charAt(pos) == ':')
          {
            start = pos+1;
            part = parseDigits(str, start);
            pos = part & 0xffff;
            part >>= 16;
            if (part > 0 && (part >= 60 || hour == 14))
              return 0;
            minute += part;
            if (pos!=start+2)
              return 0;
          }
      }
    else // The minutes part is not optional.
      return 0;
    if (minute > 840)
      return 0;
    if (ch == '-')
      minute = -minute;
    return (minute << 16)|pos;
  }

  int parseTime(String str, int start)
  {
    if (start < 0)
      return start;
    int len = str.length();
    int pos = start;
    int part = parseDigits(str, start);
    int hour = part >> 16;
    pos = part & 0xffff;
    if (hour <= 24 && pos == start+2 && pos != len && str.charAt(pos) == ':')
      {
        start = pos + 1;
        part = parseDigits(str, start);
        int minute = part >> 16;
        pos = part & 0xffff;
        if (minute < 60 && pos == start+2
            && pos != len && str.charAt(pos) == ':')
          {
            start = pos + 1;
            part = parseDigits(str, start);
            int second = part >> 16;
            pos = part & 0xffff;
            // We don't allow/handle leap seconds.
            if (second < 60 && pos == start+2)
              {
                if (pos + 1 < len && str.charAt(pos) == '.'
                    && Character.digit(str.charAt(pos+1), 10) >= 0)
                  {
                    start = pos + 1;
                    pos = start;
                    int nanos = 0;
                    int nfrac = 0;
                    for (; pos < len; nfrac++, pos++)
                      {
                        int dig = Character.digit(str.charAt(pos), 10);
                        if (dig < 0)
                          break;
                        if (nfrac < 9)
                          nanos = 10 * nanos + dig;
                        else if (nfrac == 9 && dig >= 5)
                          nanos++;
                      }
                    while (nfrac++ < 9)
                      nanos = 10 * nanos;
                    nanoSeconds = nanos;
                  }
                if (hour == 24
                    && (minute != 0 || second != 0 || nanoSeconds != 0))
                  return -1;
                calendar.set(Calendar.HOUR_OF_DAY, hour);
                calendar.set(Calendar.MINUTE, minute);
                calendar.set(Calendar.SECOND, second);
                return pos;
              }
          }
      }
    return -1;
  }

  /** Return (VALUE << 16)|END. */
  private static int parseDigits(String str, int start)
  {
    int i = start;
    int val = -1;
    int len = str.length();
    while (i < len)
      {
        char ch = str.charAt(i);
        int dig = Character.digit(ch, 10);
        if (dig < 0)
          break;
        if (val > 20000)
          return 0; // possible overflow
        val = val < 0 ? dig : 10 * val + dig;
        i++;
      }
    return val < 0 ? i : (val << 16) | i;
  }

  public int getYear()
  {
    int year = calendar.get(Calendar.YEAR);
    if (calendar.get(Calendar.ERA) == GregorianCalendar.BC)
      year = 1 - year;
    return year;
  }

  public int getMonth()
  {
    return calendar.get(Calendar.MONTH) + 1;
  }

  public int getDay()
  {
    return calendar.get(Calendar.DATE);
  }

  public int getHours()
  {
    return calendar.get(Calendar.HOUR_OF_DAY);
  }

  public int getMinutes()
  {
    return calendar.get(Calendar.MINUTE);
  }

  public int getSecondsOnly ()
  {
    return calendar.get(Calendar.SECOND);
  }

  public int getWholeSeconds () // deprecated
  {
    return calendar.get(Calendar.SECOND);
  }

  public int getNanoSecondsOnly ()
  {
    return nanoSeconds;
  }

  /*
  public Object getSecondsObject ()
  {
    return IntNum.make(getWholeSeconds());
  }
  */

  /** Return -1, 0, or 1, depending on which value is greater. */
  public static int compare (DateTime date1, DateTime date2)
  {
    long millis1 = date1.calendar.getTimeInMillis();
    long millis2 = date2.calendar.getTimeInMillis();
    if (((date1.mask | date2.mask) & DATE_MASK) == 0)
      {
        if (millis1 < 0) millis1 += 24 * 60 * 60 * 1000;
        if (millis2 < 0) millis2 += 24 * 60 * 60 * 1000;
      }
    int nanos1 = date1.nanoSeconds;
    int nanos2 = date2.nanoSeconds;
    millis1 += nanos1 / 1000000;
    millis2 += nanos2 / 1000000;
    nanos1 = nanos1 % 1000000;
    nanos2 = nanos2 % 1000000;
    return millis1 < millis2 ? -1 : millis1 > millis2 ? 1
      : nanos1 < nanos2 ? -1 : nanos1 > nanos2 ? 1 : 0;
  }

  public int compare (Object obj)
  {
    if (obj instanceof DateTime)
      return compare (this, (DateTime) obj);
    return ((Numeric) obj).compareReversed (this);
  }

  public static Duration sub (DateTime date1, DateTime date2)
  {
    long millis1 = date1.calendar.getTimeInMillis();
    long millis2 = date2.calendar.getTimeInMillis();
    int nanos1 = date1.nanoSeconds;
    int nanos2 = date2.nanoSeconds;
    millis1 += nanos1 / 1000000;
    millis2 += nanos2 / 1000000;
    nanos1 = nanos1 % 1000000;
    nanos2 = nanos2 % 1000000;
    long millis = millis1 - millis2;
    long seconds = millis / 1000;
    int nanos = (int) ((millis % 1000) * 1000000 + nanos2 - nanos2);
    seconds += nanos / 1000000000;
    nanos = nanos % 1000000000;
    return Duration.make(0, seconds, nanos, Unit.second);
  }

  public DateTime withZoneUnspecified ()
  {
    if (isZoneUnspecified())
      return this;
    DateTime r = new DateTime(mask, (GregorianCalendar) calendar.clone());
    r.calendar.setTimeZone(TimeZone.getDefault());
    r.mask &= ~TIMEZONE_MASK;
    return r;
  }

  public DateTime adjustTimezone (int newOffset)
  {
    DateTime r = new DateTime(mask, (GregorianCalendar) calendar.clone());
    TimeZone zone;
    if (newOffset == 0)
      zone = GMT;
    else
      {
        StringBuffer sbuf = new StringBuffer("GMT");
        toStringZone(newOffset, sbuf);
        zone = TimeZone.getTimeZone(sbuf.toString());
      }
    r.calendar.setTimeZone(zone);
    if ((r.mask & TIMEZONE_MASK) != 0)
      {
        long millis = calendar.getTimeInMillis();
        r.calendar.setTimeInMillis(millis);
        if ((mask & TIME_MASK) == 0)
          {
            r.calendar.set(Calendar.HOUR_OF_DAY, 0); 
            r.calendar.set(Calendar.MINUTE, 0); 
            r.calendar.set(Calendar.SECOND, 0);
            r.nanoSeconds = 0;
          }
      }
    else
      r.mask |= TIMEZONE_MASK;
    return r;
  }

  public static DateTime add (DateTime x, Duration y, int k)
  {
    if (y.unit == Unit.duration
        || (y.unit == Unit.month && (x.mask & DATE_MASK) != DATE_MASK))
      throw new IllegalArgumentException("invalid date/time +/- duration combinatuion");
    DateTime r = new DateTime(x.mask, (GregorianCalendar) x.calendar.clone());
    if (y.months != 0)
      {
        int month = 12 * r.getYear() + r.calendar.get(Calendar.MONTH);
        month += k * y.months;
        int day = r.calendar.get(Calendar.DATE);
        int year, daysInMonth;
        if (month >= 12)
          {
            year = month / 12;
            month = month % 12;
            r.calendar.set(Calendar.ERA, GregorianCalendar.AD);
            daysInMonth = daysInMonth(month, year);
          }
        else
          {
            month = 11 - month;
            r.calendar.set(Calendar.ERA, GregorianCalendar.BC);
            year = (month / 12) + 1;
            month = 11 - (month % 12);
            daysInMonth = daysInMonth(month, 1);
          }
        
        if (day > daysInMonth)
          day = daysInMonth;
        r.calendar.set(year, month, day);
      }
    long nanos = x.nanoSeconds + k * (y.seconds * 1000000000L + y.nanos);
    if (nanos != 0)
      {
        if ((x.mask & TIME_MASK) == 0)
          { // Truncate to 00:00:00
            long nanosPerDay = 1000000000L * 24 * 60 * 60;
            long mod = nanos % nanosPerDay;
            if (mod < 0)
              mod += nanosPerDay;
            nanos -= mod;
          }
        long millis = r.calendar.getTimeInMillis();
        millis += (nanos / 1000000000L) * 1000;
        r.calendar.setTimeInMillis(millis);
        r.nanoSeconds = (int) (nanos % 1000000000L);
      }
    return r;
  }

  public static DateTime addMinutes (DateTime x, int y)
  {
    return addSeconds (x, 60 * y);
  }

  public static DateTime addSeconds (DateTime x, int y)
  {
    DateTime r = new DateTime(x.mask, (GregorianCalendar) x.calendar.clone());
    long nanos = y * 1000000000L;
    if (nanos != 0)
      {
        nanos = x.nanoSeconds + nanos;
        long millis = x.calendar.getTimeInMillis();
        millis += (nanos / 1000000L);
        r.calendar.setTimeInMillis(millis);
        r.nanoSeconds = (int) (nanos % 1000000L);
      }
    return r;
  }

  public Numeric add (Object y, int k)
  {
    if (y instanceof Duration)
      return DateTime.add(this, (Duration) y, k);
    if (y instanceof DateTime && k == -1)
      return DateTime.sub(this, (DateTime) y);
    throw new IllegalArgumentException ();
  }

  public Numeric addReversed (Numeric x, int k)
  {
    if (x instanceof Duration && k == 1)
      return DateTime.add(this, (Duration) x, k);
    throw new IllegalArgumentException ();
  }

  private static void append (int value, StringBuffer sbuf, int minWidth)
  {
    int start = sbuf.length();
    sbuf.append(value);
    int padding = start + minWidth - sbuf.length();
    while (--padding >= 0)
      sbuf.insert(start, '0');
  }

  public void toStringDate(StringBuffer sbuf)
  {
    int mask = components();
    if ((mask & YEAR_MASK) != 0)
      {
        int year = calendar.get(Calendar.YEAR);
        if (calendar.get(Calendar.ERA) == GregorianCalendar.BC)
          {
            year--;
            if (year != 0)
              sbuf.append('-');
          }
        append(year, sbuf, 4);
      }
    else
      sbuf.append('-');
    if ((mask & (MONTH_MASK|DAY_MASK)) != 0)
      {
        sbuf.append('-');
        if ((mask & MONTH_MASK) != 0)
          append(getMonth(), sbuf, 2);
        if ((mask & DAY_MASK) != 0)
          {
            sbuf.append('-');
            append(getDay(), sbuf, 2);
          }
      }
  }

  public void toStringTime(StringBuffer sbuf)
  {
    append(getHours(), sbuf, 2);
    sbuf.append(':');
    append(getMinutes(), sbuf, 2);
    sbuf.append(':');
    append(getWholeSeconds(), sbuf, 2);
    Duration.appendNanoSeconds(nanoSeconds, sbuf);
  }

  public boolean isZoneUnspecified ()
  {
    //TimeZone zone = calendar.getTimeZone();
    //return zone.equals(TimeZone.getDefault()); // FIXME?
    return (mask & TIMEZONE_MASK) == 0;
  }

  public int getZoneMinutes ()
  {
    return calendar.getTimeZone().getRawOffset() / 60000;
  }

  /** Get a TimeZone object for a given offset.
   * @param minutes timezone offset in minutes.
   */
  public static TimeZone minutesToTimeZone (int minutes)
  {
    if (minutes == 0)
      return DateTime.GMT;
    StringBuffer sbuf = new StringBuffer("GMT");
    toStringZone(minutes, sbuf);
    return TimeZone.getTimeZone(sbuf.toString());
  }

  public void setTimeZone (TimeZone timeZone)
  {
    calendar.setTimeZone(timeZone);
  }

  public void toStringZone(StringBuffer sbuf)
  {
    if (isZoneUnspecified())
      return;
    toStringZone(getZoneMinutes(), sbuf);
  }
  public static void toStringZone(int minutes, StringBuffer sbuf)
  {
    if (minutes == 0)
      sbuf.append('Z');
    else
      {
        if (minutes < 0)
          {
            sbuf.append('-');
            minutes = -minutes;
          }
        else
          sbuf.append('+');
        append(minutes/60, sbuf, 2);
        sbuf.append(':');
        append(minutes%60, sbuf, 2);
      }
  }

  public void toString (StringBuffer sbuf)
  {
    int mask = components();
    boolean hasDate = (mask & DATE_MASK) != 0;
    boolean hasTime = (mask & TIME_MASK) != 0;
    if (hasDate)
      {
        toStringDate(sbuf);
        if (hasTime)
          sbuf.append('T');
      }
    if (hasTime)
      toStringTime(sbuf);
    toStringZone(sbuf);
  }

  public String toString ()
  {
    StringBuffer sbuf = new StringBuffer();
    toString(sbuf);
    return sbuf.toString();
  }

  public boolean isExact ()
  {
    return (mask & TIME_MASK) == 0;
  }

  public boolean isZero ()
  {
    throw new Error("DateTime.isZero not meaningful!");
  }

  public Unit unit() { return unit; }
  public Complex number ()
  {
    throw new Error("number needs to be implemented!");
  }
}
