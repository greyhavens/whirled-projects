package popcraft.battle {

import com.whirled.contrib.simplegame.*;

import popcraft.*;
import popcraft.data.*;
import popcraft.battle.ai.*;

/**
 * Sappers are suicide-bombers. They deal heavy
 * damage to enemies and bases.
 */
public class SapperCreatureUnit extends CreatureUnit
{
    public function SapperCreatureUnit (owningPlayerId :uint)
    {
        super(Constants.UNIT_TYPE_SAPPER, owningPlayerId);

        _sapperAI = new SapperAI(this, this.findEnemyBaseToAttack());
    }

    override protected function get aiRoot () :AITask
    {
        return _sapperAI;
    }

    override public function sendAttack (targetUnitOrLoc :*, weapon :UnitWeaponData) :Boolean
    {
        // when the sapper attacks, he self-destructs
        var success :Boolean = super.sendAttack(targetUnitOrLoc, weapon);

        if (success) {
            this.die();
        }

        return success;
    }

    override public function receiveAttack (attack :UnitAttack) :void
    {
        // if the sapper is killed by an attack, he explodes

        var wasDead :Boolean = _isDead;
        super.receiveAttack(attack);

        // prevent infinite recursion - don't explode if we're already dead
        if (!wasDead && _isDead) {
            this.sendAttack(this.unitLoc, _unitData.weapon);
        }
    }

    protected var _sapperAI :SapperAI;
}

}

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
class SapperAI extends AITaskTree
{
    public function SapperAI (unit :SapperCreatureUnit, targetBaseRef :SimObjectRef)
    {
        _unit = unit;
        _targetBaseRef = targetBaseRef;

        this.attackBaseAndScanForEnemyGroups();
    }

    protected function attackBaseAndScanForEnemyGroups () :void
    {
        this.clearSubtasks();

        if (_targetBaseRef.isNull) {
            _targetBaseRef = _unit.findEnemyBaseToAttack();
        }

        if (!_targetBaseRef.isNull) {
            this.addSubtask(new AttackUnitTask(_targetBaseRef, true, -1));
        }

        var sapperBlastRadius :Number = _unit.unitData.weapon.aoeRadius;

        var scanSequence :AITaskSequence = new AITaskSequence(true);
        scanSequence.addSequencedTask(new DetectCreatureGroupAction(
            SCAN_FOR_ENEMIES_TASK_NAME,
            SCAN_FOR_ENEMY_GROUP_SIZE,
            DetectCreatureGroupAction.isDetectableEnemyCreaturePred,
            DetectCreatureGroupAction.createIsGroupedEnemyPred(sapperBlastRadius - 15))); // this number is sort of fudged
        scanSequence.addSequencedTask(new AITimerTask(SCAN_FOR_ENEMIES_DELAY));

        this.addSubtask(scanSequence);
    }

    override protected function receiveSubtaskMessage (subtask :AITask, messageName :String, data :Object) :void
    {
        if (messageName == AITaskSequence.MSG_SEQUENCEDTASKMESSAGE) {
            // we detected an enemy group - unbundle the message from the sequenced task
            var msg :SequencedTaskMessage = data as SequencedTaskMessage;
            var group :Array = msg.data as Array;
            log.info("detected enemy group - bombing!");

            // try to attack the first enemy
            var enemy :CreatureUnit = group[0];
            this.clearSubtasks();
            this.addSubtask(new AttackUnitTask(enemy.ref, true, -1));
        } else if (messageName == AITaskTree.MSG_SUBTASKCOMPLETED && subtask.name == AttackUnitTask.NAME) {
            // the unit we were going after died before we got to them
            this.attackBaseAndScanForEnemyGroups();
        }
    }

    override public function get name () :String
    {
        return "SapperAI";
    }

    protected var _unit :SapperCreatureUnit;
    protected var _targetBaseRef :SimObjectRef;

    protected static const SCAN_FOR_ENEMIES_DELAY :Number = 1;
    protected static const SCAN_FOR_ENEMY_GROUP_SIZE :int = 2;
    protected static const SCAN_FOR_ENEMIES_TASK_NAME :String = "ScanForEnemies";

    protected static const log :Log = Log.getLog(SapperAI);
}
