package popcraft.battle.ai {

import com.threerings.flash.Vector2;

import popcraft.battle.CreatureUnit;

/**
 * Attempts to move the creature to a particular location on the battlefield.
 */
public class MoveToLocationTask extends AITask
{
    public function MoveToLocationTask (name :String, loc :Vector2, fudgeFactor :Number = 0, failAfter :Number = -1)
    {
        _name = name;
        _dest = loc;
        _fudgeFactor = Math.max(fudgeFactor, MIN_FUDGE_FACTOR);
        _failAfter = failAfter;
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
            _success = true;
            return AITaskStatus.COMPLETE;
        }

        if (_failAfter > 0 && _elapsedTime > 0) {
            // determine if we might be stuck
            _expectedDistanceSoFar += (_lastDt * creature.movementSpeed);
            if (creature.unitLoc.subtractLocal(_start).length + STUCK_DISTANCE < _expectedDistanceSoFar) {
                _stuckTime += _lastDt;
                if (_stuckTime >= _failAfter) {
                    _success = false;
                    return AITaskStatus.COMPLETE;
                }
            } else {
                _stuckTime = 0;
            }
        }

        _elapsedTime += dt;
        _lastDt = dt;

        // keep moving (CreatureUnit requires that we reset the movement destination every frame)
        creature.setMovementDestination(_dest);

        return AITaskStatus.ACTIVE;
    }

    public function get success () :Boolean
    {
        return _success;
    }

    protected var _name :String;
    protected var _start :Vector2;
    protected var _dest :Vector2;
    protected var _failAfter :Number = 0;
    protected var _fudgeFactor :Number = 0;

    protected var _expectedTime :Number = 0;
    protected var _expectedDistanceSoFar :Number = 0;
    protected var _stuckTime :Number = 0;
    protected var _lastDt :Number = 0;

    protected var _elapsedTime :Number = 0;
    protected var _success :Boolean;

    protected static const MIN_FUDGE_FACTOR :Number = 0.4;
    protected static const STUCK_DISTANCE :Number = 10;

}

}
