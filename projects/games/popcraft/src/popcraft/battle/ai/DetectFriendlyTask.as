package popcraft.battle.ai {

import popcraft.battle.*;

public class DetectFriendlyTask extends DetectCreatureTask
{
    public static const NAME :String = "DetectFriendlyTask";
    
    public function DetectFriendlyTask ()
    {
        super(NAME, DetectFriendlyTask.isFriendlyPredicate);
    }
    
    static protected function isFriendlyPredicate (thisCreature :CreatureUnit, thatCreature :CreatureUnit) :Boolean
    {
        return (
                (thisCreature.owningPlayerId == thatCreature.owningPlayerId) && 
                (thisCreature.isUnitInRange(thatCreature, thisCreature.unitData.detectRadius))
               );
    }
}

}
