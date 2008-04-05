package popcraft.battle.ai {

import com.threerings.flash.Vector2;

import popcraft.battle.CreatureUnit;

/**
 * Attempts to move the creature to a particular location on the battlefield.
 */
public class MoveToLocationTask implements AITask
{
    public function MoveToLocationTask (name :String, loc :Vector2, fudgeFactor :Number = 0, failAfter :Number = -1)
    {
        _name = name;
        _loc = loc;
        _fudgeFactor = Math.max(fudgeFactor, MIN_FUDGE_FACTOR);
        _failAfter = failAfter;
    }

    public function get name () :String
    {
        return _name;
    }

    public function update (dt :Number, creature :CreatureUnit) :uint
    {
        if (0 == _elapsedTime) {
            // calculate how long it *should* take us to get to the destination
            _expectedTime = creature.calcShortestTravelTimeTo(_loc);
        }

        if (creature.isAtLocation(_loc) || _elapsedTime >= _expectedTime && creature.isNearLocation(_loc, _fudgeFactor)) {
            // we made it to the location
            _success = true;
            return AITaskStatus.COMPLETE;
        } else if (_failAfter >= 0 && _elapsedTime >= _expectedTime + _failAfter) {
            // it took us too long to get to the location
            _success = false;
            return AITaskStatus.COMPLETE;
        } else {
            _elapsedTime += dt;

            // keep moving

            // CreatureUnit requires that we reset the movement destination every frame
            creature.setMovementDestination(_loc);

            return AITaskStatus.ACTIVE;
        }
    }

    public function get success () :Boolean
    {
        return _success;
    }

    protected var _name :String;
    protected var _loc :Vector2;
    protected var _failAfter :Number;
    protected var _fudgeFactor :Number;

    protected var _expectedTime :Number;

    protected var _elapsedTime :Number = 0;
    protected var _success :Boolean;

    protected static const MIN_FUDGE_FACTOR :Number = 0.4;

}

}
