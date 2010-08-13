//
// $Id$

package popcraft.game.battle {

import com.threerings.flashbang.*;

import popcraft.*;
import popcraft.game.*;
import popcraft.game.battle.ai.*;
import popcraft.gamedata.*;

/**
 * Sappers are suicide-bombers. They deal heavy
 * damage to enemies and bases.
 */
public class SapperCreatureUnit extends CreatureUnit
{
    public function SapperCreatureUnit (owningPlayerIndex :int)
    {
        super(owningPlayerIndex, Constants.UNIT_TYPE_SAPPER);

        _sapperAI = new SapperAI(this);
    }

    override protected function get aiRoot () :AITask
    {
        return _sapperAI;
    }

    override public function sendAttack (targetUnitOrLoc :*, weapon :UnitWeaponData) :Number
    {
        var damage :Number = 0;

        if (!_hasAttacked) {
            // when the sapper attacks, he self-destructs
            damage = super.sendAttack(targetUnitOrLoc, weapon);
            _hasAttacked = true;
            if (_hasAttacked) {
                die();
            }

            if (damage > 0 && this.owningPlayerIndex == GameCtx.localPlayerIndex &&
                GameCtx.diurnalCycle.isDay) {
                // awarded for Delivery Boy damaging a base at sunrise
                // (if it's daytime, the only damage we can have done is to a base)
                ClientCtx.awardTrophy(Trophies.RUSHDELIVERY);
            }
        }

        return damage;
    }

    override public function die () :void
    {
        if (!_isDead) {
            _isDead = true;

            // when the sapper is killed, he explodes
            if (!_hasAttacked) {
                sendAttack(this.unitLoc, _unitData.weapon);
            }

            super.die();
        }
    }

    protected var _sapperAI :SapperAI;
    protected var _hasAttacked :Boolean;
}

}

import com.threerings.flashbang.*;
import com.threerings.flashbang.util.*;
import flash.geom.Point;

import popcraft.*;
import popcraft.game.battle.*;
import popcraft.game.battle.ai.*;
import com.threerings.util.Log;

/**
 * Goals:
 * (Priority 1) Attack groups of approaching enemies.
 * (Priority 1) Attack enemy base
 */
class SapperAI extends AITaskTree
{
    public function SapperAI (unit :SapperCreatureUnit)
    {
        _unit = unit;
        attackBaseAndScanForEnemyGroups();
    }

    protected function attackBaseAndScanForEnemyGroups () :void
    {
        clearSubtasks();

        if (_targetBaseRef.isNull) {
            _targetBaseRef = _unit.getEnemyBaseToAttack();
        }

        if (!_targetBaseRef.isNull) {
            addSubtask(new AttackUnitTask(_targetBaseRef, true, -1));
        }

        var sapperBlastRadius :Number = _unit.unitData.weapon.aoeRadius;

        var scanSequence :AITaskSequence = new AITaskSequence(true);
        scanSequence.addSequencedTask(new DetectCreatureGroupAction(
            SCAN_FOR_ENEMIES_TASK_NAME,
            SCAN_FOR_ENEMY_GROUP_SIZE,
            isSapperEnemyCreaturePred,
            AIPredicates.createIsGroupedEnemyPred(sapperBlastRadius - 15))); // this number is sort of fudged
        scanSequence.addSequencedTask(new AITimerTask(SCAN_FOR_ENEMIES_DELAY));

        addSubtask(scanSequence);
    }

    protected static function isSapperEnemyCreaturePred (thisCreature :CreatureUnit, thatCreature :CreatureUnit) :Boolean
    {
        return (thatCreature.unitType != Constants.UNIT_TYPE_COURIER &&
            AIPredicates.isAttackableEnemyPredicate(thisCreature, thatCreature));
    }

    override protected function receiveSubtaskMessage (subtask :AITask, messageName :String, data :Object) :void
    {
        if (messageName == AITaskSequence.MSG_SEQUENCEDTASKMESSAGE) {
            // we detected an enemy group - unbundle the message from the sequenced task
            var msg :SequencedTaskMessage = data as SequencedTaskMessage;
            var group :Array = msg.data as Array;
            //log.info("detected enemy group - bombing!");

            // try to attack the first enemy
            var enemy :CreatureUnit = group[0];
            clearSubtasks();
            addSubtask(new AttackUnitTask(enemy.ref, true, -1, DISABLE_COLLISIONS_AFTER, DISABLE_COLLISIONS_FOR));
        } else if (messageName == AITaskTree.MSG_SUBTASKCOMPLETED && subtask.name == AttackUnitTask.NAME) {
            // the unit we were going after died before we got to them
            attackBaseAndScanForEnemyGroups();
        }
    }

    override public function get name () :String
    {
        return "SapperAI";
    }

    protected var _unit :SapperCreatureUnit;
    protected var _targetBaseRef :GameObjectRef = GameObjectRef.Null();

    protected static const SCAN_FOR_ENEMIES_DELAY :Number = 1;
    protected static const SCAN_FOR_ENEMY_GROUP_SIZE :int = 2;
    protected static const DISABLE_COLLISIONS_AFTER :Number = 1;
    protected static const DISABLE_COLLISIONS_FOR :Number = 0.5;
    protected static const SCAN_FOR_ENEMIES_TASK_NAME :String = "ScanForEnemies";

    protected static const log :Log = Log.getLog(SapperAI);
}
