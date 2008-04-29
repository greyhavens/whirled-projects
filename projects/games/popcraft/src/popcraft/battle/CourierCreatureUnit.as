package popcraft.battle {

import com.whirled.contrib.simplegame.*;

import popcraft.*;
import popcraft.battle.ai.*;

/**
 * Couriers retrieve spell pickups from the battlefield and bring them back to their
 * owning player's base.
 *
 * Couriers move faster when there are more of them on the playfield.
 */
public class CourierCreatureUnit extends CreatureUnit
{
    public function CourierCreatureUnit (owningPlayerId :uint)
    {
        super(Constants.UNIT_TYPE_COURIER, owningPlayerId);

        _courierAI = new CourierAI(this);
        _groupName = "CourierCreature_Player" + owningPlayerId;
    }

    override protected function addedToDB () :void
    {
        this.updateSpeedup();
    }

    override protected function get aiRoot () :AITask
    {
        return _courierAI;
    }

    override public function getObjectGroup (groupNum :int) :String
    {
        switch (groupNum) {
        case 0: return _groupName;
        default: return super.getObjectGroup(groupNum - 1);
        }
    }

    override protected function update (dt :Number) :void
    {
        this.updateSpeedup();
        super.update(dt);
    }

    protected function updateSpeedup () :void
    {
        // the Courier moves more quickly when there are other friendly
        // Couriers on the battlefield
        var numCouriers :int = GameContext.netObjects.getObjectRefsInGroup(_groupName).length;
        _speedup = (numCouriers - 1) * SPEEDUP_PER_COURIER;
        _speedup = Math.max(_speedup, 0);
        _speedup = Math.min(_speedup, MAX_SPEEDUP);
    }

    override public function get speedScale () :Number
    {
        return super.speedScale * _speedup;
    }

    public function get speedup () :Number
    {
        return _speedup;
    }

    protected var _courierAI :CourierAI;
    protected var _groupName :String;
    protected var _speedup :Number = 1.0;

    // @TODO - load these from XML
    protected static const SPEEDUP_PER_COURIER :Number = 0.15;
    protected static const MAX_SPEEDUP :Number = 2;
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
import com.threerings.flash.Vector2;

class CourierAI extends AITaskTree
{
    public static const NAME :String = "CourierAI";

    public function CourierAI (unit :CourierCreatureUnit)
    {
        _unit = unit;
        this.addSubtask(new ScanForSpellPickupsTask());
    }

    protected function attemptSpellPickup (spell :SpellPickupObject) :void
    {
        log.info("detected spell - attempting pickup");

        this.clearSubtasks();
    }

    override protected function receiveSubtaskMessage (task :AITask, messageName :String, data :Object) :void
    {
        if (messageName == ScanForSpellPickupsTask.MSG_DETECTEDSPELL) {
            var spell :SpellPickupObject = data as SpellPickupObject;
            this.attemptSpellPickup(spell);
        }
    }

    override public function get name () :String
    {
        return NAME;
    }

    protected var _unit :CourierCreatureUnit;

    protected static const log :Log = Log.getLog(CourierAI);
}

// The Courier skitters around, like an insect
class CourierMoveTask extends AITaskTree
{
    public static const NAME :String = "CourierMoveTask";

    public function CourierMoveTask (unit :CourierCreatureUnit, loc :Vector2)
    {
        _unit = unit;
        _loc = loc;

        this.moveToNextLoc();
    }

    protected function moveToNextLoc () :void
    {
        var curLoc :Vector2 = _unit.unitLoc;

        var d :Vector2 = _loc.subtract(curLoc);

        var nextLoc :Vector2;
        if (d.lengthSquared < MAX_MOVE_LENGTH_SQUARED) {
            nextLoc = _loc;
        } else {
            d.length = MAX_MOVE_LENGTH;
            d.addLocal(curLoc);
            nextLoc = d;
        }

        this.addSubtask(new MoveToLocationTask(MOVE_SUBTASK_NAME, nextLoc, MOVE_FUDGE_FACTOR));
    }

    override protected function receiveSubtaskMessage (subtask :AITask, messageName :String, data :Object) :void
    {
        if (messageName == AITaskTree.MSG_SUBTASKCOMPLETED) {
            if (subtask.name == MOVE_SUBTASK_NAME) {
                // are we at our destination?
                if (_unit.unitLoc.similar(_loc, MOVE_FUDGE_FACTOR)) {
                    _complete = true;
                } else {
                    // pause for a moment
                    this.addSubtask(new AITimerTask(PAUSE_TIME, PAUSE_SUBTASK_NAME));
                }
            } else if (subtask.name == PAUSE_SUBTASK_NAME) {
                // start moving again
                this.moveToNextLoc();
            }
        }
    }

    override public function update (dt :Number, creature :CreatureUnit) :uint
    {
        if (_complete) {
            return AITaskStatus.COMPLETE;
        } else {
            super.update(dt, creature);
            return AITaskStatus.ACTIVE;
        }
    }

    override public function get name () :String
    {
        return NAME;
    }

    protected var _unit :CourierCreatureUnit;
    protected var _loc :Vector2;
    protected var _complete :Boolean;

    protected static const MAX_MOVE_LENGTH :Number = 70;
    protected static const MOVE_FUDGE_FACTOR :Number = 5;
    protected static const MAX_MOVE_LENGTH_SQUARED :Number = MAX_MOVE_LENGTH * MAX_MOVE_LENGTH;
    protected static const MOVE_SUBTASK_NAME :String = "MoveSubtask";
    protected static const PAUSE_SUBTASK_NAME :String = "PauseSubtask";

    protected static const PAUSE_TIME :Number = 0.5;
}

class ScanForSpellPickupsTask extends AITaskTree
{
    public static const NAME :String = "ScanForSpellPickupsTask";
    public static const MSG_DETECTEDSPELL :String = "DetectedSpell";

    public function ScanForSpellPickupsTask ()
    {
        // scan for spell pickups once/second
        var scanSequence :AITaskSequence = new AITaskSequence(true);
        scanSequence.addSequencedTask(new DetectSpellPickupAction());
        scanSequence.addSequencedTask(new AITimerTask(1));
        this.addSubtask(scanSequence);

        // wander
    }

    override protected function receiveSubtaskMessage (task :AITask, messageName :String, data :Object) :void
    {
        if (messageName == AITaskSequence.MSG_SEQUENCEDTASKMESSAGE) {
            var msg :SequencedTaskMessage = data as SequencedTaskMessage;
            var spell :SpellPickupObject = msg.data as SpellPickupObject;
            this.sendParentMessage(MSG_DETECTEDSPELL, spell);
        }
    }

    override public function get name () :String
    {
        return NAME;
    }
}
