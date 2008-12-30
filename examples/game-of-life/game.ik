Cell = Origin mimic do(
  notice = method("Cell #{position[:x], position[:y]}")
)

Grid = Origin mimic do(
  with = method(rows:, columns:,

    newGrid = Grid mimic
    newGrid cells = (0...rows) map((0...columns) map(Cell mimic))

    newGrid cells each(i, row,
      newGrid cells[i] each(j, cell,
        cell position = {x: i, y: j}
        cell neighbours = {}
        cell alive = false
        cell queuedState = nil
        if(i-1 >= 0,
          cell neighbours[:n] = newGrid cells[i-1][j]
          if(j+1 < columns,
            cell neighbours[:ne] = newGrid cells[i-1][j+1]
          )
          if(j-1 >= 0,
            cell neighbours[:nw] = newGrid cells[i-1][j-1]
          )
        )
        if(j-1 >= 0,
          cell neighbours[:w] = newGrid cells[i][j-1]
        )
        if(j+1 < columns,
          cell neighbours[:e] = newGrid cells[i][j+1]
        )
        if(i+1 < rows,
          cell neighbours[:s] = newGrid cells[i+1][j]
          if(j+1 < columns,
            cell neighbours[:se] = newGrid cells[i+1][j+1]
          )
          if(j-1 >= 0,
            cell neighbours[:sw] = newGrid cells[i+1][j-1]
          )
        )
      )
    )

    newGrid
  )
)

Game = Origin mimic do(

  grid = Grid with(rows: 3, columns: 3)

  next = method(

    grid cells each(row,
      row each(cell,
        if(cell alive && (cell neighbours map(value) count(alive) < 2 || cell neighbours map(value) count(alive) > 3),
          cell queuedState = :dead
        )

        if(cell alive && (cell neighbours map(value) count(alive) == 2 || cell neighbours map(value) count(alive) == 3),
          cell queuedState = :alive
        )

        if(!cell alive && (cell neighbours map(value) count(alive) == 3),
          cell queuedState = :alive
        )

      )
    )

    grid cells each(row,
      row each(cell,
        if(cell queuedState == :dead,
          cell alive = false
        )
        if(cell queuedState == :alive,
          cell alive = true
        )
        cell queuedState = nil
      )
    )
  )

  reset = method(
    grid cells each(row,
      row each(cell,
        cell queuedState = nil
        cell alive = false
      )
    )

    self
  )
)

System ifMain(
  Grid with(rows: 16, columns: 16) inspect println
)
