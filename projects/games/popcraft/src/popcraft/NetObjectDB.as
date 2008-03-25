package popcraft {
    
import com.threerings.flash.DisplayUtil;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.components.*;
import com.whirled.contrib.simplegame.objects.*;

import flash.display.DisplayObject;

import popcraft.battle.*;

public class NetObjectDB extends ObjectDB
{
    public function NetObjectDB ()
    {
    }
    
    override protected function beginUpdate (dt :Number) :void
    {
        // update the simulation (objects will move)
        super.beginUpdate(dt);
        
        /*var collisionGrid :CollisionGrid = GameMode.instance.battleCollisionGrid;
        
        collisionGrid.beginDetectCollisions();
        
        // detect collisions
        var creatureRefs :Array = this.getObjectRefsInGroup(CreatureUnit.GROUP_NAME);
        for each (var ref :SimObjectRef in creatureRefs) {
            if (!ref.isNull) {
                var creature :CreatureUnit = ref.object as CreatureUnit;
                creature.detectCollisions();
            }
        }
        
        collisionGrid.endDetectCollisions();*/
        
        // depth-sort all the units
        DisplayUtil.sortDisplayChildren(GameMode.instance.battleUnitDisplayParent, displayObjectYSort);
    }
    
    protected static function displayObjectYSort (a :DisplayObject, b :DisplayObject) :int
    {
        var ay :Number = a.y;
        var by :Number = b.y;
        
        if (ay < by) {
            return -1;
        } else if (ay > by) {
            return 1;
        } else {
            return 0;
        }
    }
    
    /*override protected function finalizeObjectDestruction (obj :SimObject) :void
    {
        // remove dead creatures from the collision grid
        if (obj is CreatureUnit) {
            var creature :CreatureUnit = obj as CreatureUnit;
            creature.removeFromCollisionGrid();
        }
        
        super.finalizeObjectDestruction(obj);
    }*/
}

}