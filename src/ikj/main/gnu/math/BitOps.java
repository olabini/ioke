// Copyright (c) 1997  Per M.A. Bothner.
// This is free software;  for terms and warranty disclaimer see ./COPYING.

package gnu.math;

/** Implements logical (bit-wise) operations on infinite-precision integers.
 * There are no BitOps object - all the functions here are static.
 * The semantics used are the same as for Common Lisp.
 * @author Per Bothner
 */

public class BitOps
{
  private BitOps () { }

  /** Return the value of a specified bit in an IntNum. */
  public static boolean bitValue (IntNum x, int bitno)
  {
    int i = x.ival;
    if (x.words == null)
      {
	return bitno >= 32 ? i < 0 : ((i >> bitno) & 1) != 0;
      }
    else
      {
	int wordno = bitno >> 5;
	return wordno >= i ? x.words[i-1] < 0
	  : (((x.words[wordno]) >> bitno) & 1) != 0;
      }
  }
 
  /** Return true iff an IntNum and an int have any true bits in common. */
  public static boolean test (IntNum x, int y)
  {
    if (x.words == null)
      return (x.ival & y) != 0;
    return (y < 0) || (x.words[0] & y) != 0;
  }

  /** Return true iff two IntNums have any true bits in common. */
  public static boolean test (IntNum x, IntNum y)
  {
    if (y.words == null)
      return test (x, y.ival);
    else if (x.words == null)
      return test (y, x.ival);
    if (x.ival < y.ival)
      {
        IntNum temp = x;  x = y;  y = temp;
      }
    for (int i = 0;  i < y.ival;  i++)
      {
	if ((x.words[i] & y.words[i]) != 0)
	  return true;
      }
    return y.isNegative ();
  }

  /** Return the logical (bit-wise) "and" of an IntNum and an int. */
  public static IntNum and (IntNum x, int y)
  {
    if (x.words == null)
      return IntNum.make (x.ival & y);
    if (y >= 0)
      return IntNum.make (x.words[0] & y);
    int len = x.ival;
    int[] words = new int[len];
    words[0] = x.words[0] & y;
    while (--len > 0)
      words[len] = x.words[len];
    return IntNum.make (words, x.ival);
  }

  /** Return the logical (bit-wise) "and" of two IntNums. */
  public static IntNum and (IntNum x, IntNum y)
  {
    if (y.words == null)
      return and (x, y.ival);
    else if (x.words == null)
      return and (y, x.ival);
    if (x.ival < y.ival)
      {
        IntNum temp = x;  x = y;  y = temp;
      }
    int i;
    int len = y.isNegative () ? x.ival : y.ival;
    int[] words = new int[len];
    for (i = 0;  i < y.ival;  i++)
      words[i] = x.words[i] & y.words[i];
    for ( ; i < len;  i++)
      words[i] = x.words[i];
    return IntNum.make (words, len);
  }

  /** Return the logical (bit-wise) "(inclusive) or" of two IntNums. */
  public static IntNum ior (IntNum x, IntNum y)
  {
    return bitOp (7, x, y);
  }

  /** Return the logical (bit-wise) "exclusive or" of two IntNums. */
  public static IntNum xor (IntNum x, IntNum y)
  {
    return bitOp (6, x, y);
  }

  /** Return the logical (bit-wise) negation of an IntNum. */
  public static IntNum not (IntNum x)
  {
    return bitOp (12, x, IntNum.zero ());
  }

  /** Return the boolean opcode (for bitOp) for swapped operands.
   * I.e. bitOp (swappedOp(op), x, y) == bitOp (op, y, x).
   */
  public static int swappedOp (int op)
  {
    return
    "\000\001\004\005\002\003\006\007\010\011\014\015\012\013\016\017"
    .charAt (op);
  }

  /** Do one the the 16 possible bit-wise operations of two IntNums. */
  public static IntNum bitOp (int op, IntNum x, IntNum y)
  {
    switch (op)
      {
        case 0:  return IntNum.zero();
        case 1:  return and (x, y);
        case 3:  return x;
        case 5:  return y;
        case 15: return IntNum.minusOne();
      }
    IntNum result = new IntNum ();
    setBitOp (result, op, x, y);
    return result.canonicalize ();
  }

  /** Do one the the 16 possible bit-wise operations of two IntNums. */
  public static void setBitOp (IntNum result, int op, IntNum x, IntNum y)
  {
    if (y.words == null) ;
    else if (x.words == null || x.ival < y.ival)
      {
	IntNum temp = x;  x = y;  y = temp;
	op = swappedOp (op);
      }
    int xi;
    int yi;
    int xlen, ylen;
    if (y.words == null)
      {
	yi = y.ival;
	ylen = 1;
      }
    else
      {
	yi = y.words[0];
	ylen = y.ival;
      }
    if (x.words == null)
      {
	xi = x.ival;
	xlen = 1;
      }
    else
      {
	xi = x.words[0];
	xlen = x.ival;
      }
    if (xlen > 1)
      result.realloc (xlen);
    int[] w = result.words;
    int i = 0;
    // Code for how to handle the remainder of x.
    // 0:  Truncate to length of y.
    // 1:  Copy rest of x.
    // 2:  Invert rest of x.
    int finish = 0;
    int ni;
    switch (op)
      {
      case 0:  // clr
	ni = 0;
	break;
      case 1: // and
	for (;;)
	  {
	    ni = xi & yi;
	    if (i+1 >= ylen) break;
	    w[i++] = ni;  xi = x.words[i];  yi = y.words[i];
	  }
	if (yi < 0) finish = 1;
	break;
      case 2: // andc2
	for (;;)
	  {
	    ni = xi & ~yi;
	    if (i+1 >= ylen) break;
	    w[i++] = ni;  xi = x.words[i];  yi = y.words[i];
	  }
	if (yi >= 0) finish = 1;
	break;
      case 3:  // copy x
	ni = xi;
	finish = 1;  // Copy rest
	break;
      case 4: // andc1
	for (;;)
	  {
	    ni = ~xi & yi;
	    if (i+1 >= ylen) break;
	    w[i++] = ni;  xi = x.words[i];  yi = y.words[i];
	  }
	if (yi < 0) finish = 2;
	break;
      case 5: // copy y
	for (;;)
	  {
	    ni = yi;
	    if (i+1 >= ylen) break;
	    w[i++] = ni;  xi = x.words[i];  yi = y.words[i];
	  }
	break;
      case 6:  // xor
	for (;;)
	  {
	    ni = xi ^ yi;
	    if (i+1 >= ylen) break;
	    w[i++] = ni;  xi = x.words[i];  yi = y.words[i];
	  }
	finish = yi < 0 ? 2 : 1;
	break;
      case 7:  // ior
	for (;;)
	  {
	    ni = xi | yi;
	    if (i+1 >= ylen) break;
	    w[i++] = ni;  xi = x.words[i];  yi = y.words[i];
	  }
	if (yi >= 0) finish = 1;
	break;
      case 8:  // nor
	for (;;)
	  {
	    ni = ~(xi | yi);
	    if (i+1 >= ylen) break;
	    w[i++] = ni;  xi = x.words[i];  yi = y.words[i];
	  }
	if (yi >= 0)  finish = 2;
	break;
      case 9:  // eqv [exclusive nor]
	for (;;)
	  {
	    ni = ~(xi ^ yi);
	    if (i+1 >= ylen) break;
	    w[i++] = ni;  xi = x.words[i];  yi = y.words[i];
	  }
	finish = yi >= 0 ? 2 : 1;
	break;
      case 10:  // c2
	for (;;)
	  {
	    ni = ~yi;
	    if (i+1 >= ylen) break;
	    w[i++] = ni;  xi = x.words[i];  yi = y.words[i];
	  }
	break;
      case 11:  // orc2
	for (;;)
	  {
	    ni = xi | ~yi;
	    if (i+1 >= ylen) break;
	    w[i++] = ni;  xi = x.words[i];  yi = y.words[i];
	  }
	if (yi < 0)  finish = 1;
	break;
      case 12:  // c1
	ni = ~xi;
	finish = 2;
	break;
      case 13:  // orc1
	for (;;)
	  {
	    ni = ~xi | yi;
	    if (i+1 >= ylen) break;
	    w[i++] = ni;  xi = x.words[i];  yi = y.words[i];
	  }
	if (yi >= 0) finish = 2;
	break;
      case 14:  // nand
	for (;;)
	  {
	    ni = ~(xi & yi);
	    if (i+1 >= ylen) break;
	    w[i++] = ni;  xi = x.words[i];  yi = y.words[i];
	  }
	if (yi < 0) finish = 2;
	break;
      default:
      case 15:  // set
	ni = -1;
	break;
      }
    // Here i==ylen-1; w[0]..w[i-1] have the correct result;
    // and ni contains the correct result for w[i+1].
    if (i+1 == xlen)
      finish = 0;
    switch (finish)
      {
      case 0:
	if (i == 0 && w == null)
	  {
	    result.ival = ni;
	    return;
	  }
	w[i++] = ni;
	break;
      case 1:  w[i] = ni;  while (++i < xlen)  w[i] = x.words[i];  break;
      case 2:  w[i] = ni;  while (++i < xlen)  w[i] = ~x.words[i];  break;
      }
    result.ival = i;
  }

  /** Extract a bit-field as an unsigned integer. */
  public static IntNum extract (IntNum x, int startBit, int endBit)
  {
    //System.err.print("extract([");  if (x.words!=null) MPN.dprint(x.words);
    //System.err.println (","+x.ival+"], start:"+startBit+", end:"+endBit);
    if (endBit < 32)
      {
	int word0 = x.words == null ? x.ival : x.words[0];
	return IntNum.make ((word0 & ~((-1) << endBit)) >> startBit);
      }
    int x_len;
    if (x.words == null)
      {
	if (x.ival >= 0)
	  return IntNum.make (startBit >= 31 ? 0 : (x.ival >> startBit));
	x_len = 1;
      }
    else
      x_len = x.ival;
    boolean neg = x.isNegative ();
    if (endBit > 32 * x_len)
      {
	endBit = 32 * x_len;
	if (!neg && startBit == 0)
	  return x;
      }
    else
      x_len = (endBit + 31) >> 5;
    int length = endBit - startBit;
    if (length < 64)
      {
	long l;
	if (x.words == null)
	  l = x.ival >> (startBit >= 32 ? 31 : startBit);
	else
	  l = MPN.rshift_long (x.words, x_len, startBit);
	return IntNum.make (l & ~((-1L) << length));
      }
    int startWord = startBit >> 5;
    // Allocate a work buffer, which has to be large enough for the result
    // AND large enough for all words we use from x (including possible
    // partial words at both ends).
    int buf_len = (endBit >> 5) + 1 - startWord;
    int[] buf = new int[buf_len];
    if (x.words == null)  // x < 0.
      buf[0] = startBit >= 32 ? -1 : (x.ival >> startBit);
    else
      {
	x_len -= startWord;
	startBit &= 31;
	MPN.rshift0 (buf, x.words, startWord, x_len, startBit);
      }
    x_len = length >> 5;
    buf[x_len] &= ~((-1) << length);
    return IntNum.make (buf, x_len + 1);
  }

  // bit4count[I] is number of '1' bits in I.
  static final byte[] bit4_count = { 0, 1, 1, 2,  1, 2, 2, 3,
				     1, 2, 2, 3,  2, 3, 3, 4};

  public static int bitCount (int i)
  {
    int count = 0;
    while (i != 0)
      {
	count += bit4_count[i & 15];
	i >>>= 4;
      }
    return count;
  }

  public static int bitCount (int[] x, int len)
  {
    int count = 0;
    while (--len >= 0)
      count += bitCount (x[len]);
    return count;
  }

  /** Count one bits in an IntNum.
   * If argument is negative, count zero bits instead. */
  public static int bitCount (IntNum x)
  {
    int i, x_len;
    int[] x_words = x.words;
    if (x_words == null)
      {
	x_len = 1;
	i = bitCount (x.ival);
      }
    else
      {
	x_len = x.ival;
	i = bitCount (x_words, x_len);
      }
    return x.isNegative () ? x_len * 32 - i : i;
  }
}
