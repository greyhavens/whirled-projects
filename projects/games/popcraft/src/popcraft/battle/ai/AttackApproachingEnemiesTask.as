package popcraft.battle.ai {

import com.whirled.contrib.simplegame.SimObjectRef;

import popcraft.battle.CreatureUnit;

public class AttackApproachingEnemiesTask extends AITaskTree
{
    public function AttackApproachingEnemiesTask (detectDelay :Number = 1)
    {
        _detectDelay = Math.max(detectDelay, 0);

        this.detectEnemies();
    }

    protected function detectEnemies () :void
    {
        // let's look for an enemy every so often

        var detectSequence :AITaskSequence = new AITaskSequence(true);
        detectSequence.addSequencedTask(new DetectCreatureAction(DetectCreatureAction.isAttackableEnemyPredicate));
        detectSequence.addSequencedTask(new AITimerTask(_detectDelay));

        this.addSubtask(detectSequence);
    }

    override protected function receiveSubtaskMessage (subtask :AITask, messageName :String, data :Object) :void
    {
        if (messageName == AITaskSequence.MSG_SEQUENCEDTASKMESSAGE) {
            var message :SequencedTaskMessage = data as SequencedTaskMessage;
            var detectedCreature :CreatureUnit = message.data as CreatureUnit;

            // unit detected - start attacking
            this.clearSubtasks();
            this.addSubtask(new AttackUnitTask(detectedCreature.ref, false, -1));

        } else if (messageName == AITaskTree.MSG_SUBTASKCOMPLETED && subtask.name == AttackUnitTask.NAME) {

            // unit killed - resume detecting
            this.clearSubtasks();
            this.detectEnemies();
        }
    }

    protected var _detectDelay :Number = 1;

}

}
