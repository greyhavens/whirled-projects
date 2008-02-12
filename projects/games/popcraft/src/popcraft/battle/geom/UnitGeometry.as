package popcraft.battle.geom {
    
import com.threerings.util.Assert;
import com.whirled.contrib.core.Vector2;
import com.whirled.contrib.core.util.Collision;

import flash.geom.Rectangle;

import popcraft.battle.Unit;
    
public class UnitGeometry
{
    public function UnitGeometry (unit :Unit, grid :CollisionGrid)
    {
        _unit = unit;
        _radius = unit.unitData.collisionRadius;
        
        Assert.isTrue(_radius > 0);
        
        // unit collision geometry is a circle. we map that to a square for the purposes
        // of insertion into the CollisionGrid
        
        var widthHeight :Number = Math.ceil((_radius * 2) * CollisionGrid.GRID_TILE_SIZE_INV);
        Assert.isTrue(widthHeight > 0);
        
        _gridRect.width = widthHeight;
        _gridRect.height = widthHeight;
        _gridRect.x = Number.MAX_VALUE;
        _gridRect.y = Number.MAX_VALUE;
    }
    
    public function get unit () :Unit
    {
        return _unit;
    }
    
    public function setLocation () :void
    {
        _center.x = _unit.x;
        _center.y = _unit.y;
        
        var newCol :Number = Math.floor((_center.x - (_radius * 0.5)) * CollisionGrid.GRID_TILE_SIZE_INV);
        var newRow :Number = Math.floor((_center.y - (_radius * 0.5)) * CollisionGrid.GRID_TILE_SIZE_INV);
        
        // if the unit hasn't changed its location in the collision grid,
        // don't move it.
        
        if (newCol != _gridCol || newRow != _gridRow || !_inCollisionGrid) {
            
            if (!_inCollisionGrid) {
                _grid.removeUnit(this);
                _inCollisionGrid = true;
            }
            
            _gridRect.x = newCol;
            _gridRect.y = newRow;
            
            _grid.addUnit(this); 
        }
    }
    
    public function unitDestroyed () :void
    {
        if (_inCollisionGrid) {
            _grid.removeUnit(this);
        }
    }
    
    public function get collisionGridRect () :Rectangle
    {
        return _gridRect;
    }
    
    public function collidesWith (other :UnitGeometry) :Boolean
    {
        return Collision.circlesIntersect(_center, _radius, other._center, other._radius);
    }
    
    protected var _grid :CollisionGrid;
    protected var _gridRect :Rectangle = new Rectangle();
    
    protected var _unit :Unit;
    protected var _gridCol :int;
    protected var _gridRow :int;
    
    protected var _inCollisionGrid :Boolean;
    
    // cached values
    protected var _radius :Number;
    protected var _center :Vector2;
}

}