package popcraft.battle.ai {

import popcraft.battle.*;
import com.whirled.contrib.core.ObjectMessage;

public class DetectEnemyTask extends AITaskBase
{
    public static const NAME :String = "DetectEnemyTask";
    public static const MSG_DETECTED_ENEMY = "DetectEnemyTask_DetectedEnemy";

    override public function update (dt :Number, obj :AppObject) :Boolean
    {
        super.update(dt, obj);

        var unit :CreatureUnit = (obj as CreatureUnit);

        // check to see if there are any enemies nearby
        var enemy :CreatureUnit = unit.findEnemyToAttack();

        if (null != enemy) {
            this.parentTask.receiveMessage(new ObjectMessage(MSG_DETECTED_ENEMY, enemy.id));
            return true;
        } else {
            return false;
        }
    }

    override public function clone () :ObjectTask
    {
        return new DetectEnemyTask();
    }

    override public function get name () :String
    {
        return NAME;
    }

}

}
