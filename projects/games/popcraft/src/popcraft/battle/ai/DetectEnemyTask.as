package popcraft.battle.ai {

import popcraft.battle.*;

public class DetectEnemyTask extends DetectCreatureTask
{
    public static const NAME :String = "DetectEnemyTask";
    
    public function DetectEnemyTask ()
    {
        super(NAME, DetectEnemyTask.isEnemyPredicate);
    }
    
    static protected function isEnemyPredicate (thisCreature :CreatureUnit, thatCreature :CreatureUnit) :Boolean
    {
        return (
                (thisCreature.owningPlayerId != thatCreature.owningPlayerId) && 
                (thisCreature.isUnitInRange(thatCreature, thisCreature.unitData.detectRadius))
               );
    }
}

}
