
use("ispec")

describe("parsing",
  describe("numbers",
    it("should be possible to parse a 0",
      0 should == 0)

    it("should be possible to parse a 1",
      1 should == 1)

    it("should be possible to parse a longer number",
      132342534 should == 132342534)

    it("should be possible to parse a really long number",
      112142342353453453453453453475434574675674564756896765786781121213200000 should == 112142342353453453453453453475434574675674564756896765786781121213200000)

    it("should return the same number for several parses",
      1 should be same(1))
  )

  describe("hexadecimal numbers",
    it("should be possible to parse a 0",
      0x0 should == 0)

    it("should be possible to parse a 1",
      0x1 should == 1)

    it("should be possible to parse a larger number",
      0xA should == 10
      0xb should == 11
      0xC should == 12
      0xD should == 13
      0xe should == 14
      0xF should == 15
      0xFA111CD should == 262214093
    )

    it("should be possible to parse a really large number",
      0xFAD23234235FFFFFF4434334534500000000000232345234FFDDDDDDD should == 422632681289240890518030477270484810255193915833100047461304598650333
    )
  )
)    

describe(Number,
  it("should have the correct kind",
    Number should have kind("Number"))

  it("should mimic Comparing",
    Number should mimic(Mixins Comparing))

  describe("zero?",
    it("should return true for int zero",
      0 should be zero)
    
    it("should return true for real zero",
      0.0 should be zero)

    it("should return false for a negative value",
      -1 should not be zero)

    it("should return false for a real > 0.0",
      0.1 should not be zero)

    it("should return false for an int > 0",
      1 should not be zero)
  )

  describe("negation",
    it("should return zero for zero",
      0 negation should == 0)

    it("should return 1 for -1",
      -1 negation should == 1)

    it("should return -1 for 1",
      1 negation should == -1)

    it("should return a large positive number for a large negative number",
      -353654645676451123345674 negation should == 353654645676451123345674)

    it("should return a large negative number for a large positive number",
      353654645676451123345674 negation should == -353654645676451123345674)
  )

  describe("abs",
    it("should return zero for zero",
      0 abs should == 0)
    
    it("should return the negation for negative number",
      -1 abs should == 1)

    it("should return the receiver for positive number",
      1 abs should == 1)

    it("should return a large positive number for a large negative number",
      -353654645676451123345674 abs should == 353654645676451123345674)
  )

  describe("===",
    it("should check for mimicness if receiver is Number",
      Number should === Number
      Number should === Number Rational
      Number should === Number Decimal
      Number should === 123
      Number should === 123.3
      Number should === (1/3)
      Number should not === Ground
      Number should not === Origin
    )
  )

  describe(Number Real,
    it("should have the correct kind",
      Number Real should have kind("Number Real"))

    it("should mimic Number",
      Number Real should mimic(Number))

    describe("===",
      it("should check for mimicness if receiver is Number Real",
        Number Real should === Number Real
        Number Real should === Number Rational
        Number Real should === Number Decimal
        Number Real should === 123
        Number Real should === 123.3
        Number Real should === (1/3)
        Number Real should not === Number
        Number Real should not === Origin
      )
    )
  )

  describe(Number Rational,
    it("should have the correct kind",
      Number Rational should have kind("Number Rational"))

    it("should mimic Number Real",
      Number Rational should mimic(Number Real))

    describe("===",
      it("should check for mimicness if receiver is Number Rational",
        Number Rational should === Number Rational
        Number Rational should === 123
        Number Rational should === (1/3)
        Number Rational should not === Number
        Number Rational should not === Number Real
        Number Rational should not === Origin
      )
      
      it("should check for equalness if receiver is not Number Rational",
        0 should === 0
        0 should === 0.0
        0 should not === 1
        (-234) should === -234
        12434 should not === 0.0
        12434 should === 12434
      )
    )

    describe("<=>",
      it("should return 0 for the same number",
        (0<=>0) should == 0
        (1<=>1) should == 0
        (10<=>10) should == 0
        (12413423523452345345345<=>12413423523452345345345) should == 0
        (-1<=> -1) should == 0
      )

      it("should return 1 when the left number is larger than the right",
        (1 <=> 0) should == 1
        (2 <=> 1) should == 1
        (10 <=> 9) should == 1
        (12413423523452345345345 <=> 12413423523452345345344) should == 1
        (0 <=> -1) should == 1
        (1 <=> -1) should == 1
      )

      it("should return 1 when the left number is smaller than the right",
        (0 <=> 1) should == -1
        (1 <=> 2) should == -1
        (9 <=> 10) should == -1
        (12413423523452345345344 <=> 12413423523452345345345) should == -1
        (-1 <=> 0) should == -1
        (-1 <=> 1) should == -1
      )

      it("should convert itself to a decimal if the argument is a decimal",
        (1<=>1.0) should == 0
        (1<=>1.1) should == -1
        (1<=>0.9) should == 1
      )

      it("should convert its argument to a rational if its not a number or a decimal",
        x = Origin mimic
        x asRational = method(42)
        (42 <=> x) should == 0
      )

      it("should return nil if it can't be converted and there is no way of comparing",
        (1 <=> Origin mimic) should be nil
      )

      it("should validate type of receiver",
        Number Rational should checkReceiverTypeOn(:"<=>", 4)
      )
    )

    describe("-", 
      it("should return 0 for the difference between 0 and 0", 
        (0-0) should == 0
      )
      
      it("should return the difference between really large numbers", 
        (123435334645674745675675757-123435334645674745675675756) should == 1
        (123435334645674745675675757-1) should == 123435334645674745675675756
        (123435334645674745675675757-24334534544345345345345) should == 123411000111130400330330412
      )
      
      it("should return the difference between smaller numbers", 
        (1-1) should == 0
        (0-1) should == -1
        (2-1) should == 1
        (10-5) should == 5
        (234-30) should == 204
        (30-35) should == -5
      )
      
      it("should return the difference between negative numbers", 
        ((0-1)-1) should == -2
        ((0-1)-5) should == -6
        ((0-1)-(0-5)) should == 4
        ((0-10)-5) should == -15
        ((0-10)-(0-5)) should == -5
        ((0-2545345345346547456756)-(0-2545345345346547456755)) should == -1
      )

      it("should return the number when 0 is the argument", 
        (-1-0) should == -1
        (10-0) should == 10
        (1325234534634564564576367-0) should == 1325234534634564564576367
      )
      
      it("should convert itself to a decimal if the argument is a decimal", 
        (1-0.6) should == 0.4
        (3-1.2) should == 1.8
      )

      it("should convert its argument to a rational if its not a number or a decimal", 
        x = Origin mimic
        x asRational = method(42)
        (43 - x) should == 1
      )
      
      it("should signal a condition if it can't be converted and there is no way of subtracting",
        fn(1 - Origin mimic) should signal(Condition Error Type IncorrectType)
      )

      it("should validate type of receiver",
        Number Rational should checkReceiverTypeOn(:"-", 4)
      )
    )

    describe("+", 
      it("should return 0 for the sum of 0 and 0", 
        (0+0) should == 0
      )

      it("should return the sum of really large numbers", 
        (234235345636345634567345675467+1) should == 234235345636345634567345675468
        (21342342342345345+778626453756754687567865785678) should == 778626453756776029910208131023
        (234234+63456345745676574567571345456345645675674567878567856785678657856568768) should == 63456345745676574567571345456345645675674567878567856785678657856803002
      )

      it("should return the sum of smaller numbers", 
        (1+1) should == 2
        (10+1) should == 11
        (15+15) should == 30
        (16+15) should == 31
      )

      it("should return the sum of negative numbers", 
        (1+(0-1)) should == 0
        ((0-1)+2) should == 1
        ((0-1)+(0-1)) should == -2
      )

      it("should return the number when 0 is the receiver", 
        (0+1) should == 1
        (0+(0-1)) should == -1
        (0+124423) should == 124423
        (0+34545636745678657856786786785678) should == 34545636745678657856786786785678
      )

      it("should return the number when 0 is the argument", 
        (1+0) should == 1
        ((0-1)+0) should == -1
        (124423+0) should == 124423
        (34545636745678657856786786785678+0) should == 34545636745678657856786786785678
      )

      it("should convert itself to a decimal if the argument is a decimal", 
        (1+0.6) should == 1.6
        (3+1.2) should == 4.2
      )

      it("should convert its argument to a rational if its not a number or a decimal", 
        x = Origin mimic
        x asRational = method(41)
        (1 + x) should == 42
      )
      
      it("should signal a condition if it can't be converted and there is no way of adding",
        fn(1 + Origin mimic) should signal(Condition Error Type IncorrectType)
      )

      it("should validate type of receiver",
        Number Rational should checkReceiverTypeOn(:"+", 4)
      )
    )

    describe("*", 
      it("should multiply with 0", 
        (1*0) should == 0
        (34253453*0) should == 0
        (-1*0) should == 0
      )

      it("should return the same number when multiplying with 1", 
        (1*1) should == 1
        (34253453*1) should == 34253453
        (-1*1) should == -1
      )

      it("should return a really large number when multiplying large numbers", 
        (2345346456745722*12213212323899088545) should == 28644214249339912541248622627954490
      )

      it("should return a negative number when multiplying with one negative number", 
        (-21*2) should == -42
      )

      it("should return a positive number when multiplying with two negative numbers", 
        (-21* -2) should == 42
      )

      it("should convert itself to a decimal if the argument is a decimal", 
        (1*0.6) should == 0.6
        (3*1.2) should == 3.6
      )

      it("should convert its argument to a rational if its not a number or a decimal", 
        x = Origin mimic
        x asRational = method(21)
        (2 * x) should == 42
      )
      
      it("should signal a condition if it can't be converted and there is no way of multiplying",
        fn(1 * Origin mimic) should signal(Condition Error Type IncorrectType)
      )

      it("should validate type of receiver",
        Number Rational should checkReceiverTypeOn(:"*", 4)
      )
    )

    describe("**", 
      it("should return 1 for raising to 0",
        (1**0) should == 1
      )

      it("should return the number when raising to 1",
        (2**1) should == 2
      )

      it("should raise a number",
        (2**2) should == 4
        (2**3) should == 8
      )

      it("should raise a number to a large number",
        (2 ** 40) should == 1099511627776
      )

      it("should convert its argument to a rational if its not a number or a decimal", 
        x = Origin mimic
        x asRational = method(3)
        (2 ** x) should == 8
      )

      it("should signal a condition if it isn't a rational and can't be converted", 
        fn(1 ** Origin mimic) should signal(Condition Error Type IncorrectType)
      )

      it("should validate type of receiver",
        Number Rational should checkReceiverTypeOn(:"**", 4)
      )
    )
    
    describe("/", 
      it("should cause a condition when dividing with 0", 
        fn(10/0) should signal(Condition Error Arithmetic DivisionByZero)
      )

      it("should divide simple numbers", 
        (2/1)   should == 2
        (4/2)   should == 2
        (200/5) should == 40
      )

      it("should return a rational when dividing uneven numbers", 
        x = 8192/10
        x should mimic(Number Ratio)
        x should == (4096/5)

        x = 3/2
        x should mimic(Number Ratio)
        x should not == 1
        x should == (3/2)

        x = 5/2
        x should mimic(Number Ratio)
        x should not == 2
        x should == (5/2)

        x = 1/2
        x should mimic(Number Ratio)
        x should not == 0
        x should == (1/2)
      )

      it("should divide negative numbers correctly", 
        (-8200/10) should == -820
      )

      it("should divide with a negative dividend correctly", 
        (8200/ -10) == -820
      )

      it("should divide a negative number with a negative dividend", 
        (-8200/ -10) == 820
      )

      it("should convert itself to a decimal if the argument is a decimal", 
        (1/0.5) should == 2.0
        (3/1.2) should == 2.5
      )
      
      it("should convert its argument to a number if its not a number or a decimal", 
        x = Origin mimic
        x asRational = method(2)
        (42 / x) should == 21
      )

      it("should signal a condition if it isn't a number and can't be converted", 
        fn(1 / Origin mimic) should signal(Condition Error Type IncorrectType)
      )

      it("should validate type of receiver",
        Number Rational should checkReceiverTypeOn(:"/", 4)
      )
    )

    describe("==", 
      it("should return true for the same number", 
        x = 1. x should == x
        x = 10. x should == x
        x = (0-20). x should == x
      )

      it("should not return true for unequal numbers", 
        1 should not == 2
        1 should not == 200000
        1123223 should not == 65756756756
        (0-1) should not == 2
      )
      
      it("should return true for the result of equal number calculations", 
        (1+1) should == 2
        (2+1) should == (1+2)
      )
      
      it("should work correctly when comparing zeroes", 
        0 should == 0
        1 should not == 0
        0 should not == 1
      )

      it("should work correctly when comparing negative numbers", 
        (-19) should == -19
        (-19) should not == -20
      )

      it("should work correctly when comparing large positive numbers", 
        123234534675676786789678985463456345 should == 123234534675676786789678985463456345
        8888856676776 should == 8888856676776
      )

      it("should convert itself to a decimal if the argument is a decimal", 
        2 should == 2.0
        2 should not == 2.1
      )

      it("should return false for unrelated objects", 
        2 should not == "foo"
        2 should not == :blarg
      )

      it("should validate type of receiver",
        Number Rational should checkReceiverTypeOn(:"==", 4)
      )
    )
    
    describe("asText", 
      it("should return a representation of 0", 
        0 asText should == "0"
      )

      it("should return a representation of a Ratio", 
        (1/3) asText should == "1/3"
      )

      it("should return a representation of a small positive number", 
        1 asText should == "1"
        12 asText should == "12"
        9232423 asText should == "9232423"
      )
      
      it("should return a representation of a large positive number", 
        65535 asText should == "65535"
        65536 asText should == "65536"
        1235345341231298989793249879238543956783485384758333478526 asText should == "1235345341231298989793249879238543956783485384758333478526"
        99999999999999999999999999 asText should == "99999999999999999999999999"
      )

      it("should return a representation of a negative number", 
        (-65535) asText should == "-65535"
        (-65536) asText should == "-65536"
        (-1) asText should == "-1"
        (-645654) asText should == "-645654"
      )
    )

    describe("inspect",
      it("should validate type of receiver",
        Number Rational should checkReceiverTypeOn(:"inspect")
        x = Origin mimic
        x cell("inspect") = Number Rational cell("inspect")
        fn(x inspect) should signal(Condition Error Type IncorrectType)
      )
    )

    describe("notice",
      it("should validate type of receiver",
        Number Rational should checkReceiverTypeOn(:"notice")
      )
    )
  )

  describe(Number Decimal,
    it("should have the correct kind",
      Number Decimal kind should == "Number Decimal"
    )

    it("should mimic Real",
      Number Decimal should mimic(Number Real)
    )

    describe("===",
      it("should check for mimicness if receiver is Number Decimal",
        Number Decimal should === Number Decimal
        Number Decimal should === 123.3
        Number Decimal should not === 123
        Number Decimal should not === (1/3)
        Number Decimal should not === Number
        Number Decimal should not === Number Real
        Number Decimal should not === Number Rational
        Number Decimal should not === Origin
      )
      
      it("should check for equalness if receiver is not Number Decimal",
        0.0 should === 0.0
        0.0 should not === 1.0
        (-234.3) should === -234.3
        12434 should not === 0.0
        12434.1 should === 12434.1
      )
    )

    it("should be the kind of simple decimal numbers",
      0.0 should have kind("Number Decimal")
      1.0 should have kind("Number Decimal")
      424345.255 should have kind("Number Decimal")
      (-1.0) should have kind("Number Decimal")
      435345643563.56456456 should have kind("Number Decimal")
      10e6 should have kind("Number Decimal")
    )

    describe("==", 
      it("should return true for the same number", 
        x = 1.0. x should == x
        x = 10.0. x should == x
        x = -20.0. x should == x
      )

      it("should not return true for unequal numbers", 
        1.1 should not == 2.0
        1.2 should not == 200000.0
        1123223.3233223 should not == 65756756756.0
        (-1.0) should not == 2.0
      )
      
      it("should return true for the result of equal number calculations", 
        (1.0+1.0) should == 2.0
        (2.1+1.0) should == (1.1+2.0)
      )

      it("should work correctly when comparing zeroes", 
        0.0 should == 0.0
        1.0 should not == 0.0
        0.0 should not == 1.0
      )

      it("should work correctly when comparing negative numbers", 
        (-19.1) should == (-19.1)
        (-19.0) should not == (-20.1)
      )

      it("should work correctly when comparing large positive numbers", 
        123234534675676786789678985463456345.234234 should == 123234534675676786789678985463456345.234234
        8888856676776.0101 should == 8888856676776.0101
      )

      it("should convert its argument to a decimal if it is a rational", 
        2.0 should == 2
        2.1 should not == 2
      )

      it("should return false for comparisons against unrelated objects", 
        2.1 should not == "foo"
        2.1 should not == :blarg
      )

      it("should validate type of receiver",
        Number Decimal should checkReceiverTypeOn(:"==", 2)
      )
    )
    
    describe("<=>", 
      it("should return 0 for the same number", 
        (0.0<=>0.0) should == 0
        (1.0<=>1.0) should == 0
        (10.0<=>10.0) should == 0
        (12413423523452345345345.0<=>12413423523452345345345.0) should == 0
        ((0.0-1.0)<=>(0.0-1.0)) should == 0
        (1.2<=>1.2) should == 0
      )

      it("should return 1 when the left number is larger than the right", 
        (1.0<=>0.0) should == 1
        (2.0<=>1.0) should == 1
        (10.0<=>9.0) should == 1
        (12413423523452345345345.0<=>12413423523452345345344.0) should == 1
        (0.0<=>(-1.0)) should == 1
        (1.0<=>(-1.0)) should == 1
        (0.001<=>0.0009) should == 1
        (0.2<=>0.1) should == 1
      )

      it("should return -1 when the left number is smaller than the right", 
        (0.0<=>1.0) should == -1
        (1.0<=>2.0) should == -1
        (9.0<=>10.0) should == -1
        (12413423523452345345343.0<=>12413423523452345345344.0) should == -1
        ((-1.0)<=>0.0) should == -1
        ((-1.0)<=>1.0) should == -1
        (0.0009<=>0.001) should == -1
        (0.1<=>0.2) should == -1
      )

      it("should convert argument to a decimal if the argument is a rational", 
        (1.0<=>1) should == 0
        (1.1<=>1) should == 1
        (0.9<=>1) should == -1
      )

      it("should convert its argument to a decimal if its not a rational or a decimal", 
        x = Origin mimic
        x asDecimal = method(42.0)
        (42.0 <=> x) should == 0
      )
      
      it("should return nil if it can't be converted and there is no way of comparing", 
        (1.0 <=> Origin mimic) should be nil
      )

      it("should validate type of receiver",
        Number Decimal should checkReceiverTypeOn(:"<=>", 2)
      )
    )

    describe("-", 
      it("should return 0.0 for the difference between 0.0 and 0.0", 
        (0.0-0.0) should == 0.0
      )
      
      it("should return the difference between really large numbers", 
        (123435334645674745675675757.1-123435334645674745675675756.1) should == 1.0
        (123435334645674745675675757.2-1.1) should == 123435334645674745675675756.1
        (123435334645674745675675757.0-24334534544345345345345.0) should == 123411000111130400330330412.0
      )
      
      it("should return the difference between smaller numbers", 
        (0.0-1.0) should == -1.0
        (2.0-1.0) should == 1.0
        (10.0-5.0) should == 5.0
        (234.0-30.0) should == 204.0
        (30.0-35.0) should == -5.0
      )
      
      it("should return the difference between negative numbers", 
        ((-1.0)-1.0) should == -2.0
        ((-1.0)-5.0) should == -6.0
        ((-1.0)-(-5.0)) should == 4.0
        ((-10.0)-5.0) should == -15.0
        ((-10.0)-(0.0-5.0)) should == -5.0
        ((-2545345345346547456756.0)-(-2545345345346547456755.0)) should == -1.0
      )

      it("should return the number when 0 is the argument", 
        ((-1.0)-0.0) should == -1.0
        (10.0-0.0) should == 10.0
        (1325234534634564564576367.0-0.0) should == 1325234534634564564576367.0
      )

      it("should convert its argument to a decimal if its not a decimal", 
        (1.6-1) should == 0.6
        (3.2-2) should == 1.2
      )

      it("should convert its argument to a decimal with asDecimal if its not a decimal and not a rational", 
        x = Origin mimic
        x asDecimal = method(42.0)
        (43.4 - x) should == 1.4
      )

      it("should signal a condition if it isn't a number and can't be converted", 
        fn(1 - Origin mimic) should signal(Condition Error Type IncorrectType)
      )

      it("should validate type of receiver",
        Number Decimal should checkReceiverTypeOn(:"-", 2)
      )
    )

    describe("+", 
      it("should return 0.0 for the sum of 0.0 and 0.0", 
        (0.0+0.0) should == 0.0
      )

      it("should return the sum of really large numbers", 
        (234235345636345634567345675467.1+1.2) should == 234235345636345634567345675468.3
        (21342342342345345.0+778626453756754687567865785678.1) should == 778626453756776029910208131023.1
        (234234.0+63456345745676574567571345456345645675674567878567856785678657856568768.0) should == 63456345745676574567571345456345645675674567878567856785678657856803002.0
      )

      it("should return the sum of smaller numbers", 
        (1.0+1.1) should == 2.1
        (10.0+1.0) should == 11.0
        (15.5+15.0) should == 30.5
        (16.0+15.0) should == 31.0
      )

      it("should return the sum of negative numbers", 
        (1.0+(0.0-1.0)) should == 0.0
        ((0.0-1.0)+2.0) should == 1.0
        ((0.0-1.0)+(0.0-1.0)) should == -2.0
      )

      it("should return the number when 0.0 is the receiver", 
        (0.0+1.0) should == 1.0
        (0.0+(0.0-1.0)) should == -1.0
        (0.0+124423.0) should == 124423.0
        (0.0+34545636745678657856786786785678.1) should == 34545636745678657856786786785678.1
      )

      it("should return the number when 0.0 is the argument", 
        (1.3+0.0) should == 1.3
        ((0.0-1.0)+0.0) should == -1.0
        (124423.0+0.0) should == 124423.0
        (34545636745678657856786786785678.0+0.0) should == 34545636745678657856786786785678.0
      )

      it("should convert its argument to a decimal if its not a decimal", 
        (0.6+1) should == 1.6
        (1.2+3) should == 4.2
      )

      it("should convert its argument to a decimal with asDecimal if its not a decimal and not a rational", 
        x = Origin mimic
        x asDecimal = method(41.1)
        (1.1 + x) should == 42.2
      )
      
      it("should signal a condition if it isn't a decimal and can't be converted", 
        fn(1.0 + Origin mimic) should signal(Condition Error Type IncorrectType)
      )

      it("should validate type of receiver",
        Number Decimal should checkReceiverTypeOn(:"+", 2)
      )
    )
    
    describe("*", 
      it("should multiply with 0.0", 
        (1.0*0.0) should == 0.0
        (34253453.0*0.0) should == 0.0
        (-1.0*0.0) should == 0.0
      )

      it("should return the same number when multiplying with 1.0", 
        (1.0*1.0) should == 1.0
        (34253453.1*1.0) should == 34253453.1
        (-1.0*1.0) should == -1.0
      )

      it("should return a really large number when multiplying large numbers", 
        (2345346456745722.0*12213212323899088545.0) should == 28644214249339912541248622627954490.0
      )

      it("should return a negative number when multiplying with one negative number", 
        (-21.0*2.0) should == -42.0
      )

      it("should return a positive number when multiplying with two negative numbers", 
        (-21.0* -2.0) should == 42.0
      )

      it("should convert its argument to a decimal if its not a decimal", 
        (0.6*2) should == 1.2
        (1.2*3) should == 3.6
      )

      it("should convert its argument to a decimal with asDecimal if its not a decimal and not a rational", 
        x = Origin mimic
        x asDecimal = method(21.2)
        (2.0 * x) should == 42.4
      )
      
      it("should signal a condition if it isn't a decimal and can't be converted", 
        fn(1.0 * Origin mimic) should signal(Condition Error Type IncorrectType)
      )

      it("should validate type of receiver",
        Number Decimal should checkReceiverTypeOn(:"*", 2)
      )
    )
    
    describe("/", 
      it("should cause a condition when dividing with 0.0", 
        fn(10.0/0.0) should signal(Condition Error Arithmetic DivisionByZero)
      )

      it("should divide simple numbers", 
        (2.0/1.0) should == 2.0
        (4.2/2.0) should == 2.1
        (200.0/5.0) should == 40.0
      )

      it("should divide negative numbers correctly", 
        (-8200.0/10.0) should == -820.0
      )

      it("should divide with a negative dividend correctly", 
        (8200.0/ -10.0) should == -820.0
      )

      it("should correctly handle a number that would generate an infinite expansion, by being inexact",
        (2.0/3.0) should == 0.6666666666666666666666666666666667
      )
        
      it("should divide a negative number with a negative dividend", 
        (-8200.0/ -10.0) should == 820.0
      )

      it("should convert its argument to a decimal if its not a decimal", 
        (0.5/5) should == 0.1
        (3.4/2) should == 1.7
      )
      
      it("should convert its argument to a decimal with asDecimal if its not a decimal and not a rational", 
        x = Origin mimic
        x asDecimal = method(2.0)
        (42.8 / x) should == 21.4
      )

      it("should signal a condition if it isn't a decimal and can't be converted", 
        fn(1.0 / Origin mimic) should signal(Condition Error Type IncorrectType)
      )

      it("should validate type of receiver",
        Number Decimal should checkReceiverTypeOn(:"/", 2)
      )
    )
  )    

  describe(Number Integer,
    it("should have the correct kind",
      Number Integer kind should == "Number Integer"
    )

    it("should mimic Rational",
      Number Integer should mimic(Number Rational)
    )

    it("should be the kind of simple decimal numbers",
      0 should have kind("Number Integer")
      1 should have kind("Number Integer")
      255 should have kind("Number Integer")
      (-1) should have kind("Number Integer")
      43534564356356456456 should have kind("Number Integer")
      0xFFF should have kind("Number Integer")
    )

    describe("%", 
      it("should return the number when taking the modulo of 0", 
        (0%0) should == 0
        (13%0) should == 13
        (-10%0) should == -10
      )
      
      it("should return the regular modulus", 
        (13%4) should == 1
        (4%13) should == 4
        (1%2) should == 1
      ) 

      it("should return modulus for negative numbers", 
        (-13%4) should == 3
        (-13% -4) should == -1
        (13% -4) should == -3
      )

      it("should convert its argument to a number if its not a number or a decimal", 
        x = Origin mimic
        x asRational = method(3)
        (10 % x) should == 1
      )

      it("should signal a condition if it isn't a number and can't be converted", 
        fn(1 % Origin mimic) should signal(Condition Error Type IncorrectType)
      )

      it("should validate type of receiver",
        Number Integer should checkReceiverTypeOn(:"%", 2)
      )
    )
    
    describe("times", 
      it("should not do anything for a negative number", 
        x = 0. (-1) times(x++). x should == 0
        x = 0. (-100) times(x++). x should == 0
      )
      
      it("should not do anything for 0", 
        x = 0. 0 times(x++). x should == 0
      )

      it("should execute the block one time for 1", 
        x = 0. 1 times(x++). x should == 1
      )

      it("should execute the block the same number of times as the receiver", 
        x = 0. 12 times(x++). x should == 12
        x = 0. 343 times(x++). x should == 343
      )

      it("should validate type of receiver",
        Number Integer should checkReceiverTypeOn(:"times", "foo")
      )
    )

    describe("&", 
      it("should bitwise and two powers of 8", 
        (256&16) should == 0
      )

      it("should bitwise and two zeroes", 
        (0&0) should == 0
      )

      it("should bitwise and other numbers", 
        (2010&5) should == 0
        (65535&1) should == 1
      )

      it("should bitwise and large numbers", 
        (-1 & 2**64) should == 18446744073709551616
      )

      it("should convert its argument to a number if its not a number or a decimal", 
        x = Origin mimic
        x asRational = method(3)
        (10 & x) should == 2
      )

      it("should signal a condition if it isn't a number and can't be converted", 
        fn(1 & Origin mimic) should signal(Condition Error Type IncorrectType)
      )

      it("should validate type of receiver",
        Number Integer should checkReceiverTypeOn(:"&", 4)
      )
    )

    describe("|", 
      it("should bitwise or two zeroes", 
        (0|0) should == 0
      )

      it("should bitwise or other numbers", 
        (1|0) should == 1
        (5|4) should == 5
        (5|6) should == 7
        (248|4096) should == 4344
      )
      
      it("should bitwise or negative and large numbers", 
        (-1|2**64) should == -1
      )

      it("should convert its argument to a number if its not a number or a decimal", 
        x = Origin mimic
        x asRational = method(3)
        (10 | x) should == 11
      )

      it("should signal a condition if it isn't a number and can't be converted", 
        fn(1 | Origin mimic) should signal(Condition Error Type IncorrectType)
      )

      it("should validate type of receiver",
        Number Integer should checkReceiverTypeOn(:"|", 4)
      )
    )
    
    describe("^", 
      it("should xor zeroes", 
        (0^0) should == 0
      )
      
      it("should xor regular numbers", 
        (1^0) should == 1
        (1^1) should == 0
        (0^1) should == 1
        (3^5) should == 6
        (-2^ -255) should == 255
      )
      
      it("should xor large numbers", 
        (-1 ^ 2**64) should == -18446744073709551617
      )

      it("should convert its argument to a number if its not a number or a decimal", 
        x = Origin mimic
        x asRational = method(3)
        (10 ^ x) should == 9
      )

      it("should signal a condition if it isn't a number and can't be converted", 
        fn(1 ^ Origin mimic) should signal(Condition Error Type IncorrectType)
      )

      it("should validate type of receiver",
        Number Integer should checkReceiverTypeOn(:"^", 4)
      )
    )

    describe(">>", 
      it("returns self shifted the given amount of bits to the right",
        (7 >> 1) should == 3
        (4095 >> 3) should == 511
        (9245278 >> 1) should == 4622639
      )

      it("performs a left-shift if given a negative value",
        (7 >> -1) should == 7 << 1
        (4095 >> -3) should == 4095 << 3
      )
      
      it("performs a right-shift if given a negative value as receiver",
        (-7 >> 1) should == -4
        (-4095 >> 3) should == -512
      )

      it("should convert its argument to a number if its not a number or a decimal", 
        x = Origin mimic
        x asRational = method(1)
        (7 >> x) should == 3
      )

      it("should signal a condition if it isn't a number and can't be converted", 
        fn(1 >> Origin mimic) should signal(Condition Error Type IncorrectType)
      )

      it("should validate type of receiver",
        Number Integer should checkReceiverTypeOn(:">>", 4)
      )
    )

    describe("<<", 
      it("returns self shifted the given amount of bits to the left", 
        (7<<2) should == 28
        (9<<4) should == 144
      )
      
      it("performs a right shift if given a negative value", 
        (7<< -2) should == 7>>2
        (9<< -4) should == 9>>4
      )
      
      it("should left shift a large number", 
        (6<<255) should == 347376267711948586270712955026063723559809953996921692118372752023739388919808
      )

      it("should convert its argument to a number if its not a number or a decimal", 
        x = Origin mimic
        x asRational = method(2)
        (7 << x) should == 28
      )

      it("should signal a condition if it isn't a number and can't be converted", 
        fn(1 << Origin mimic) should signal(Condition Error Type IncorrectType)
      )

      it("should validate type of receiver",
        Number Integer should checkReceiverTypeOn(:"<<", 4)
      )
    )

    describe("succ", 
      it("should return the successor of 0", 
        0 succ should == 1
      )

      it("should return the successor of a small positive number", 
        1 succ should == 2
        12 succ should == 13
        41 succ should == 42
        99 succ should == 100
      )

      it("should return the successor of a large positive number", 
        465467257434567 succ should == 465467257434568
        5999999999999999999 succ should == 6000000000000000000
        65535 succ should == 65536
        34565464575678567876852464563575468678567835678456865785678 succ should == 34565464575678567876852464563575468678567835678456865785679
      )

      it("should return the successor of a negative number", 
        (-1) succ should == 0
        (-2) succ should == -1
        (-10) succ should == -9
        (-23534634654367) succ should == -23534634654366
      )

      it("should validate type of receiver",
        Number Integer should checkReceiverTypeOn(:"succ")
      )
    )

    describe("pred", 
      it("should return the predecessor of 0", 
        0 pred should == -1
      )

      it("should return the predecessor of a small positive number", 
        1 pred should == 0
        2 pred should == 1
        12 pred should == 11
        41 pred should == 40
        99 pred should == 98
      )

      it("should return the predecessor of a large positive number", 
        465467257434567 pred should == 465467257434566
        6000000000000000000 pred should == 5999999999999999999
        65536 pred should == 65535
        34565464575678567876852464563575468678567835678456865785678 pred should == 34565464575678567876852464563575468678567835678456865785677
      )

      it("should return the predecessor of a negative number", 
        (-1) pred should == -2
        (-2) pred should == -3
        (-10) pred should == -11
        (-23534634654367) pred should == -23534634654368
      )

      it("should validate type of receiver",
        Number Integer should checkReceiverTypeOn(:"pred")
      )
    )

    describe("inspect",
      it("should validate type of receiver",
        Number Integer should checkReceiverTypeOn(:inspect)
      )
    )

    describe("notice",
      it("should validate type of receiver",
        Number Integer should checkReceiverTypeOn(:notice)
      )
    )
  )

  describe(Number Ratio,
    it("should have the correct kind",
      Number Ratio kind should == "Number Ratio"
    )

    it("should mimic Rational",
      Number Ratio should mimic(Number Rational)
    )
  )
)
