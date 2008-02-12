package popcraft.battle.geom {
    
import popcraft.battle.Unit;
    
public class UnitGeometry
{
    public function UnitGeometry (unit :Unit, grid :CollisionGrid)
    {
        _unit = unit;
        _unitCollisionRadius = unit.unitData.collisionRadius;
        
        _numColsRows = Math.ceil((_unitCollisionRadius * 2) * CollisionGrid.GRID_TILE_SIZE_INV);
    }
    
    public function get unit () :Unit
    {
        return _unit;
    }
    
    public function locationChanged () :void
    {
        // units that have no collision geometry don't go in the collision grid
        if (_numColsRows <= 0) {
            return;
        }
        
        var newCol :int = (unit.x - (_unitCollisionRadius * 0.5)) * CollisionGrid.GRID_TILE_SIZE_INV;
        var newRow :int = (unit.y - (_unitCollisionRadius * 0.5)) * CollisionGrid.GRID_TILE_SIZE_INV;
        
        if (newCol != _gridCol || newRow != _gridRow || !_inCollisionGrid) {
            
            if (!_inCollisionGrid) {
                _grid.removeUnitAt(this, _gridCol, _gridRow, _numColsRows, _numColsRows);
                _inCollisionGrid = true;
            }
            
            _gridCol = newCol;
            _gridRow = newRow;
            _grid.addUnitAt(this, _gridCol, _gridRow, _numColsRows, _numColsRows); 
        }
    }
    
    public function unitDestroyed () :void
    {
        if (_numColsRows <= 0) {
            return;
        }
        
        if (_inCollisionGrid) {
            _grid.removeUnitAt(this, _gridCol, _gridRow, _numColsRows, _numColsRows);
        }
    }
    
    protected var _grid :CollisionGrid;
    protected var _unit :Unit;
    protected var _gridCol :int;
    protected var _gridRow :int;
    
    protected var _inCollisionGrid :Boolean;
    
    // We can cache these values because unit collision radii
    // never change.
    protected var _unitCollisionRadius :Number;
    protected var _numColsRows :int;
}

}