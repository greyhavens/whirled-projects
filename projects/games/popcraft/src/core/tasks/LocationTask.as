package core.tasks {

import com.threerings.util.Assert;

import core.AppObject;
import core.ObjectTask;
import core.util.Interpolator;
import core.util.MXInterpolatorAdapter;

import flash.geom.Point;

import mx.effects.easing.*;
import flash.display.DisplayObject;

public class LocationTask extends ObjectTask
{
    public static function CreateLinear (loc :Point, time :Number) :LocationTask
    {
        return new LocationTask(
            loc,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Linear.easeNone));
    }

    public static function CreateSmooth (loc :Point, time :Number) :LocationTask
    {
        return new LocationTask(
            loc,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeInOut));
    }

    public static function CreateEaseIn (loc :Point, time :Number) :LocationTask
    {
        return new LocationTask(
            loc,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeIn));
    }

    public static function CreateEaseOut (loc :Point, time :Number) :LocationTask
    {
        return new LocationTask(
            loc,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeOut));
    }

    public function LocationTask (
        loc :Point,
        time :Number = 0,
        interpolator :Interpolator = null)
    {
        // default to linear interpolation
        if (null == interpolator) {
            interpolator = new MXInterpolatorAdapter(mx.effects.easing.Linear.easeNone);
        }

        Assert.isTrue(null != loc);
        Assert.isTrue(time >= 0);

        _to = loc;
        _totalTime = time;
        _interpolator = interpolator;
    }

    override public function update (dt :Number, obj :AppObject) :uint
    {
        var displayObj :DisplayObject = obj.displayObject;
        Assert.isNotNull(displayObj, "LocationTask can only be applied to AppObjects with attached display objects.");

        if (0 == _elapsedTime) {
            _from.x = displayObj.x;
            _from.y = displayObj.y;
        }

        _elapsedTime += dt;

        displayObj.x = _interpolator.interpolate(_from.x, _to.x, _elapsedTime, _totalTime);
        displayObj.y = _interpolator.interpolate(_from.y, _to.y, _elapsedTime, _totalTime);

        return (_elapsedTime >= _totalTime ? ObjectTask.STATUS_COMPLETE : ObjectTask.STATUS_INCOMPLETE);
    }

    override public function clone () :ObjectTask
    {
        return new LocationTask(_to, _totalTime, _interpolator);
    }

    protected var _interpolator :Interpolator;
    protected var _from :Point = new Point();
    protected var _to :Point;
    protected var _totalTime :Number = 0;
    protected var _elapsedTime :Number = 0;
}

}
