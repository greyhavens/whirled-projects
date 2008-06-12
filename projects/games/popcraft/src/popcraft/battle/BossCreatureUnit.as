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

    public function set escaping (val :Boolean) :void
    {
        _escaping = val;
    }

    override public function get speedScale () :Number
    {
        return (_escaping ? ESCAPE_SPEEDSCALE : super.speedScale);
    }

    protected var _escaping :Boolean;

    protected static const ESCAPE_SPEEDSCALE :Number = 4;
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

    override public function update (dt :Number, creature :CreatureUnit) :uint
    {
        if (_boss.health == 1 || GameContext.diurnalCycle.isDay) {
            _boss.escaping = true;
            _boss.health = 2;
            _boss.isInvincible = true;

            // return to home base and recharge there
            var ourBaseLoc :Vector2 = GameContext.baseLocs[_boss.owningPlayerId];
            var rechargeSequence :AITaskSequence = new AITaskSequence();
            rechargeSequence.addSequencedTask(new MoveToLocationTask("ReturnToBase", ourBaseLoc.clone()));
            rechargeSequence.addSequencedTask(new RegenerateTask(_boss.maxHealth / REGENERATE_TIME));
            rechargeSequence.addSequencedTask(new AIDelayUntilTask("WaitForNight", isNight));

            this.clearSubtasks();
            this.addSubtask(rechargeSequence);

        } else if (!_escaped && _boss.health <= (_boss.maxHealth * 0.5)) {
            _boss.escaping = true;
            _boss.isInvincible = true;

            // choose a new location to move to midway between the player base and his target
            // base
            var playerBaseLoc :Vector2 = GameContext.baseLocs[GameContext.localPlayerId];
            var playerTargetBaseLoc :Vector2 = GameContext.baseLocs[GameContext.localPlayerInfo.targetedEnemyId];
            var direction :Vector2 = playerTargetBaseLoc.subtract(playerBaseLoc);
            var distance :Number = direction.normalizeLocalAndGetLength();
            direction.scaleLocal(distance * 0.7);
            var newLoc :Vector2 = direction.addLocal(playerBaseLoc);

            this.clearSubtasks();
            this.addSubtask(new MoveToLocationTask(ESCAPE_TASK_NAME, newLoc));

            _escaped = true;
        }

        return super.update(dt, creature);
    }

    protected static function isNight (...ignored) :Boolean
    {
        return GameContext.diurnalCycle.isNight;
    }

    override protected function receiveSubtaskMessage (task :AITask, messageName :String, data :Object) :void
    {
        if (messageName == AITaskSequence.MSG_SEQUENCEDTASKCOMPLETED) {
            var subtask :AITask = data as AITask;
            if (subtask.name == RegenerateTask.NAME) {
                // we finished regenerating. go back out and fight!
                _boss.isInvincible = false;
                _boss.escaping = false;
                _escaped = false;
                this.restartAI();
                return;
            }
        } else if (messageName == AITaskTree.MSG_SUBTASKCOMPLETED && task.name == ESCAPE_TASK_NAME) {
            _boss.isInvincible = false;
            _boss.escaping = false;
            this.addSubtask(this.createScanForUnitTask());
        }

        super.receiveSubtaskMessage(task, messageName, data);
    }

    protected var _boss :BossCreatureUnit;
    protected var _escaped :Boolean;

    protected static const REGENERATE_TIME :Number = 25;
    protected static const ESCAPE_TASK_NAME :String = "Escape";
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
