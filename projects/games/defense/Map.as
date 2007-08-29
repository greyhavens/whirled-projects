package {

/**
 * Rectangular occupancy map storing the game board. Each cell is marked as UNOCCUPIED, or if it
 * supports a tower, with the player id of the tower owner. 
 */
public class Map
{
    /** Marks cells that can be built on, and through which critters can pass. */
    public static const UNOCCUPIED :int = -1;
    /** Marks cells that can't be built on, but through which critters can pass. */
    public static const RESERVED :int = -2;
    /** Marks cells that can't be built on, and are impassable for critters. */
    public static const INVALID :int = -3;
    
    public function Map (width :int, height :int)
    {
        _width = width;
        _height = height;
        _data = new Array(width);
        for (var xx :int = 0; xx < width; xx++) {
            _data[xx] = new Array(height);
            for (var yy :int = 0; yy < height; yy++) {
                _data[xx][yy] = UNOCCUPIED;
            }
        }
    }

    public function getCell (x :int, y :int) :*
    {
        return _data[x][y];
    }

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
    
    /**
     * Runs the specified function over all cells that intersect the tower location.
     * Function should be of the form: function (cellValue :*) :void { }
     */
    public function forEachTowerCell (def :TowerDef, fn :Function) :void
    {
        def.forEach(function (x :int, y :int) :void {
                fn(getCell(x, y));
            });
    }

    /**
     * Tests all cells intersected by the tower location for equality with specified value.
     */
    public function isEachTowerCellEqual (def :TowerDef, value :*) :Boolean
    {
        var result :Boolean = true;
        forEachTowerCell(def, function (cellValue :*) :void {
                result = result && (value == cellValue);
            });
        return result;
    }

    /**
     * Tests all cells intersected by the tower location for equality with specified value.
     */
    public function isAnyTowerCellEqual (def :TowerDef, value :*) :Boolean
    {
        var result :Boolean = false;
        forEachTowerCell(def, function (cellValue :*) :void {
                result = result || (value == cellValue);
            });
        return result;
    }

    /**
     * Fills all cells intersected by the tower location with specified value.
     */
    public function fillAllTowerCells (def :TowerDef, value :*) :void
    {
        def.forEach(function (x :int, y :int) :void {
                setCell(x, y, value);
            });
    }

    /** Grid dimensions. */
    protected var _width :int;
    protected var _height :int;
    
    /** Column-major representation of the grid data. */
    protected var _data :Array;
}
}
