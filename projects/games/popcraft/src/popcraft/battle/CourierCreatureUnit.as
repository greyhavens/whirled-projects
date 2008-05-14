package popcraft.battle {

import com.threerings.flash.Vector2;
import com.threerings.util.Assert;
import com.whirled.contrib.simplegame.*;

import popcraft.*;
import popcraft.battle.ai.*;
import popcraft.data.SpellData;

/**
 * Couriers retrieve spell pickups from the battlefield and bring them back to their
 * owning player's base.
 *
 * Couriers move faster when there are more of them on the playfield.
 */
public class CourierCreatureUnit extends CreatureUnit
{
    public static function getNumPlayerCouriersOnBoard (playerId :uint) :int
    {
        return GameContext.netObjects.getObjectRefsInGroup(getGroupName(playerId)).length;
    }

    public function CourierCreatureUnit (owningPlayerId :uint)
    {
        super(Constants.UNIT_TYPE_COURIER, owningPlayerId);

        _spawnLoc = _owningPlayerInfo.base.unitSpawnLoc;

        _courierAI = new CourierAI(this);
        _groupName = getGroupName(owningPlayerId);
    }

    public function pickupSpell (spellObject :SpellDropObject) :void
    {
        Assert.isNull(_carriedSpell);
        _carriedSpell = spellObject.spellData;
        spellObject.destroySelf();
    }

    public function deliverSpellToBase () :void
    {
        Assert.isNotNull(_carriedSpell);

        this.owningPlayerInfo.addSpell(_carriedSpell.type);
        _carriedSpell = null;

        // the courier is destroyed when he delivers the spell
        this.die();
    }

    public function get carriedSpell () :SpellData
    {
        return _carriedSpell;
    }

    override protected function addedToDB () :void
    {
        super.addedToDB();
        this.updateSpeedup();
    }

    override protected function die () :void
    {
        // drop the currently carried spell on the ground when we die.
        // don't play the "new spell" sound when this happens.
        if (null != _carriedSpell && GameContext.diurnalCycle.isNight) {
            SpellDropFactory.createSpellDrop(_carriedSpell.type, this.unitLoc, false);
        }

        super.die();
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
        // the Courier pauses for less time when there are other friendly
        // Couriers on the battlefield
        var numCouriers :int = GameContext.netObjects.getObjectRefsInGroup(_groupName).length;
        _speedup = numCouriers * CourierSettings.SPEEDUP_PER_COURIER;
        _speedup = Math.max(_speedup, 0);
        _speedup = Math.min(_speedup, CourierSettings.MAX_SPEEDUP);
    }

    public function get speedup () :Number
    {
        return _speedup;
    }

    public function get spawnLoc () :Vector2
    {
        return _spawnLoc; // Courier AI uses this to determine where to move to
    }

    protected static function getGroupName (playerId :uint) :String
    {
        return "CourierCreature_Player" + playerId;
    }

    protected var _courierAI :CourierAI;
    protected var _spawnLoc :Vector2;
    protected var _groupName :String;
    protected var _speedup :Number = 1;

    protected var _carriedSpell :SpellData;
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
import com.threerings.util.Name;
import flash.geom.Rectangle;

class CourierSettings
{
    // @TODO - load these from XML
    public static const BASE_PAUSE_TIME :Number = 1.5;
    public static const SPEEDUP_PER_COURIER :Number = 1.5;
    public static const MAX_SPEEDUP :Number = 8;
    public static const MAX_MOVE_LENGTH :Number = 50;
    public static const MOVE_FUDGE_FACTOR :Number = 5;
    public static const MAX_MOVE_LENGTH_SQUARED :Number = MAX_MOVE_LENGTH * MAX_MOVE_LENGTH;
    public static const WANDER_BOUNDS :Rectangle = new Rectangle(
        75, 75, Constants.BATTLE_WIDTH - 75, Constants.BATTLE_HEIGHT - 75);
    public static const ENEMY_BASE_WANDER_RADIUS :NumRange = new NumRange(150, 300, Rand.STREAM_GAME);
    public static const ENEMY_BASE_WANDER_ANGLE :NumRange = new NumRange(-Math.PI / 3, Math.PI / 3, Rand.STREAM_GAME);
}

class CourierAI extends AITaskTree
{
    public static const NAME :String = "CourierAI";

    public function CourierAI (unit :CourierCreatureUnit)
    {
        _unit = unit;
        this.addSubtask(new ScanForSpellPickupsTask(_unit));
    }

    override protected function receiveSubtaskMessage (task :AITask, messageName :String, data :Object) :void
    {
        if (messageName == ScanForSpellPickupsTask.MSG_DETECTEDSPELL) {
            var spell :SpellDropObject = data as SpellDropObject;
            log.info("detected spell - attempting pickup");
            this.clearSubtasks();
            this.addSubtask(new PickupSpellTask(_unit, spell));
        } else if (messageName == PickupSpellTask.MSG_SPELL_GONE) {
            // we were trying to get to a spell, but somebody else got to it first.
            // resume wandering
            this.clearSubtasks();
            this.addSubtask(new ScanForSpellPickupsTask(_unit));
        } else if (messageName == PickupSpellTask.MSG_SPELL_RETRIEVED) {
            // we picked up a spell!
            log.info("retrieved spell");
            _unit.pickupSpell(data as SpellDropObject);
            // let's try to go home and deliver it
            var base :PlayerBaseUnit = _unit.owningPlayerInfo.base;
            if (null != base) {
                this.addSubtask(new CourierMoveTask(_unit, base.unitLoc));
            }
        } else if (messageName == AITaskTree.MSG_SUBTASKCOMPLETED && task.name == CourierMoveTask.NAME) {
            // we've arrived at the base. deliver the goods
            _unit.deliverSpellToBase();
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
        if (d.lengthSquared < CourierSettings.MAX_MOVE_LENGTH_SQUARED) {
            nextLoc = _loc;
        } else {
            d.length = CourierSettings.MAX_MOVE_LENGTH;
            d.addLocal(curLoc);
            nextLoc = d;
        }

        this.addSubtask(new MoveToLocationTask(MOVE_SUBTASK_NAME, nextLoc, CourierSettings.MOVE_FUDGE_FACTOR));
    }

    override protected function receiveSubtaskMessage (subtask :AITask, messageName :String, data :Object) :void
    {
        if (messageName == AITaskTree.MSG_SUBTASKCOMPLETED) {
            if (subtask.name == MOVE_SUBTASK_NAME) {
                // are we at our destination?
                if (_unit.unitLoc.similar(_loc, CourierSettings.MOVE_FUDGE_FACTOR)) {
                    _complete = true;
                } else {
                    // pause for a moment
                    var pauseTime :Number = CourierSettings.BASE_PAUSE_TIME / _unit.speedup;
                    this.addSubtask(new AITimerTask(pauseTime, PAUSE_SUBTASK_NAME));
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

    protected static const MOVE_SUBTASK_NAME :String = "MoveSubtask";
    protected static const PAUSE_SUBTASK_NAME :String = "PauseSubtask";
}

class PickupSpellTask extends AITaskTree
{
    public static const NAME :String = "PickupSpellTask";
    public static const MSG_SPELL_RETRIEVED :String = "SpellRetrieved";
    public static const MSG_SPELL_GONE :String = "SpellGone";

    public function PickupSpellTask (unit :CourierCreatureUnit, spell :SpellDropObject)
    {
        _unit = unit;
        _spellRef = spell.ref;

        this.addSubtask(new CourierMoveTask(_unit, new Vector2(spell.x, spell.y)));
    }

    override protected function receiveSubtaskMessage (subtask :AITask, messageName :String, data :Object) :void
    {
        if (messageName == AITaskTree.MSG_SUBTASKCOMPLETED && subtask.name == CourierMoveTask.NAME) {
            if (!_spellRef.isNull) {
                var spell :SpellDropObject = _spellRef.object as SpellDropObject;
                this.sendParentMessage(MSG_SPELL_RETRIEVED, spell);
                _retrieved = true;
            }
        }
    }

    override public function update (dt :Number, creature :CreatureUnit) :uint
    {
        // does the spell object still exist?
        if (_spellRef.isNull) {
            if (!_retrieved) {
                this.sendParentMessage(MSG_SPELL_GONE);
            }
            return AITaskStatus.COMPLETE;
        } else {
            super.update(dt, creature);
            return AITaskStatus.ACTIVE;
        }
    }

    protected var _retrieved :Boolean;
    protected var _unit :CourierCreatureUnit;
    protected var _spellRef :SimObjectRef;
}

class ScanForSpellPickupsTask extends AITaskTree
{
    public static const NAME :String = "ScanForSpellPickupsTask";
    public static const MSG_DETECTEDSPELL :String = "DetectedSpell";

    public function ScanForSpellPickupsTask (unit :CourierCreatureUnit)
    {
        _unit = unit;

        // scan for spell pickups twice/second
        var scanSequence :AITaskSequence = new AITaskSequence(true);
        scanSequence.addSequencedTask(new DetectSpellDropAction());
        scanSequence.addSequencedTask(new AITimerTask(0.5));
        this.addSubtask(scanSequence);

        this.wander();
    }

    protected function wander () :void
    {
        // When Couriers aren't picking up spells, they wander around
        // outside an opponent's base.
        if (_wanderBaseRef.isNull) {
            _wanderBaseRef = _unit.getEnemyBaseRef();
            if (_wanderBaseRef.isNull) {
                return;
            }
        }

        var wanderBase :PlayerBaseUnit = _wanderBaseRef.object as PlayerBaseUnit;

        // pick a location to wander to outside the enemy player's base
        var wanderLoc :Vector2 = _unit.spawnLoc.subtract(wanderBase.unitLoc);
        wanderLoc.length = CourierSettings.ENEMY_BASE_WANDER_RADIUS.next();
        wanderLoc.rotateLocal(CourierSettings.ENEMY_BASE_WANDER_ANGLE.next());
        wanderLoc.addLocal(wanderBase.unitLoc);

        // clamp
        wanderLoc.x = Math.max(wanderLoc.x, CourierSettings.WANDER_BOUNDS.left);
        wanderLoc.x = Math.min(wanderLoc.x, CourierSettings.WANDER_BOUNDS.right);
        wanderLoc.y = Math.max(wanderLoc.y, CourierSettings.WANDER_BOUNDS.top);
        wanderLoc.y = Math.min(wanderLoc.y, CourierSettings.WANDER_BOUNDS.bottom);

        // commence wandering!
        this.addSubtask(new CourierMoveTask(_unit, wanderLoc));
    }

    override protected function receiveSubtaskMessage (task :AITask, messageName :String, data :Object) :void
    {
        if (messageName == AITaskSequence.MSG_SEQUENCEDTASKMESSAGE) {
            var msg :SequencedTaskMessage = data as SequencedTaskMessage;
            var spell :SpellDropObject = msg.data as SpellDropObject;
            this.sendParentMessage(MSG_DETECTEDSPELL, spell);
        } else if (messageName == AITaskTree.MSG_SUBTASKCOMPLETED && task.name == CourierMoveTask.NAME) {
            // wander again
            this.wander();
        }
    }

    override public function get name () :String
    {
        return NAME;
    }

    protected var _unit :CourierCreatureUnit;
    protected var _wanderBaseRef :SimObjectRef = SimObjectRef.Null();
}
