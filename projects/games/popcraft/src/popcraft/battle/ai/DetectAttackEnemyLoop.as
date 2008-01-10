package popcraft.battle.ai {

import com.whirled.contrib.core.ObjectMessage;
import com.whirled.contrib.core.ObjectTask;
import popcraft.battle.ai.AITaskBase.clone;

public class DetectAttackEnemyLoop extends AITaskBase
{
    public function DetectAttackEnemyLoop()
    {
        this.addSubtask(new DetectEnemyTask());
    }

    override public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        if (msg.name == DetectEnemyTask.MSG_DETECTED_ENEMY) {

            // when we detect an enemy, attack it, then immediately revert
            // back to detecting when attack sequence is over.

            var attackDetectQueue :AITaskQueue = new AITaskQueue(false);
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

}

}
