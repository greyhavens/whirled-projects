package popcraft.battle.ai {
    
import com.whirled.contrib.core.Vector2;

import popcraft.battle.CreatureUnit;

public class AIMoveToTask implements AITask
{
    public static const NAME :String = "MoveToTask";
    
    public function AIMoveToTask (destination :Vector2, speed :Number)
    {
        _destination = destination;
    }

    public function get name () :String
    {
        return NAME;
    }
    
    public function update (dt :Number, creature :CreatureUnit) :uint
    {
        var curLoc :Vector2 = new Vector2(creature.x, creature.y);
        
        // are we there yet?
        if (curLoc.similar(_destination, E)) {
            return AITaskStatus.COMPLETE;
        }
        
        var nextLoc :Vector2 = _destination.getSubtract(curLoc);
        
        var remainingDistance :Number = nextLoc.normalizeAndGetLength();
        
        // don't overshoot the destination
        var distance :Number = Math.min(speed * dt, remainingDistance);
        
        // calculate our next location
        nextLoc.scale(distance);
        nextLoc.add(curLoc);
        
        creature.requestSetLocation(nextLoc);
        
        return AITaskStatus.ACTIVE;
    }
    
    protected var _destination :Vector2;
    
    protected var _speed :Number;
    
    protected static const E :Number = 0.001;
    
}

}