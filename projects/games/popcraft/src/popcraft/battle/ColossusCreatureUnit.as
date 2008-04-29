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

        _ai = new ColossusAI(this, this.findEnemyBaseToAttack());
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
            ar.expirationTime = this.dbTime + SPEED_LOSS_EXPIRATION_TIME;
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

    protected static const SPEED_LOSS_PER_DAMAGE :Number = 0.2;
    protected static const MIN_SPEED_MOD :Number = 0.2;
    protected static const SPEED_LOSS_EXPIRATION_TIME :Number = 1.5;
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

/**
 * Goals:
 * (Priority 1) Attack groups of approaching enemies.
 * (Priority 1) Attack enemy base
 */
class ColossusAI extends AITaskTree
{
    public function ColossusAI (unit :ColossusCreatureUnit, targetBaseRef :SimObjectRef)
    {
        _unit = unit;
        _targetBaseRef = targetBaseRef;

        this.beginAttackBase();

        // scan for units in our immediate vicinity every couple of seconds
        var detectPredicate :Function = DetectCreatureAction.createNotEnemyOfTypesPredicate([Constants.UNIT_TYPE_COLOSSUS]);
        var scanSequence :AITaskSequence = new AITaskSequence(true);
        scanSequence.addSequencedTask(new AITimerTask(2));
        scanSequence.addSequencedTask(new DetectCreatureAction(detectPredicate));
        this.addSubtask(scanSequence);
    }

    protected function beginAttackBase () :void
    {
        if (_targetBaseRef.isNull) {
            _targetBaseRef = _unit.findEnemyBaseToAttack();
        }

        if (!_targetBaseRef.isNull) {
            this.addSubtask(new AttackUnitTask(_targetBaseRef, true, -1));
        }
    }

    override public function get name () :String
    {
        return "ColossusAI";
    }

    override protected function receiveSubtaskMessage (task :AITask, messageName :String, data :Object) :void
    {
        if (messageName == AITaskSequence.MSG_SEQUENCEDTASKMESSAGE) {
            var msg :SequencedTaskMessage = data as SequencedTaskMessage;
            var enemyUnit :CreatureUnit = msg.data as CreatureUnit;

            // we detected an enemy - attack it
            //log.info("detected enemy - attacking");
            _unit.sendAttack(enemyUnit, _unit.unitData.weapon);
        } else if (messageName == AttackUnitTask.NAME) {
            // the base we were targeting died - find a new one
            this.beginAttackBase();
        }
    }

    protected var _unit :ColossusCreatureUnit;
    protected var _targetBaseRef :SimObjectRef;

    protected static const log :Log = Log.getLog(ColossusAI);
}
