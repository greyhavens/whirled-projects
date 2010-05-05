//
// $Id$

package popcraft.game.battle {

import com.threerings.util.Log;
import com.threerings.flashbang.GameObjectRef;

import popcraft.game.battle.ai.*;

/**
 * Goals:
 * (Priority 1) Attack groups of approaching enemies.
 * (Priority 2) Attack enemy base
 */
public class ColossusAI extends AITaskTree
{
    public function ColossusAI (unit :ColossusCreatureUnit)
    {
        _unit = unit;
    }

    public function init () :void
    {
        restartAI();
    }

    protected function restartAI () :void
    {
        beginAttackEnemyBase();
        addSubtask(createScanForUnitTask());
    }

    protected function createScanForUnitTask () :AITask
    {
        // scan for units in our immediate vicinity
        var scanSequence :AITaskSequence = new AITaskSequence(true);
        scanSequence.addSequencedTask(new AIDelayUntilTask("DelayUntilNotAttacking", AIDelayUntilTask.notAttackingPredicate));
        scanSequence.addSequencedTask(new DetectColossusTargetAction());

        return scanSequence;
    }

    protected function beginAttackEnemyBase () :void
    {
        _targetBaseRef = _unit.getEnemyBaseToAttack();
        if (_targetBaseRef.isNull) {
            return;
        }

        addSubtask(new MoveToAttackLocationTask(_targetBaseRef, true, -1));
        addSubtask(new AIDelayUntilTask(TARGET_BASE_DIED,
            AIDelayUntilTask.createUnitDiedPredicate(_targetBaseRef)));
    }

    override public function get name () :String
    {
        return "ColossusAI";
    }

    override protected function receiveSubtaskMessage (task :AITask, messageName :String, data :Object) :void
    {
        if (messageName == AITaskTree.MSG_SUBTASKCOMPLETED && task.name == TARGET_BASE_DIED) {
            // find a new base to attack
            beginAttackEnemyBase();
        } else if (messageName == AITaskSequence.MSG_SEQUENCEDTASKMESSAGE) {
            var msg :SequencedTaskMessage = data as SequencedTaskMessage;
            if (msg.messageName == DetectColossusTargetAction.DETECTED_TARGET_MSG) {
                // we detected an enemy - attack it
                var enemyUnit :Unit = msg.data as Unit;
                _unit.sendAttack(enemyUnit, _unit.unitData.weapon);
            }
        }
    }

    protected var _unit :ColossusCreatureUnit;
    protected var _targetBaseRef :GameObjectRef = GameObjectRef.Null();

    protected static const TARGET_BASE_DIED :String = "TargetBaseDied";

    protected static const log :Log = Log.getLog(ColossusAI);
}

}

import com.threerings.flashbang.GameObjectRef;

import popcraft.*;
import popcraft.game.*;
import popcraft.game.battle.*;
import popcraft.game.battle.ai.*;

class DetectColossusTargetAction extends DetectCreatureAction
{
    public static const NAME :String = "DetectColossusTargetAction";
    public static const DETECTED_TARGET_MSG :String = "DetectedColossusTarget";

    public function DetectColossusTargetAction ()
    {
        super(AIPredicates.createNotEnemyOfTypesPredicate([Constants.UNIT_TYPE_COLOSSUS, Constants.UNIT_TYPE_BOSS]));
    }

    override protected function handleDetectedCreature (thisCreature :CreatureUnit, detectedCreature :CreatureUnit) :void
    {
        var detectedUnit :Unit = detectedCreature;
        if (null == detectedUnit) {
            // are we in range of an enemy base?
            var baseRefs :Array = GameCtx.netObjects.getObjectRefsInGroup(WorkshopUnit.GROUP_NAME);
            for each (var baseRef :GameObjectRef in baseRefs) {
                var base :WorkshopUnit = baseRef.object as WorkshopUnit;
                if (null != base && AIPredicates.isAttackableEnemyPredicate(thisCreature, base)) {
                    detectedUnit = base;
                    break;
                }
            }
        }

        if (null != detectedUnit) {
            sendParentMessage(DETECTED_TARGET_MSG, detectedUnit);
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
