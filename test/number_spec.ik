
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
  )
)
