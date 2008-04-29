package popcraft.battle {

import com.whirled.contrib.simplegame.*;

import popcraft.*;
import popcraft.battle.ai.*;

/**
 * Grunts are the meat-and-potatoes offensive unit of the game.
 * - Don't chase enemies unless attacked.
 * - non-ranged.
 * - moderate damage to enemy base.
 */
public class GruntCreatureUnit extends CreatureUnit
{
    public function GruntCreatureUnit (owningPlayerId :uint)
    {
        super(Constants.UNIT_TYPE_GRUNT, owningPlayerId);

        _gruntAI = new GruntAI(this);
    }

    override protected function get aiRoot () :AITask
    {
        return _gruntAI;
    }

    protected var _gruntAI :GruntAI;
}

}

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.util.*;
import flash.geom.Point;

import popcraft.*;
import popcraft.battle.*;
import popcraft.battle.ai.*;
import flash.display.Loader;
import com.threerings.util.Log;

/**
 * Goals:
 * (Priority 1) Attack enemy base
 * (Priority 2) Attack enemy aggressors (responds to attacks, but doesn't initiate fights with other units)
 */
class GruntAI extends AITaskTree
{
    public function GruntAI (unit :GruntCreatureUnit)
    {
        _unit = unit;
        this.beginAttackBase();
    }

    protected function beginAttackBase () :void
    {
        this.clearSubtasks();

        if (_targetBaseRef.isNull) {
            _targetBaseRef = _unit.findEnemyBaseToAttack();
        }

        if (!_targetBaseRef.isNull) {
            this.addSubtask(new AttackUnitTask(_targetBaseRef, true, -1));
        }

        // scan for non-sappers once/second
        var detectPredicate :Function = DetectCreatureAction.createNotEnemyOfTypesPredicate([Constants.UNIT_TYPE_SAPPER]);
        var scanSequence :AITaskSequence = new AITaskSequence(true);
        scanSequence.addSequencedTask(new DetectCreatureAction(detectPredicate));
        scanSequence.addSequencedTask(new AITimerTask(1));
        this.addSubtask(scanSequence);
    }

    override protected function receiveSubtaskMessage (task :AITask, messageName :String, data :Object) :void
    {
        if (messageName == MSG_SUBTASKCOMPLETED) {
            switch (task.name) {

            case AttackUnitTask.NAME:
                // resume attacking base
                //log.info("resuming attack on base");
                this.beginAttackBase();
                break;
            }

        } else if (messageName == AITaskSequence.MSG_SEQUENCEDTASKMESSAGE) {
            var msg :SequencedTaskMessage = data as SequencedTaskMessage;
            var enemyUnit :CreatureUnit = msg.data as CreatureUnit;

            // we detected an enemy - attack it
            //log.info("detected enemy - attacking");
            this.clearSubtasks();
            this.addSubtask(new AttackUnitTask(enemyUnit.ref, true, _unit.unitData.loseInterestRadius));

        }
    }

    override public function get name () :String
    {
        return "GruntAI";
    }

    protected var _unit :GruntCreatureUnit;
    protected var _state :uint;
    protected var _targetBaseRef :SimObjectRef = SimObjectRef.Null();

    protected static const log :Log = Log.getLog(GruntAI);
}
