package popcraft.battle.view {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.SimObjectRef;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;

import popcraft.*;
import popcraft.battle.*;

public class MissileView extends BattlefieldSprite
{
    public function MissileView (startLoc :Vector2, targetUnit :Unit, travelTime :Number)
    {
        _startLoc = startLoc.clone();
        _targetUnitRef = targetUnit.ref;
        _travelTime = travelTime;

        // is the missile moving further in the vertical or in the horizontal?
        var travelVec :Vector2 = targetUnit.unitLoc.subtractLocal(_startLoc);
        var missileName :String =
            (Math.abs(travelVec.x) >= Math.abs(travelVec.y) ? "handy_attack_X" : "handy_attack_Y");

        _movie = SwfResource.instantiateMovieClip("missile", missileName);
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    override protected function update (dt :Number) :void
    {
        var targetUnit :Unit = (_targetUnitRef.object as Unit);

        if (null == targetUnit) {
            // our target's gone. die.
            this.destroySelf();
            return;
        }

        _elapsedTime = Math.min(_elapsedTime + dt, _travelTime);

        var elapsedPercentage :Number = _elapsedTime / _travelTime;

        // calculate the missile's current location
        var loc :Vector2 = targetUnit.unitLoc.subtractLocal(_startLoc).scaleLocal(elapsedPercentage).addLocal(_startLoc);

        // add an arc to the missile
        // (scale elapsedPercentage to be between -ARC_HEIGHT_SQRT and ARC_HEIGHT_SQRT)
        // (find ARC_HEIGHT - arc^2)
        var arc :Number = ((elapsedPercentage * 2) - 1) * ARC_HEIGHT_SQRT;
        arc = ARC_HEIGHT - (arc * arc);

        this.updateLoc(loc.x, loc.y - arc);

        if (_elapsedTime == _travelTime) {
            this.destroySelf();
        }

    }

    protected var _startLoc :Vector2;
    protected var _targetUnitRef :SimObjectRef;

    protected var _totalDistance :Number;

    protected var _elapsedTime :Number = 0;
    protected var _travelTime :Number;

    protected var _movie :MovieClip;

    protected static const ARC_HEIGHT :Number = 50;
    protected static const ARC_HEIGHT_SQRT :Number = Math.sqrt(ARC_HEIGHT);

}

}
