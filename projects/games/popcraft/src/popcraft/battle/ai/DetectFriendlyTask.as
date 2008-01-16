package popcraft.battle.ai {

import popcraft.battle.*;

public class DetectFriendlyTask extends FindCreatureTask
{
    public static const NAME :String = "DetectFriendlyTask";
    public static const MSG_DETECTED_ENEMY :String = "DetectFriendlyTask_DetectedFriendly";
    
    public function DetectFriendlyTask ()
    {
        super(NAME, MSG_DETECTED_ENEMY, DetectFriendlyTask.isFriendlyPredicate);
    }
    
    static protected function isFriendlyPredicate (thisCreature :CreatureUnit, thatCreature :CreatureUnit) :Boolean
    {
        return (thisCreature.owningPlayerId == thatCreature.owningPlayerId && thisCreature.isUnitInDetectRange(thatCreature));
    }
}

}
