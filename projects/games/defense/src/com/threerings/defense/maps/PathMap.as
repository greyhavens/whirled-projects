package com.threerings.defense.maps {

import flash.geom.Point;

import com.threerings.flash.MathUtil;

import com.threerings.defense.Board;
import com.threerings.defense.units.Tower;

/**
 * Stores pathfinding information for a single player's critters.
 */
public class PathMap extends Map
{
    public function PathMap (board :Board, player :int)
    {
        super();

        _board = board;
        _player = player;

        _gradient = new Array(_width);
        for (var xx :int = 0; xx < _width; xx++) {
            _gradient[xx] = new Array(_height);
        }
    }
    
    // from Map
    override public function clear () :void
    {
        // note: no call to super, this is a complete replacement
        
        for (var xx :int = 0; xx < _width; xx++) {
            for (var yy :int = 0; yy < _height; yy++) {
                _data[xx][yy] = Infinity;
                _gradient[xx][yy] = NO_GRADIENT;
            }
        }
        
        invalidate();
    }

    // from Map
    override public function update () :void
    {
        if (! _upToDate) {
            for (var ii :int = 0; ii < UPDATES_PER_FRAME; ii++) {
                var changeCount :int = pathingPass();
                if (changeCount > 0) {
                    trace("Found " + changeCount + " new values!");
                } else {
                    trace("Path up to date!");
                    _upToDate = true;  
                    return; // we're done for now
                }
            }
            invalidate();
        }
    }

    // from Map
    override public function fillAllTowerCells (tower :Tower, value :*) :void
    {
        // since this is the pathing map, instead of filling in with player id,
        // we fill the cells underneath the tower with infinite pathing cost.
        super.fillAllTowerCells(tower, Infinity);

        // and now propagate pathing failures
        tower.forEach(propagatePathingFailures);
        invalidate();
    }

    // from Map
    override public function invalidate () :void
    {
        super.invalidate();
        _upToDate = false;
    }

    /** Called by the board, to clear the map and set up a new pathfinding target */
    public function setTarget (x :int, y :int) :void
    {
        clear();
        setCell(x, y, 0);
        invalidate();
    }

    /**
     * Given x, y coordinates on the board, returns the coordinates of the next cell
     * that should be traveled in order to reach the target - or null if none can be found.
     */
    public function getNextNode (x :int, y :int) :Point
    {
        if (x >= 0 && x < _width && y >= 0 && y < _height) {
            // see if the node we're supposed to go to is okay
            var g :Array = _gradient[x][y];
            var xn :int = x + g[0];
            var yn :int = y + g[1];
            if (! (xn == x && yn == y) && isFinite(_data[xn][yn])) {
                return new Point(xn, yn);
            }

            // well, let's try to find a neighbor - any neighbor - that's okay
            for each (var coords :Array in NEIGHBORS) {
                xn = x + coords[0];
                yn = y + coords[1];
                if (xn >= 0 && xn < _width && yn >= 0 && yn < _height &&
                    isFinite(_data[xn][yn])) {
                    return new Point(xn, yn);
                }
            }      
        }

        // give up
        return null;
    }
    
    /** Propagates pathing failures via a DFS from the specified point. */
    protected function propagatePathingFailures (x :int, y :int) :void
    {
        for each (var coords :Array in NEIGHBORS) {
            var xn :int = x + coords[0];
            var yn :int = y + coords[1];
            if (xn >= 0 && xn < _width && yn >= 0 && yn < _height) {
                // otherwise get the neighbor's gradient, see if it points back here
                var g :Array = _gradient[xn][yn];
                if (! (g[0] == 0 && g[1] == 0) &&
                    g[0] == -coords[0] && g[1] == -coords[1]) {
                    _data[xn][yn] = Infinity;
                    _gradient[xn][yn] = NO_GRADIENT;
                    propagatePathingFailures(xn, yn);
                }
            }
        }
    }
        
    
    /** Performs a single pass of spreading activation */
    protected function pathingPass () :int
    {
        if (_upToDate) {
            return 0; // nothing to be done
        }
        
        var occ :Map = _board.getMapOccupancy();
        
        var count :int = 0;
        var cellval :Number = 0;
        var minval :Number = 0;
        var mincoords :Array = null;

        // iterate over all cells, left to right, top to bottom
        for (var xx :int = 0; xx < _width; xx++) {
            for (var yy :int = 0; yy < _height; yy++) {

                if (! occ.isPassable(xx, yy)) { // special tile
                    _data[xx][yy] = Infinity;
                    _gradient[xx][yy] = NO_GRADIENT;
                    continue;
                }

                // otherwise, try to find a path through this tile
                
                cellval = _data[xx][yy];
                minval = cellval;
                mincoords = NO_GRADIENT;

                // let's iterate over all neighbors, and figure out the current path length
                for each (var coords :Array in NEIGHBORS) {
                    var x2 :int = xx + coords[0];
                    var y2 :int = yy + coords[1];
                    if (x2 >= 0 && x2 < _width && y2 >= 0 && y2 < _height) {
                        var n :Number = _data[x2][y2];
                        if (n < minval) {
                            minval = n;
                            mincoords = coords;
                        }
                    }
                }
                
                if (minval + 1 < cellval) {
                    _data[xx][yy] = minval + 1;
                    _gradient[xx][yy] = mincoords;
                    count++;
                }
            }
        }

        return count;
    }
    
    // from Map
    override protected function getColor (x :int, y :int, player :int) :uint
    {
        var val :Number = getCell(x, y);
        if (isFinite(val)) {
            var n :uint = 128 - uint(MathUtil.clamp(val * 5, 0, 128));
            return (n << 24 | 0x0000ff00);
        } else {
            return 0xff000000;
        }                    
    }

    protected static const NEIGHBORS :Array = [ [-1, 0], [0, -1], [0, 0], [0, 1], [1, 0] ];
    
    protected static const NO_GRADIENT :Array = NEIGHBORS[2];

    protected static const UPDATES_PER_FRAME :int = 3;
    
    /** Contains path gradient map for the entire board. */
    protected var _gradient :Array; // of Arrays like [x, y].

    /** Is this path info up to date? */
    protected var _upToDate :Boolean;
    
    protected var _board :Board;
    protected var _player :int;
}
}
