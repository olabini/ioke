/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.Collection;
import java.util.Map;
import java.util.List;
import java.util.ArrayList;
import java.util.regex.Pattern;

import ioke.lang.exceptions.ControlFlow;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public final class Body {
    String documentation;

    IokeObject mimic = null;
    IokeObject[] mimics = null;
    int mimicCount = 0;

    Collection<IokeObject> hooks = null;
    // zeroed by jvm
    int flags;


    public final void put(String name, int index, Object value) {
        Cell cell = getCell(name, index, false);
        cell.value = value;
    }

    public final boolean has(String name) {
        return null != getCell(name, 0, true);
    }

    public final boolean has(int index) {
        return null != getCell(null, index, true);
    }

    public final Object get(String name, int index) {
        Cell cell = getCell(name, index, true);
        if(cell == null) {
            return cell;
        }
        return cell.value;
    }

    public Object remove(String name, int index) {
        int indexOrHash = (name != null ? name.hashCode() : index);

        Cell[] cellsLocalRef = cells;
        if(count != 0) {
            int tableSize = cells.length;
            int cellIndex = getCellIndex(tableSize, indexOrHash);
            Cell prev = cellsLocalRef[cellIndex];
            Cell cell = prev;
            while(cell != null) {
                if(cell.indexOrHash == indexOrHash && (cell.name == name || (name != null && name.equals(cell.name)))) {
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

    Cell firstAdded;
    Cell lastAdded;

    private static final int INITIAL_CELL_SIZE = 4;

    public static class Cell {
        String name;
        int indexOrHash;
        public Object value;
        Cell next; // next in hash table bucket
        Cell orderedNext; // next in linked list

        Cell(String name, int indexOrHash) {
            this.name = name;
            this.indexOrHash = indexOrHash;
        }
    }

    private Cell getCell(String name, int index, boolean query) {
        Cell[] cellsLocalRef = cells;
        if(cellsLocalRef == null && query) {
            return null;
        }
        int indexOrHash = (name != null ? name.hashCode() : index);
        if(cellsLocalRef != null) {
            Cell cell;
            int cellIndex = getCellIndex(cellsLocalRef.length, indexOrHash);
            for(cell = cellsLocalRef[cellIndex];
                cell != null;
                cell = cell.next) {
                Object sname = cell.name;
                if(indexOrHash == cell.indexOrHash && (sname == name || (name != null && name.equals(sname)))) {
                    break;
                }
            }
            if(query || (!query && cell != null)) {
                return cell;
            }
        }

        return createCell(name, indexOrHash, query);
    }

    private static int getCellIndex(int tableSize, int indexOrHash) {
        return indexOrHash & (tableSize - 1);
    }

    private Cell createCell(String name, int indexOrHash, boolean query) {
        Cell[] cellsLocalRef = cells;
        int insertPos;
        if(count == 0) {
            cellsLocalRef = new Cell[INITIAL_CELL_SIZE];
            cells = cellsLocalRef;
            insertPos = getCellIndex(cellsLocalRef.length, indexOrHash);
        } else {
            int tableSize = cellsLocalRef.length;
            insertPos = getCellIndex(tableSize, indexOrHash);
            Cell prev = cellsLocalRef[insertPos];
            Cell cell = prev;
            while(cell != null) {
                if(cell.indexOrHash == indexOrHash && (cell.name == name || (name != null && name.equals(cell.name)))) {
                    break;
                }
                prev = cell;
                cell = cell.next;
            }

            if(cell != null) {
                return cell;
            } else {
                if(4 * (count + 1) > 3 * cellsLocalRef.length) {
                    cellsLocalRef = new Cell[cellsLocalRef.length * 2];
                    copyTable(cells, cellsLocalRef, count);
                    cells = cellsLocalRef;
                    insertPos = getCellIndex(cellsLocalRef.length, indexOrHash);
                }
            }
        }
        Cell newCell = new Cell(name, indexOrHash);
        ++count;
        if(lastAdded != null)
            lastAdded.orderedNext = newCell;
        if(firstAdded == null)
            firstAdded = newCell;
        lastAdded = newCell;
        addKnownAbsentCell(cellsLocalRef, newCell, insertPos);
        return newCell;
    }

    private static void copyTable(Cell[] cells, Cell[] newCells, int count) {
        int tableSize = newCells.length;
        int i = cells.length;
        for (;;) {
            --i;
            Cell cell = cells[i];
            while(cell != null) {
                int insertPos = getCellIndex(tableSize, cell.indexOrHash);
                Cell next = cell.next;
                addKnownAbsentCell(newCells, cell, insertPos);
                cell.next = null;
                cell = next;
                if(--count == 0)
                    return;
            }
        }
    }

    private static void addKnownAbsentCell(Cell[] cells, Cell cell, int insertPos) {
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
