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
    public function BossCreatureUnit (owningPlayerIndex :int)
    {
        super(owningPlayerIndex, Constants.UNIT_TYPE_BOSS, new BossAI(this));
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
        _boss = unit;
    }

    override public function get name () :String
    {
        return NAME;
    }

    override public function init () :void
    {
        _homeLoc = _boss.owningPlayerInfo.workshop.unitSpawnLoc;
        super.init();
    }

    override public function update (dt :Number, creature :CreatureUnit) :int
    {
        // return home to recharge when health runs out
        if (_boss.health == 1) {
            _boss.health = Math.max(2, _boss.health);
            _boss.isInvincible = true;

            // return to home base and recharge there
            var rechargeSequence :AITaskSequence = new AITaskSequence();
            rechargeSequence.addSequencedTask(new MoveToLocationTask("ReturnToBase", _homeLoc.clone()));
            rechargeSequence.addSequencedTask(new RegenerateTask(_boss.maxHealth / REGENERATE_TIME));

            clearSubtasks();
            addSubtask(rechargeSequence);
        }

        return super.update(dt, creature);
    }

    override protected function receiveSubtaskMessage (task :AITask, messageName :String, data :Object) :void
    {
        if (messageName == AITaskSequence.MSG_SEQUENCEDTASKCOMPLETED) {
            var subtask :AITask = data as AITask;
            if (subtask.name == RegenerateTask.NAME) {
                // we finished regenerating. go back out and fight!
                _boss.isInvincible = false;
                restartAI();
                return;
            }
        }

        super.receiveSubtaskMessage(task, messageName, data);
    }

    protected var _boss :BossCreatureUnit;
    protected var _homeLoc :Vector2;

    protected static const REGENERATE_TIME :Number = 10;
}

class RegenerateTask extends AITask
{
    public static const NAME :String = "Regenerate";

    public function RegenerateTask (regenRate :Number)
    {
        _regenRate = regenRate;
    }

    override public function update (dt :Number, creature :CreatureUnit) :int
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
