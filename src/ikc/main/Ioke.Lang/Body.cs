
namespace Ioke.Lang {
    using System.Collections;
    using System.Collections.Generic;

    using Ioke.Lang.Util;

    public class Cell {
        internal string name;
        internal int hash;
        public object value;
        internal Cell next; // next in hash table bucket
        internal Cell orderedNext; // next in linked list
        
        internal Cell(string name, int hash) {
            this.name = name;
            this.hash = hash;
        }
    }

    public class Body {
        internal string documentation;

        internal IokeObject mimic = null;
        internal IokeObject[] mimics = null;
        internal int mimicCount = 0;

        internal List<IokeObject> hooks = null;
        // zeroed by jvm
        internal int flags;

        public void Put(string name, object value) {
            Cell cell = GetCell(name, false);
            cell.value = value;
        }

        public bool Has(string name) {
            return null != GetCell(name, true);
        }

        public object Get(string name) {
            Cell cell = GetCell(name, true);
            if(cell == null) {
                return cell;
            }
            return cell.value;
        }

        public object Remove(string name) {
            int hash = name.GetHashCode();

            Cell[] cellsLocalRef = cells;
            if(count != 0) {
                int tableSize = cells.Length;
                int cellIndex = GetCellIndex(tableSize, hash);
                Cell prev = cellsLocalRef[cellIndex];
                Cell cell = prev;
                while(cell != null) {
                    if(cell.name == name || name.Equals(cell.name)) {
                        break;
                    }
                    prev = cell;
                    cell = cell.next;
                }
                if(cell != null) {
                    count--;
                    // remove slot from hash table
                    if(prev == cell) {
                        cellsLocalRef[cellIndex] = cell.next;
                    } else {
                        prev.next = cell.next;
                    }

                    if(firstAdded == cell) {
                        firstAdded = cell.orderedNext;
                        if(lastAdded == cell) {
                            lastAdded = null;
                        }
                    } else {
                        Cell p2 = firstAdded;
                        while(p2.orderedNext != cell) {
                            p2 = p2.orderedNext;
                        }
                        if(p2 != null) {
                            p2.orderedNext = cell.orderedNext;
                        }
                        if(lastAdded == cell) {
                            lastAdded = p2;
                        }
                    }

                    return cell.value;
                }
            }
            return null;
        }

        private Cell[] cells;
        private int count;

        internal Cell firstAdded;
        internal Cell lastAdded;

        private static readonly int INITIAL_CELL_SIZE = 4;


        private Cell GetCell(string name, bool query) {
            Cell[] cellsLocalRef = cells;
            if(cellsLocalRef == null && query) {
                return null;
            }
            int hash = name.GetHashCode();
            if(cellsLocalRef != null) {
                Cell cell;
                int cellIndex = GetCellIndex(cellsLocalRef.Length, hash);
                for(cell = cellsLocalRef[cellIndex];
                    cell != null;
                    cell = cell.next) {
                    string sname = cell.name;
                    if(sname == name || name.Equals(sname)) {
                        break;
                    }
                }
                if(query || (!query && cell != null)) {
                    return cell;
                }
            }

            return CreateCell(name, hash, query);
        }

        private static int GetCellIndex(int tableSize, int hash) {
            return hash & (tableSize - 1);
        }

        private Cell CreateCell(string name, int hash, bool query) {
            Cell[] cellsLocalRef = cells;
            int insertPos;
            if(count == 0) {
                cellsLocalRef = new Cell[INITIAL_CELL_SIZE];
                cells = cellsLocalRef;
                insertPos = GetCellIndex(cellsLocalRef.Length, hash);
            } else {
                int tableSize = cellsLocalRef.Length;
                insertPos = GetCellIndex(tableSize, hash);
                Cell prev = cellsLocalRef[insertPos];
                Cell cell = prev;
                while(cell != null) {
                    if(cell.name == name || name.Equals(cell.name)) {
                        break;
                    }
                    prev = cell;
                    cell = cell.next;
                }

                if(cell != null) {
                    return cell;
                } else {
                    if(4 * (count + 1) > 3 * cellsLocalRef.Length) {
                        cellsLocalRef = new Cell[cellsLocalRef.Length * 2];
                        CopyTable(cells, cellsLocalRef, count);
                        cells = cellsLocalRef;
                        insertPos = GetCellIndex(cellsLocalRef.Length, hash);
                    }
                }
            }
            Cell newCell = new Cell(name, hash);
            ++count;
            if(lastAdded != null)
                lastAdded.orderedNext = newCell;
            if(firstAdded == null)
                firstAdded = newCell;
            lastAdded = newCell;
            AddKnownAbsentCell(cellsLocalRef, newCell, insertPos);
            return newCell;
        }

        private static void CopyTable(Cell[] cells, Cell[] newCells, int count) {
            int tableSize = newCells.Length;
            int i = cells.Length;
            for (;;) {
                --i;
                Cell cell = cells[i];
                while(cell != null) {
                    int insertPos = GetCellIndex(tableSize, cell.hash);
                    Cell next = cell.next;
                    AddKnownAbsentCell(newCells, cell, insertPos);
                    cell.next = null;
                    cell = next;
                    if(--count == 0)
                        return;
                }
            }
        }

        private static void AddKnownAbsentCell(Cell[] cells, Cell cell, int insertPos) {
            if(cells[insertPos] == null) {
                cells[insertPos] = cell;
            } else {
                Cell prev = cells[insertPos];
                while(prev.next != null) {
                    prev = prev.next;
                }
                prev.next = cell;
            }
        }
    }
}
