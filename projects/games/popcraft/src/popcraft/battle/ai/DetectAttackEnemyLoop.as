package popcraft.battle.ai {

import com.whirled.contrib.core.ObjectMessage;
import com.whirled.contrib.core.ObjectTask;
import popcraft.battle.ai.AIStateTree.clone;
import popcraft.battle.ai.AIStateTree.name;

public class DetectAttackEnemyLoop extends AIStateTree
{
    public static const NAME :String = "DetectAttackEnemyLoop";

    public function DetectAttackEnemyLoop()
    {
        this.addSubtask(new DetectEnemyTask());
    }

    override public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        if (msg.name == DetectEnemyTask.MSG_DETECTED_ENEMY) {

            // when we detect an enemy, attack it, then immediately revert
            // back to detecting when attack sequence is over.

            var attackDetectQueue :AIStateQueue = new AIStateQueue(false);
            attackDetectQueue.addTask(new AttackEnemyTask(msg.data as uint));
            attackDetectQueue.addTask(new DetectEnemyTask());

            this.clearSubtasks();
            this.addSubtask(attackDetectQueue);
        } else {
            super.receiveMessage(msg);
        }
    }

    override public function clone() :ObjectTask
    {
        return new DetectAttackEnemyLoop();
    }

    override public function get name () :String
    {
        return NAME;
    }

}

}
