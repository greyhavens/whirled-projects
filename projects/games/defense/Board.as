package {

import flash.geom.Rectangle;
    
/**
 * Occupancy grid representation, used for pathfinding and occupancy tests.
 */
public class Board
{
    public static const EMPTY :int = 0;
    public static const OCCUPIED :int = 1;
    
    public function Board (rows :int, columns :int)
    {
        _rows = new Array();
        for (var rr :int = 0; rr < rows; rr++) {
            _rows[rr] = new Array(columns);
            for (var cc :int = 0; cc < columns; cc++) {
                _rows[rr][cc] = EMPTY;
            }
        }
    }

    /** Maps the function over all cells in the rectangle, and returns an array of results. */
    public function map (r :Rectangle, fn :Function) :Array
    {
        var results :Array = new Array();
        for (var rr :int = r.top; rr < r.bottom; rr++) {
            for (var cc :int = r.left; cc < r.right; cc++) {
                results.push(fn(_rows[rr][cc]));
            }
        }
        return results;
    }

    /** Runs the function over all cells in the rectangle, storing the results back in the cell. */
    public function forEach (r :Rectangle, fn :Function) :void
    {
        for (var rr :int = r.top; rr < r.bottom; rr++) {
            for (var cc :int = r.left; cc < r.right; cc++) {
                _rows[rr][cc] = fn(_rows[rr][cc]);
            }
        }
    }

    /** Returns true if all cells in the rectangle are clear. */
    public function allClear (r :Rectangle) :Boolean
    {
        var results :Array = map(r, function (val :int) :Boolean { return val == EMPTY; });
        return results.every(function (val :Boolean, i :*, a :*) :Boolean { return val; });
    }

    /** Sets all cells in the rectangle to specified state. */
    public function setState (r :Rectangle, state :int) :void
    {
        forEach(r, function (... ignored) :int { return state; });
    }        
        
    protected var _rows :Array = null;
}
}
