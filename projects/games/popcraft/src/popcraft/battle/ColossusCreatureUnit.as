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
    public function ColossusCreatureUnit (owningPlayerIndex :int, unitType :int = Constants.UNIT_TYPE_COLOSSUS, ai :ColossusAI = null)
    {
        super(owningPlayerIndex, unitType);
        _ai = (null != ai ? ai : new ColossusAI(this));
        _ai.init();
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
            updateSpeedScale();
        }

        super.update(dt);
    }

    override public function receiveAttack (attack :UnitAttack, maxDamage :Number = Number.MAX_VALUE) :Number
    {
        // Every time the colossus gets hit, he is slowed a bit, and a timer
        // is started that will remove the movement penalty after a set time
        // (unless he is hit again by the same attacker)

        var attacker :SimObjectRef = attack.sourceUnitRef;
        var index :int = ArrayUtil.indexIf(
            _attackers,
            function (record :AttackRecord) :Boolean { return record.attacker == attacker; });

        var numAttackers :int = _attackers.length;
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
            updateSpeedScale();
        }

        return super.receiveAttack(attack, maxDamage);
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
    protected static const SPEED_LOSS_EXPIRATION_TIME :Number = 1.6;
}

}

import com.whirled.contrib.simplegame.SimObjectRef;

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
