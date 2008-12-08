
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
)
