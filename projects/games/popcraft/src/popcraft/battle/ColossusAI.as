package popcraft.battle {

import com.threerings.util.Log;
import com.whirled.contrib.simplegame.SimObjectRef;

import popcraft.battle.ai.*;

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
        this.restartAI();
    }

    protected function restartAI () :void
    {
        this.beginAttackEnemyBase();

        // scan for units in our immediate vicinity
        var scanSequence :AITaskSequence = new AITaskSequence(true);
        scanSequence.addSequencedTask(new DelayUntilTask("DelayUntilNotAttacking", DelayUntilTask.notAttackingPredicate));
        scanSequence.addSequencedTask(new DetectColossusTargetAction());
        this.addSubtask(scanSequence);
    }

    protected function beginAttackEnemyBase () :void
    {
        _targetBaseRef = _unit.getEnemyBaseToAttack();
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
        if (messageName == AITaskTree.MSG_SUBTASKCOMPLETED && task.name == TARGET_BASE_DIED) {
            // find a new base to attack
            this.beginAttackEnemyBase();
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
    protected var _targetBaseRef :SimObjectRef = SimObjectRef.Null();

    protected static const TARGET_BASE_DIED :String = "TargetBaseDied";

    protected static const log :Log = Log.getLog(ColossusAI);
}

}

import com.whirled.contrib.simplegame.SimObjectRef;

import popcraft.*;
import popcraft.battle.*;
import popcraft.battle.ai.*;

class DetectColossusTargetAction extends DetectCreatureAction
{
    public static const NAME :String = "DetectColossusTargetAction";
    public static const DETECTED_TARGET_MSG :String = "DetectedColossusTarget";

    public function DetectColossusTargetAction ()
    {
        super(DetectCreatureAction.createNotEnemyOfTypesPredicate([Constants.UNIT_TYPE_COLOSSUS, Constants.UNIT_TYPE_BOSS]));
    }

    override protected function handleDetectedCreature (thisCreature :CreatureUnit, detectedCreature :CreatureUnit) :void
    {
        var detectedUnit :Unit = detectedCreature;
        if (null == detectedUnit) {
            // are we in range of an enemy base?
            var baseRefs :Array = GameContext.netObjects.getObjectRefsInGroup(PlayerBaseUnit.GROUP_NAME);
            for each (var baseRef :SimObjectRef in baseRefs) {
                var base :PlayerBaseUnit = baseRef.object as PlayerBaseUnit;
                if (null != base && DetectCreatureAction.isAttackableEnemyPredicate(thisCreature, base)) {
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
