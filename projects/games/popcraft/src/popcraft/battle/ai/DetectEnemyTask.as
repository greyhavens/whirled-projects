package popcraft.battle.ai {

import com.whirled.contrib.core.ObjectMessage;

import popcraft.battle.*;

public class DetectEnemyTask extends FindCreatureTask
{
    public static const NAME :String = "DetectEnemyTask";
    public static const MSG_DETECTED_ENEMY = "DetectEnemyTask_DetectedEnemy";
    
    public function DetectEnemyTask ()
    {
        super(NAME, MSG_DETECTED_ENEMY, DetectEnemyTask.isEnemyPredicate);
    }
    
    static protected function isEnemyPredicate (thisCreature :CreatureUnit, thatCreature :CreatureUnit) :Boolean
    {
        return (thisCreature.owningPlayerId != thatCreature.owningPlayerId && thisCreature.isUnitInDetectRange(thatCreature));
    }
}

}
