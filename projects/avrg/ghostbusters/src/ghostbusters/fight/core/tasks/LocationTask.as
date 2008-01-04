package ghostbusters.fight.core.tasks {

import com.threerings.util.Assert;

import ghostbusters.fight.core.AppObject;
import ghostbusters.fight.core.ObjectTask;
import ghostbusters.fight.core.util.Interpolator;
import ghostbusters.fight.core.util.MXInterpolatorAdapter;

import flash.geom.Point;

import mx.effects.easing.*;
import flash.display.DisplayObject;

public class LocationTask extends ObjectTask
{
    public static function CreateLinear (x :Number, y :Number, time :Number) :LocationTask
    {
        return new LocationTask(
            x, y,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Linear.easeNone));
    }

    public static function CreateSmooth (x :Number, y :Number, time :Number) :LocationTask
    {
        return new LocationTask(
            x, y,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeInOut));
    }

    public static function CreateEaseIn (x :Number, y :Number, time :Number) :LocationTask
    {
        return new LocationTask(
            x, y,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeIn));
    }

    public static function CreateEaseOut (x :Number, y :Number, time :Number) :LocationTask
    {
        return new LocationTask(
            x, y,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeOut));
    }

    public static function CreateWithFunction (x :Number, y:Number, time :Number, fn :Function) :LocationTask
    {
        return new LocationTask(
           x, y,
           time,
           new MXInterpolatorAdapter(fn));
    }

    public function LocationTask (
        x :Number,
        y :Number,
        time :Number = 0,
        interpolator :Interpolator = null)
    {
        // default to linear interpolation
        if (null == interpolator) {
            interpolator = new MXInterpolatorAdapter(mx.effects.easing.Linear.easeNone);
        }

        Assert.isTrue(time >= 0);

        _toX = x;
        _toY = y;
        _totalTime = time;
        _interpolator = interpolator;
    }

    override public function update (dt :Number, obj :AppObject) :Boolean
    {
        var displayObj :DisplayObject = obj.displayObject;
        Assert.isNotNull(displayObj, "LocationTask can only be applied to AppObjects with attached display objects.");

        if (0 == _elapsedTime) {
            _fromX = displayObj.x;
            _fromY = displayObj.y;
        }

        _elapsedTime += dt;

        displayObj.x = _interpolator.interpolate(_fromX, _toX, _elapsedTime, _totalTime);
        displayObj.y = _interpolator.interpolate(_fromY, _toY, _elapsedTime, _totalTime);

        return (_elapsedTime >= _totalTime);
    }

    override public function clone () :ObjectTask
    {
        return new LocationTask(_toX, _toY, _totalTime, _interpolator);
    }

    protected var _interpolator :Interpolator;

    protected var _toX :Number;
    protected var _toY :Number;

    protected var _fromX :Number;
    protected var _fromY :Number;

    protected var _totalTime :Number = 0;
    protected var _elapsedTime :Number = 0;
}

}
