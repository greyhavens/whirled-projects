package popcraft.battle.geom {
    
import com.threerings.util.ArrayUtil;
import com.threerings.util.Assert;

import flash.geom.Rectangle;
    
public class CollisionGrid
{
    public static const GRID_TILE_SIZE :int = 20;
    public static const GRID_TILE_SIZE_INV :Number = 1 / GRID_TILE_SIZE;
    
    public function CollisionGrid (boardWidth :int, boardHeight :int)
    {
        _numCols = Math.ceil(boardWidth / GRID_TILE_SIZE);
        _numRows = Math.ceil(boardHeight / GRID_TILE_SIZE);
        
        var gridSize :int = _numCols * _numRows;
        
        _bucketGrid = new Array(gridSize);
        
        for (var i :int = 0; i < gridSize; ++i) {
            _bucketGrid[i] = new Array();
        }
    }
    
    public function addUnit (ug :UnitGeometry) :void
    {
        this.forEachBucketInRect(ug.collisionGridRect, addToBucket);
        
        function addToBucket (bucket :Array) :void {
            bucket.push(ug);
        }
    }
    
    public function removeUnit (ug :UnitGeometry) :void
    {
        this.forEachBucketInRect(ug.collisionGridRect, removeFromBucket);
        
        function removeFromBucket (bucket :Array) :void  {
            // O(n)! But we assume that most buckets will have
            // 0 or 1 units in them, and only very seldomly 
            // have more than that.
            var removed :Boolean = ArrayUtil.removeFirst(bucket, ug);
            
            // game should never attempt to remove a unit from a bucket it wasn't in
            Assert.isTrue(removed);
        }
    }
    
    public function getPotentialCollisions (gridRect :Rectangle, excludedUnit :UnitGeometry, outCollisions :Array) :void
    {
        outCollisions.length = 0;
        
        this.forEachBucketInRect(gridRect, getBucketContents);
        
        function getBucketContents (bucket :Array) :void {
                
            for (var index :int = 0; index < bucket.length; ++index) {
                var ug :UnitGeometry = bucket[index];
                
                if (ug != excludedUnit) {
                    outCollisions.push(ug);
                }
            }
        }
    }
    
    protected function forEachBucketInRect (gridRect :Rectangle, fn :Function) :void
    {
        if (gridRect.x >= _numCols || (gridRect.x + gridRect.width <= 0) || gridRect.y >= _numRows || (gridRect.y + gridRect.height <= 0)) {
            return;
        }
        
        var xStart :int = clamp(gridRect.x, 0, _numCols - 1);
        var yStart :int = clamp(gridRect.y, 0, _numRows - 1);
        
        var xMax :int = clamp(gridRect.x + gridRect.width, 0, _numCols - 1);
        var yMax :int = clamp(gridRect.y + gridRect.height, 0, _numRows - 1);
        
        for (var y :int = yStart; y <= yMax; ++y) {
            for (var x :int = xStart; x <= xMax; ++x) {
                var bucket :Array = _bucketGrid[(y * _numCols) + x];
                fn(bucket);
            }
        }
    }
    
    protected static function clamp (val :Number, min :Number, max :Number) :Number
    {
        val = Math.max(val, min);
        return Math.min(val, max);
    }
    
    protected var _bucketGrid :Array;
    protected var _numCols :int;
    protected var _numRows :int;
}

}