package popcraft.battle.ai {

import com.threerings.flashbang.GameObjectRef;

import popcraft.battle.CreatureUnit;

public class AttackApproachingEnemiesTask extends AITaskTree
{
    public function AttackApproachingEnemiesTask (detectDelay :Number = 1)
    {
        _detectDelay = Math.max(detectDelay, 0);
        detectEnemies();
    }

    protected function detectEnemies () :void
    {
        // let's look for an enemy every so often

        var detectSequence :AITaskSequence = new AITaskSequence(true);
        detectSequence.addSequencedTask(new DetectCreatureAction(AIPredicates.isAttackableEnemyPredicate));
        detectSequence.addSequencedTask(new AITimerTask(_detectDelay));

        addSubtask(detectSequence);
    }

    override protected function receiveSubtaskMessage (subtask :AITask, messageName :String,
        data :Object) :void
    {
        if (messageName == AITaskSequence.MSG_SEQUENCEDTASKMESSAGE) {
            var message :SequencedTaskMessage = data as SequencedTaskMessage;
            var detectedCreature :CreatureUnit = message.data as CreatureUnit;

            // unit detected - start attacking
            clearSubtasks();
            addSubtask(new AttackUnitTask(detectedCreature.ref, false, -1));

        } else if (messageName == AITaskTree.MSG_SUBTASKCOMPLETED && subtask.name == AttackUnitTask.NAME) {

            // unit killed - resume detecting
            clearSubtasks();
            detectEnemies();
        }
    }

    protected var _detectDelay :Number = 1;
}

}
