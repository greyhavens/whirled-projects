package popcraft.battle.geom {
    
import com.threerings.util.Assert;

import com.whirled.contrib.core.util.Collision;

import popcraft.battle.Unit;
    
public class CollisionObject
{
    public function CollisionObject (unit :Unit)
    {
        _unit = unit;
    }
    
    public function addToGrid (grid :CollisionGrid) :void
    {
        if (null != _grid) {
            this.removeFromGrid();
        }
        
        // units must be able to fit into a single grid cell
        Assert.isTrue(_unit.unitData.collisionRadius * 2 <= grid.cellSize);
        
        var cell :CollisionGridCell = grid.getCellAt(_unit.unitLoc);
        
        Assert.isNotNull(cell, "units should not leave the battlefield bounds");
        
        _grid = grid;
        _cell = cell;
        
        // stick this object at the head of the cell's object list
        
        var oldHead :CollisionObject = _cell.listHead;
        _cell.listHead = this;
        _next = oldHead;
        
        if (null != oldHead) {
            oldHead._prev = this;
        }
    }
    
    public function removeFromGrid () :void
    {
        if (null == _grid) {
            return;
        }
        
        // remove this object from the cell's object list
        
        if (null != _prev) {
            _prev._next = _next;
        } else {
            // if prev is null, we were at the head of the list
            _cell.listHead = _next;
        }
        
        if (null != _next) {
            _next._prev = _prev;
        }
        
        _grid = null;
        _cell = null;
        _prev = null;
        _next = null;
    }
    
    public function detectCollisions () :void
    {
        if (null == _grid) {
            return;
        }
        
        // we need to check for collisions against all objects
        // after us in our cell's object list, and with all objects
        // in the four neighboring cells E, SE, S, SW
        
        this.detectCollisionsInList(_next);
        
        var cellX :int = _cell.x;
        var cellY :int = _cell.y;
        
        for (var i :int = 0; i < 4; ++i) {
            
            var cell :CollisionGridCell;
            
            switch (i) {
            case 0: cell = _grid.getCell(cellX + 1, cellY); break;      // East
            case 1: cell = _grid.getCell(cellX + 1, cellY + 1); break;  // South-East
            case 2: cell = _grid.getCell(cellX, cellY + 1); break;      // South
            case 3: cell = _grid.getCell(cellX - 1, cellY + 1); break;  // South-West
            }
            
            if (null != cell) {
                this.detectCollisionsInList(cell.listHead);
            }
        }
        
    }
    
    protected function detectCollisionsInList (obj :CollisionObject) :void
    {
        while (null != obj) {
            
            var otherUnit :Unit = obj._unit;
            
            if (Collision.circlesIntersect(_unit.unitLoc, _unit.unitData.collisionRadius, otherUnit.unitLoc, otherUnit.unitData.collisionRadius)) {
                // generate a collision event for the objects involved
                // @TODO
                trace("collision!");
            }
            
            obj = obj._next;
        }
    }
    
    protected var _unit :Unit;
    
    protected var _grid :CollisionGrid;
    protected var _cell :CollisionGridCell;
    protected var _prev :CollisionObject;
    protected var _next :CollisionObject;

}

}