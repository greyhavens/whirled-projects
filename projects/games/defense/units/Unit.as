package units {

import flash.geom.Point;

import com.threerings.util.Hashable;

/**
 * Base class for objects that occupy a board position, and cover up one or more board squares.
 */
public class Unit
    implements Hashable
{
    /** Player index at the game table. */
    public var player :int;
    
    /** Unit position, in game board units (potentially fractional). Units larger than 1x1
     *  are "anchored" in upper-left corner to the x, y position. */
    public var pos :Point;

    /** Unit size, usually 1x1, but potentially larger. */
    public var size :Point;

    /** Globally unique id of the unit. */
    public var guid :int;
    
    public static function makeGuid () :int
    {
        return int(Math.random() * int.MAX_VALUE);
    }
    
    public function Unit (player :int, x :int, y :int, width :int, height :int)
    {
        this.player = player;
        this.pos = new Point(x, y);
        this.size = new Point(width, height);
        this.guid = makeGuid();
    }

    // position in board units
    public function get x () :Number      { return pos.x; }
    public function get y () :Number      { return pos.y; }

    // size in board units
    public function get width () :Number  { return size.x; }
    public function get height () :Number { return size.y; }

    // position in screen units, relative to the upper-left corner of the board
    public function get screenx () :Number { return pos.x * Board.SQUARE_WIDTH; }
    public function get screeny () :Number { return pos.y * Board.SQUARE_HEIGHT; }

    // position of the sprite centroid in screen coordinates
    public function get centroidx () :Number { return Board.SQUARE_WIDTH * (x + width/2); }
    public function get centroidy () :Number { return Board.SQUARE_HEIGHT * (y + height); }
    
    // from interface Hashable
    public function hashCode () :int
    {
        return guid;
    }

    // from interface Equalable
    public function equals (other :Object) :Boolean
    {
        var that :Unit = (other as Unit);
        return (that != null) && (this.guid == that.guid);
    }

    /**
     * Iterates the specified function over all cells contained inside the location.
     * Function should be of the type: function (x :int, y :int) :void { }
     */
    public function forEach (fn :Function) :void
    {
        var right :int = pos.x + width;
        var bottom :int = pos.y + height;
        for (var xx :int = pos.x; xx < right; xx++) {
            for (var yy :int = pos.y; yy < bottom; yy++) {
                fn(xx, yy);
            }
        }
    }

    /**
     * Iterates the specified function over all cells contained inside the location, and collects
     * all results into an array.
     * Function should be of the type: function (x :int, y :int) :* { }
     */
    public function map (fn :Function) :Array
    {
        var results :Array = new Array;
        var right :int = pos.x + width;
        var bottom :int = pos.y + height;
        for (var xx :int = pos.x; xx < right; xx++) {
            for (var yy :int = pos.y; yy < bottom; yy++) {
                results.push(fn(xx, yy));
            }
        }
        return results;
    }

    /**
     * Converts screen coordinates (relative to the upper left corner of the board)
     * to logical coordinates in board space. Rounds results down to integer coordinates.
     */
    public static function screenToLogicalPosition (x :Number, y :Number) :Point
    {
        return new Point(int(Math.floor(x / Board.SQUARE_WIDTH)),
                         int(Math.floor(y / Board.SQUARE_HEIGHT)));
    }

    public function toString () :String
    {
        return "[Unit at " + pos + ", size: " + size + ", player: " + player +
            ", guid " + guid + "]";
    }
}
}
