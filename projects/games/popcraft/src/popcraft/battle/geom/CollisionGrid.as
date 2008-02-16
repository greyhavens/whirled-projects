package popcraft.battle.geom {
    
import com.threerings.flash.Vector2;
import com.threerings.util.Assert;

/**
 * A simple grid-based spatial database for storing dynamic game objects
 * that generate collisions.
 * 
 * Objects on the grid must be no larger than the size of a cell in the grid.
 */
public class CollisionGrid
{
    public function CollisionGrid (boardWidth :int, boardHeight :int, cellSize :int)
    {
        _cellSize = cellSize;
        _cellSizeInv = 1 / _cellSize;
        
        _numCols = Math.ceil(boardWidth * _cellSizeInv);
        _numRows = Math.ceil(boardHeight * _cellSizeInv);
        
        _cells = new Array(_numCols * _numRows);
        
        for (var y :int = 0; y < _numRows; ++y) {
            var rowStart :int = (y * _numCols);
            
            for (var x :int = 0; x < _numCols; ++x) {
                _cells[rowStart + x] = new CollisionGridCell(x, y);
            }
        }
    }
    
    public function getCellAt (loc :Vector2) :CollisionGridCell
    {
        var x :int = loc.x * _cellSizeInv;
        var y :int = loc.y * _cellSizeInv;
        
        return this.getCell(x, y);
    }
    
    public function getCell (x :int, y :int) :CollisionGridCell
    {
        if (x < 0 || x >= _numCols || y < 0 || y >= _numCols) {
            return null;
        }
        
        return _cells[(y * _numCols) + x];
    }
    
    public function get cellSize () :int
    {
        return _cellSize;
    }
    
    public function beginDetectCollisions () :void
    {
        Assert.isFalse(_isDetectingCollisions);
        
        _isDetectingCollisions = true;
    }
    
    public function endDetectCollisions () :void
    {
        Assert.isTrue(_isDetectingCollisions);
        
        _isDetectingCollisions = false;
    }
    
    public function get isDetectingCollisions () :Boolean
    {
        return _isDetectingCollisions;
    }
    
    protected var _cells :Array;
    protected var _numCols :int;
    protected var _numRows :int;
    
    protected var _cellSize :int;
    protected var _cellSizeInv :Number;
    
    protected var _isDetectingCollisions :Boolean;
}

}