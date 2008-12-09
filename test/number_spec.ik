
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

  describe(Number Real,
    it("should have the correct kind",
      Number Real should have kind("Number Real"))

    it("should mimic Number",
      Number Real should mimic(Number))
  )

  describe(Number Rational,
    it("should have the correct kind",
      Number Rational should have kind("Number Rational"))

    it("should mimic Number Real",
      Number Rational should mimic(Number Real))

    describe("<=>",
      it("should return 0 for the same number",
        (0<=>0) should == 0
        (1<=>1) should == 0
        (10<=>10) should == 0
        (12413423523452345345345<=>12413423523452345345345) should == 0
        (-1<=>-1) should == 0
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
        (1 <=> Origin mimic) should == nil
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
        (-21*-2) should == 42
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
        (8200/-10) == -820
      )

      it("should divide a negative number with a negative dividend", 
        (-8200/-10) == 820
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
  )
)
