package maps {

import flash.display.BitmapData;
import flash.geom.Rectangle;

import game.Board;

import units.Tower;
    
/**
 * Rectangular occupancy map storing the game board. Each cell is marked as UNOCCUPIED, or if it
 * supports a tower, with the player id of the tower owner. 
 */
public class Map
{
    /** Marks cells that can be built on, and through which enemies can pass. */
    public static const UNOCCUPIED :int = -1;
    /** Marks cells that can't be built on, but through which enemies can pass. */
    public static const RESERVED :int = -2;
    /** Marks cells that can't be built on, and are impassable for enemies. */
    public static const INVALID :int = -3;
    
    public function Map (board :Board)
    {
        _width = board.columns;
        _height = board.rows;
        _data = new Array(_width);
        for (var xx :int = 0; xx < _width; xx++) {
            _data[xx] = new Array(_height);
        }
    }

    public function clear () :void
    {
        for (var xx :int = 0; xx < _width; xx++) {
            for (var yy :int = 0; yy < _height; yy++) {
                _data[xx][yy] = UNOCCUPIED;
            }
        }
    }

    /** Marks map as ready to be re-drawn on the next frame. */
    public function invalidate () :void
    {
        _hasNewData = true;
    }

    /** Cell contents accessor. */
    public function getCell (x :int, y :int) :*
    {
        return _data[x][y];
    }

    /** Cell contents setter. */
    public function setCell (x :int, y :int, value :*) :void
    {
        _data[x][y] = value;
    }

    public function isBuildable (x :int, y :int) :Boolean
    {
        var value :* = _data[x][y];
        return (value == UNOCCUPIED);
    }

    public function isPassable (x :int, y :int) :Boolean
    {
        var value :* = _data[x][y];
        return (value == UNOCCUPIED) || (value == RESERVED);
    }

    /** If one of the players occupies this cell, return its id. */
    public function playerOccupied (x :int, y :int) :Boolean
    {
        return (_data[x][y] as Number) > UNOCCUPIED;
    }

    /** Processes the per-frame updates of map data. */
    public function update () :void
    {
        // no op - children should override this
    }

  
    /** Updates the overlay bitmap that represents this map. Returns true if the bitmap
     *  was updated during this call, false if it remains unchanged. */
    public function maybeRefreshOverlay (overlay :BitmapData, player :int) :Boolean
    {
        if (_hasNewData) {
            overlay.lock();
            for (var xx :int = 0; xx < _width; xx++) {
                for (var yy :int = 0; yy < _height; yy++) {
                    overlay.setPixel32(xx, yy, getColor(xx, yy, player));
                }
            }
            overlay.unlock();
            _hasNewData = false;
            return true;
        }
        
        return false;
    }
        
    /**
     * Runs the specified function over all cells that intersect the tower location.
     * Function should be of the form: function (cellValue :*) :void { }
     */
    public function forEachTowerCell (tower :Tower, fn :Function) :void
    {
        tower.forEach(function (x :int, y :int) :void {
            fn(getCell(x, y));
        });
    }

    /**
     * Tests all cells intersected by the tower location for equality with specified value.
     */
    public function isEachTowerCellEqual (tower :Tower, value :*) :Boolean
    {
        var result :Boolean = true;
        forEachTowerCell(tower, function (cellValue :*) :void {
            result = result && (value == cellValue);
        });
        return result;
    }

    /**
     * Tests all cells intersected by the tower location for equality with specified value.
     */
    public function isAnyTowerCellEqual (tower :Tower, value :*) :Boolean
    {
        var result :Boolean = false;
        forEachTowerCell(tower, function (cellValue :*) :void {
            result = result || (value == cellValue);
        });
        return result;
    }

    /**
     * Fills all cells intersected by the tower location with specified value.
     * Also marks the map as invalidated, which will cause it to be redrawn.
     */
    public function fillAllTowerCells (tower :Tower, value :*) :void
    {
        tower.forEach(function (x :int, y :int) :void {
            setCell(x, y, value);
        });
        invalidate();
    }

    /** Given cell, returns the ARGB color to be used for drawing the bitmap. */
    protected function getColor (x :int, y :int, player :int) :uint
    {
        if (! playerOccupied(x, y)) {
            return 0x00000000;
        } else {
            return (player == getCell(x, y)) ? Globals.MY_COLOR : Globals.THEIR_COLOR;
        }                    
    }
    
    /** Grid dimensions. */
    protected var _width :int;
    protected var _height :int;
    
    /** True if this map was recently updated but not yet redrawn. */
    protected var _hasNewData :Boolean = false;

    /** Column-major representation of the grid data. */
    protected var _data :Array;
}
}
