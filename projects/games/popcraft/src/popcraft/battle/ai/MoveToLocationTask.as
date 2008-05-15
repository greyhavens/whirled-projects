package popcraft.battle.ai {

import com.threerings.flash.Vector2;
import com.threerings.util.Name;

import popcraft.battle.CreatureUnit;

/**
 * Attempts to move the creature to a particular location on the battlefield.
 */
public class MoveToLocationTask extends AITask
{
    public function MoveToLocationTask (
        name :String,
        loc :Vector2,
        fudgeFactor :Number = 0,
        disableCollisionsAfter :Number = -1,
        disableCollisionsTime :Number = 0.5)
    {
        _name = name;
        _dest = loc;
        _fudgeFactor = Math.max(fudgeFactor, MIN_FUDGE_FACTOR);
        _disableCollisionsAfter = disableCollisionsAfter;
        _disableCollisionsTime = disableCollisionsTime;
    }

    override public function get name () :String
    {
        return _name;
    }

    override public function update (dt :Number, creature :CreatureUnit) :uint
    {
        // init
        if (0 == _elapsedTime) {
            _expectedTime = creature.calcShortestTravelTimeTo(_dest);
            _start = creature.unitLoc;
        }

        if (creature.isAtLocation(_dest) || _elapsedTime >= _expectedTime && creature.isNearLocation(_dest, _fudgeFactor)) {
            // we made it to the location
            return AITaskStatus.COMPLETE;
        }

        if (_disableCollisionsAfter > 0  && _elapsedTime > 0) {
            // determine if we might be stuck
            _expectedDistanceSoFar += (_lastDt * creature.movementSpeed);
            if (creature.unitLoc.subtractLocal(_start).length + STUCK_DISTANCE < _expectedDistanceSoFar) {
                _stuckTime += _lastDt;

                if (_stuckTime >= _disableCollisionsAfter) {
                    // disable collisions temporarily
                    creature.disableCollisionAvoidance(_disableCollisionsTime);
                    // re-calculate our expected time
                    _expectedTime = creature.calcShortestTravelTimeTo(_dest);
                    _start = creature.unitLoc;
                }
            }
        }

        _elapsedTime += dt;
        _lastDt = dt;

        // keep moving (CreatureUnit requires that we reset the movement destination every frame)
        creature.setMovementDestination(_dest);

        return AITaskStatus.ACTIVE;
    }

    protected var _name :String;
    protected var _start :Vector2;
    protected var _dest :Vector2;
    protected var _disableCollisionsAfter :Number;
    protected var _disableCollisionsTime :Number;
    protected var _fudgeFactor :Number;

    protected var _expectedTime :Number = 0;
    protected var _expectedDistanceSoFar :Number = 0;
    protected var _stuckTime :Number = 0;
    protected var _lastDt :Number = 0;

    protected var _elapsedTime :Number = 0;

    protected static const MIN_FUDGE_FACTOR :Number = 0.4;
    protected static const STUCK_DISTANCE :Number = 10;

}

}
