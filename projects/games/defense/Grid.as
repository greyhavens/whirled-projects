package {

/**
 * Rectangular occupancy map storing the game board. Each cell is marked as UNOCCUPIED, or if it
 * supports a tower, with the player id of the tower owner. 
 */
public class Grid
{
    public static const UNOCCUPIED :int = -1;
    
    public function Grid (width :int, height :int)
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

    /**
     * Runs the specified function over all cells that intersect the tower location.
     * Function should be of the form: function (cellValue :*) :void { }
     */
    public function forEachTowerCell (def :TowerDef, fn :Function) :void
    {
        def.forEach(function (x :int, y :int) :void { fn(getCell(x, y)); });
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

    /** Grid dimensions. */
    protected var _width :int;
    protected var _height :int;
    
    /** Column-major representation of the grid data. */
    protected var _data :Array;
}
}
