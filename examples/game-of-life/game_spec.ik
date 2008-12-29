use("ispec")
use("game")

describe("Game",
  describe("next",
    it("should allow to advance to the next step",
      game = Game mimic
      game step should == 0
      game next
      game step should == 1
    )
  )
  
  describe("evolution",
    it("should die when surrounded by fewer than two live neighbours",
      game = Game mimic
      game grid cells[1][1] alive = true
      game next
      game grid cells[1][1] alive should == false
      
      game = Game mimic
      game grid cells[0][1] alive = true
      game grid cells[1][1] alive = true
      game grid cells[2][1] alive = true
      game next
      game grid cells[1][1] alive should == true
    )

    it("should die when surrounded by more than three live neighbours",
      game = Game mimic
      
      game grid cells[0][1] alive = true
      game grid cells[1][1] alive = true
      game grid cells[2][1] alive = true
      
      game grid cells[0][0] alive = true
      game grid cells[1][0] alive = true
      game grid cells[2][0] alive = true
      
      game next
      
      game grid cells[1][1] alive should == false    
    )

    it("should live when surrounded by two or three live neighbours",
      game = Game mimic
      
      game grid cells[0][1] alive = true
      game grid cells[1][1] alive = true
      game grid cells[2][1] alive = true      
      game grid cells[0][0] alive = true
      
      game next
      
      game grid cells[1][1] alive should == true
    )

    it("should come to life when it is dead and has exactly three live neighbours")
  )
  
  describe("grid",
    it("should contain cells",
      Game grid cells should != nil
    )

    it("should be a 3x3 grid by default",
      Game grid cells size should == 3
      Game grid cells first size should == 3
    )
    
    describe("cells",
      describe("0x0",
        it("should not have a northern neighbour",
          Game grid cells[0][0] neighbours[:n] should == nil
        )
        it("should not have a northwestern neighbour",
          Game grid cells[0][0] neighbours[:nw] should == nil
        )
        it("should not have an northeastern neighbour",
          Game grid cells[0][0] neighbours[:ne] should == nil
        )
        it("should not have a western neighbour",
          Game grid cells[0][0] neighbours[:w] should == nil
        )

        it("should have an eastern neighbour",
          Game grid cells[0][0] neighbours[:e] should != nil
        )
        it("should have an southeastern neighbour",
          Game grid cells[0][0] neighbours[:se] should != nil
        )
        it("should have an southern neighbour",
          Game grid cells[0][0] neighbours[:s] should != nil
        )
      )

      describe("1x1",
        it("should have a northern neighbour",
          Game grid cells[1][1] neighbours[:n] position should == {x: 0, y: 1}
        )
        it("should have a northwestern neighbour",
          Game grid cells[1][1] neighbours[:nw] position should == {x: 0, y: 0}
        )
        it("should have an northeastern neighbour",
          Game grid cells[1][1] neighbours[:ne] position should == {x: 0, y: 2}
        )
        it("should have a western neighbour",
          Game grid cells[1][1] neighbours[:w] position should == {x: 1, y: 0}
        )
        it("should have an eastern neighbour",
          Game grid cells[1][1] neighbours[:e] position should == {x: 1, y: 2}
        )
        it("should have an southeastern neighbour",
          Game grid cells[1][1] neighbours[:se] position should == {x: 2, y: 2}
        )
        it("should have an southern neighbour",
          Game grid cells[1][1] neighbours[:s] position should == {x: 2, y: 1}
        )
      )

      describe("2x2",
        it("should have a northern neighbour",
          Game grid cells[2][2] neighbours[:n] position should == {x: 1, y: 2}
        )
        it("should have a northwestern neighbour",
          Game grid cells[2][2] neighbours[:nw] position should == {x: 1, y: 1}
        )
        it("should have a western neighbour",
          Game grid cells[2][2] neighbours[:w] position should == {x: 2, y: 1}
        )

        it("should not have an northeastern neighbour",
          Game grid cells[2][2] neighbours[:ne] should == nil
        )
        it("should not have an eastern neighbour",
          Game grid cells[2][2] neighbours[:e] should == nil
        )
        it("should not have an southeastern neighbour",
          Game grid cells[2][2] neighbours[:se] should == nil
        )
        it("should not have an southern neighbour",
          Game grid cells[2][2] neighbours[:s] should == nil
        )
      )

    )
  )
)
