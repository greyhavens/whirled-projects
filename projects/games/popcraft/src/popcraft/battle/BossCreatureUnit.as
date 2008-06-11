package popcraft.battle {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.tasks.*;

import popcraft.*;
import popcraft.battle.ai.*;

/**
 * Professor Weardd, PhD in Postmortem Ambulation
 */
public class BossCreatureUnit extends ColossusCreatureUnit
{
    public function BossCreatureUnit (owningPlayerId :uint)
    {
        super(owningPlayerId, Constants.UNIT_TYPE_BOSS, new BossAI(this));
    }
}

}

import com.threerings.flash.Vector2;

import popcraft.*;
import popcraft.battle.*;
import popcraft.battle.ai.*;

class BossAI extends ColossusAI
{
    public static const NAME :String = "BossAI";

    public function BossAI (unit :BossCreatureUnit)
    {
        super(unit);
    }

    override public function get name () :String
    {
        return NAME;
    }

    override public function update (dt :Number, creature :CreatureUnit) :uint
    {
        if (_unit.health == 1) {
            _unit.health = 2;
            _unit.isInvincible = true;

            // return to home base and recharge there
            var ourBaseLoc :Vector2 = GameContext.baseLocs[_unit.owningPlayerId];
            var rechargeSequence :AITaskSequence = new AITaskSequence(false);
            rechargeSequence.addSequencedTask(new MoveToLocationTask("ReturnToBase", ourBaseLoc.clone()));
            rechargeSequence.addSequencedTask(new RegenerateTask(REGENERATE_RATE));

            this.clearSubtasks();
            this.addSubtask(rechargeSequence);
        }

        return super.update(dt, creature);
    }

    override protected function receiveSubtaskMessage (task :AITask, messageName :String, data :Object) :void
    {
        if (messageName == AITaskSequence.MSG_SEQUENCEDTASKCOMPLETED) {
            var subtask :AITask = data as AITask;
            if (subtask.name == RegenerateTask.NAME) {
                // we finished regenerating. go back out and fight!
                _unit.isInvincible = false;
                this.restartAI();
                return;
            }
        }

        super.receiveSubtaskMessage(task, messageName, data);
    }

    protected static const REGENERATE_RATE :Number = 10;
}

class RegenerateTask extends AITask
{
    public static const NAME :String = "Regenerate";

    public function RegenerateTask (regenRate :Number)
    {
        _regenRate = regenRate;
    }

    override public function update (dt :Number, creature :CreatureUnit) :uint
    {
        creature.health += (dt * _regenRate);
        return (creature.health < creature.maxHealth ? AITaskStatus.ACTIVE : AITaskStatus.COMPLETE);
    }

    override public function get name () :String
    {
        return NAME;
    }

    protected var _regenRate :Number;
}
