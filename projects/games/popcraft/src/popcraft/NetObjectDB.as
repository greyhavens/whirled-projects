package popcraft {
    
import com.whirled.contrib.core.*;

import popcraft.battle.CreatureUnit;

public class NetObjectDB extends ObjectDB
{
    public function NetObjectDB ()
    {
    }
    
    override protected function beginUpdate (dt :Number) :void
    {
        // update the simulation (objects will move)
        super.beginUpdate(dt);
        
        // detect collisions
        var creatureRefs :Array = this.getObjectRefsInGroup(CreatureUnit.GROUP_NAME);
        for each (var ref :SimObjectRef in creatureRefs) {
            if (!ref.isNull) {
                var creature :CreatureUnit = ref.object as CreatureUnit;
                creature.detectCollisions();
            }
        }
    }
    
    override protected function finalizeObjectDestruction (obj :SimObject) :void
    {
        // remove dead creatures from the collision grid
        if (obj is CreatureUnit) {
            var creature :CreatureUnit = obj as CreatureUnit;
            creature.removeFromCollisionGrid();
        }
        
        super.finalizeObjectDestruction(obj);
    }
}

}