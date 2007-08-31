package maps {

import com.threerings.flash.MathUtil;

/**
 * Stores pathfinding information for a single player's critters.
 */
public class PathMap extends Map
{
    public function PathMap (board :Board, player :int)
    {
        _board = board;
        _player = player;
        super();
    }
    
    // from Map
    override public function init () :void
    {
        // note: no call to super, this is a complete replacement
        
        for (var xx :int = 0; xx < _width; xx++) {
            for (var yy :int = 0; yy < _height; yy++) {
                _data[xx][yy] = Infinity;
            }
        }
    }

    // from Map
    override public function update () :void
    {
        var changeCount :int = pathingPass();
        if (changeCount > 0) {
            trace("Found " + changeCount + " new values!");
            invalidate();
        }
    }

    // from Map
    override public function fillAllTowerCells (def :TowerDef, value :*) :void
    {
        // since this is the pathing map, instead of filling in with player id,
        // we fill the cells underneath the tower with infinite pathing cost.
        super.fillAllTowerCells(def, Infinity);
    }

    /** Called by the board, to clear the map and set up a new pathfinding target */
    public function setTarget (x :int, y :int) :void
    {
        init();
        
        setCell(x, y, 0);
        
        invalidate();
    }
    
    // performs a single pass of spreading activation
    protected function pathingPass () :int
    {
        var count :int = 0;
        
        // iterate over all cells, left to right, top to bottom
        for (var xx :int = 0; xx < _width; xx++) {
            for (var yy :int = 0; yy < _height; yy++) {
                // iterate over all neighbors
                var val :Number = _data[xx][yy];
                var min :Number = val;
                for (var x2 :int = xx - 1; x2 <= xx + 1; x2++) {
                    for (var y2 :int = yy - 1; y2 <= yy + 1; y2++) {
                        if (! (x2 == 0 && y2 == 0) &&
                            x2 >= 0 && x2 < _width && y2 >= 0 && y2 < _height)
                        {
                            var n :Number = _data[x2][y2];
                            min = (n < min) ? n : min;
                        }
                    }
                }
                
                if (min + 1 < val) {
                    _data[xx][yy] = min + 1;
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
    
    protected var _board :Board;
    protected var _player :int;
}
}
