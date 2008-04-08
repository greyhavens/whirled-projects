package popcraft.battle.ai {

import com.whirled.contrib.simplegame.SimObjectRef;

public class AttackApproachingEnemiesTask extends AITaskTree
{
    public function AttackApproachingEnemiesTask ()
    {
        this.addSubtask(new DetectEnemyTask());
    }

    override protected function receiveSubtaskMessage (subtask :AITask, messageName :String, data :Object) :void
    {
        if (messageName == MSG_SUBTASKCOMPLETED) {
            switch (subtask.name) {

            case DetectEnemyTask.NAME:
                // unit detected. start attacking
                var enemyRef :SimObjectRef = (subtask as DetectEnemyTask).detectedCreatureRef;

                this.clearSubtasks();
                this.addSubtask(new AttackUnitTask(enemyRef, false, -1));
                break;

            case AttackUnitTask.NAME:
                // unit killed. get back to detecting.
                this.clearSubtasks();
                this.addSubtask(new DetectEnemyTask());
                break;

            }
        }
    }

}

}
