package popcraft.battle {

import com.threerings.util.ArrayUtil;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.tasks.*;

import popcraft.*;
import popcraft.battle.ai.*;

/**
 * Colossus
 */
public class ColossusCreatureUnit extends CreatureUnit
{
    public function ColossusCreatureUnit (owningPlayerId :uint)
    {
        super(Constants.UNIT_TYPE_COLOSSUS, owningPlayerId);
        _ai = new ColossusAI(this);
    }

    override protected function get aiRoot () :AITask
    {
        return _ai;
    }

    override protected function update (dt :Number) :void
    {
        // expire old movement penalties
        var attackerExpired :Boolean;
        var timeNow :Number = this.dbTime;
        while (_attackers.length > 0) {
            var oldestRecord :AttackRecord = _attackers[_attackers.length - 1];
            if (timeNow >= oldestRecord.expirationTime) {
                attackerExpired = true;
                _attackers.pop();
            } else {
                break;
            }
        }

        if (attackerExpired) {
            this.updateSpeedScale();
        }

        super.update(dt);
    }

    override public function receiveAttack (attack :UnitAttack) :void
    {
        super.receiveAttack(attack);

        var numAttackers :int = _attackers.length;

        // Every time the colossus gets hit, he is slowed a bit, and a timer
        // is started that will remove the movement penalty after a set time
        // (unless he is hit again by the same attacker)

        var attacker :SimObjectRef = attack.sourceUnitRef;

        var index :int = ArrayUtil.indexIf(
            _attackers,
            function (record :AttackRecord) :Boolean { return record.attacker == attacker; });

        var ar :AttackRecord;
        if (index >= 0) {
            ar = _attackers[index];
        } else {
            ar = new AttackRecord();
            ar.attacker = attacker;
            _attackers.push(ar);
        }

        ar.expirationTime = this.dbTime + SPEED_LOSS_EXPIRATION_TIME;

        _attackers.sort(AttackRecord.compare);

        if (numAttackers != _attackers.length) {
            this.updateSpeedScale();
        }
    }

    protected function updateSpeedScale () :void
    {
        // calculate speed modification
        this.speedScale = Math.max(MIN_SPEED_MOD, 1.0 - (_attackers.length * SPEED_LOSS_PER_DAMAGE));
    }

    protected function get dbTime () :Number
    {
        return (this.db as NetObjectDB).dbTime;
    }

    protected var _ai :ColossusAI;
    protected var _attackers :Array = [];

    protected static const SPEED_LOSS_PER_DAMAGE :Number = 0.1;
    protected static const MIN_SPEED_MOD :Number = 0.3;
    protected static const SPEED_LOSS_EXPIRATION_TIME :Number = 1;
}

}

class AttackRecord
{
    public var attacker :SimObjectRef;
    public var expirationTime :Number;

    public static function compare (a :AttackRecord, b :AttackRecord) :int
    {
        if (a.expirationTime < b.expirationTime) {
            return 1;
        } else if (a.expirationTime > b.expirationTime) {
            return -1;
        } else {
            return 0;
        }
    }
};

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.util.*;
import flash.geom.Point;

import popcraft.*;
import popcraft.battle.*;
import popcraft.battle.ai.*;
import com.threerings.util.Log;

class DetectColossusTargetAction extends DetectCreatureAction
{
    public static const NAME :String = "DetectColossusTargetAction";
    public static const DETECTED_TARGET_MSG :String = "DetectedColossusTarget";

    public function DetectColossusTargetAction ()
    {
        super(DetectCreatureAction.createNotEnemyOfTypesPredicate([Constants.UNIT_TYPE_COLOSSUS]));
    }

    override protected function handleDetectedCreature (thisCreature :CreatureUnit, detectedCreature :CreatureUnit) :void
    {
        var detectedUnit :Unit = detectedCreature;
        if (null == detectedUnit) {
            // are we in range of an enemy base?
            var baseRefs :Array = GameContext.netObjects.getObjectRefsInGroup(PlayerBaseUnit.GROUP_NAME);
            for each (var baseRef :SimObjectRef in baseRefs) {
                var base :PlayerBaseUnit = baseRef.object as PlayerBaseUnit;
                if (null != base && DetectCreatureAction.isEnemyPredicate(thisCreature, base)) {
                    detectedUnit = base;
                    break;
                }
            }
        }

        if (null != detectedUnit) {
            this.sendParentMessage(DETECTED_TARGET_MSG, detectedUnit);
        }
    }

    override public function get name () :String
    {
        return NAME;
    }

    override public function clone () :AITask
    {
        return new DetectColossusTargetAction();
    }
}

/**
 * Goals:
 * (Priority 1) Attack groups of approaching enemies.
 * (Priority 1) Attack enemy base
 */
class ColossusAI extends AITaskTree
{
    public function ColossusAI (unit :ColossusCreatureUnit)
    {
        _unit = unit;

        this.beginAttackEnemyBase();

        // scan for units in our immediate vicinity
        var detectPredicate :Function = DetectCreatureAction.createNotEnemyOfTypesPredicate([Constants.UNIT_TYPE_COLOSSUS]);
        var scanSequence :AITaskSequence = new AITaskSequence(true);
        scanSequence.addSequencedTask(new DelayUntilTask("DelayUntilNotAttacking", DelayUntilTask.notAttackingPredicate));
        scanSequence.addSequencedTask(new DetectColossusTargetAction());
        this.addSubtask(scanSequence);
    }

    protected function beginAttackEnemyBase () :void
    {
        _inRangeOfBase = false;

        _targetBaseRef = _unit.getEnemyBaseRef();
        if (_targetBaseRef.isNull) {
            return;
        }

        this.addSubtask(new MoveToAttackLocationTask(_targetBaseRef, true, -1));
        this.addSubtask(new DelayUntilTask(TARGET_BASE_DIED, DelayUntilTask.createUnitDiedPredicate(_targetBaseRef)));
    }

    override public function get name () :String
    {
        return "ColossusAI";
    }

    override protected function receiveSubtaskMessage (task :AITask, messageName :String, data :Object) :void
    {
        if (messageName == AITaskTree.MSG_SUBTASKCOMPLETED) {
            if (task.name == TARGET_BASE_DIED) {
                // find a new base to attack
                this.beginAttackEnemyBase();
            } else if (task.name == MoveToAttackLocationTask.NAME) {
                // we're in range of our base
                _inRangeOfBase = true;
            }
        }

        if (messageName == AITaskSequence.MSG_SEQUENCEDTASKMESSAGE) {
            // we detected an enemy - attack it
            var msg :SequencedTaskMessage = data as SequencedTaskMessage;
            var enemyUnit :Unit = msg.data as Unit;
            _unit.sendAttack(enemyUnit, _unit.unitData.weapon);
        }
    }

    protected var _unit :ColossusCreatureUnit;
    protected var _targetBaseRef :SimObjectRef = SimObjectRef.Null();
    protected var _inRangeOfBase :Boolean;

    protected static const TARGET_BASE_DIED :String = "TargetBaseDied";

    protected static const log :Log = Log.getLog(ColossusAI);
}
