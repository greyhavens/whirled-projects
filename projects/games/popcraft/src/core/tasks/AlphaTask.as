package core.tasks {

import com.threerings.util.Assert;

import core.AppObject;
import core.ObjectTask;
import core.util.Interpolator;
import core.util.MXInterpolatorAdapter;

import flash.geom.Point;

import mx.effects.easing.*;
import flash.display.DisplayObject;

public class AlphaTask extends ObjectTask
{
    public static function CreateLinear (alpha :Number, time :Number) :AlphaTask
    {
        return new AlphaTask(
            alpha,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Linear.easeNone));
    }

    public static function CreateSmooth (alpha :Number, time :Number) :AlphaTask
    {
        return new AlphaTask(
            alpha,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeInOut));
    }

    public static function CreateEaseIn (alpha :Number, time :Number) :AlphaTask
    {
        return new AlphaTask(
            alpha,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeIn));
    }

    public static function CreateEaseOut (alpha :Number, time :Number) :AlphaTask
    {
        return new AlphaTask(
            alpha,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeOut));
    }

    public function AlphaTask (
        alpha :Number,
        time :Number = 0,
        interpolator :Interpolator = null)
    {
        // default to linear interpolation
        if (null == interpolator) {
            interpolator = new MXInterpolatorAdapter(mx.effects.easing.Linear.easeNone);
        }

        Assert.isTrue(time >= 0);

        _to = alpha;
        _totalTime = time;
        _interpolator = interpolator;
    }

    override public function update (dt :Number, obj :AppObject) :Boolean
    {
        var displayObj :DisplayObject = obj.displayObject;
        Assert.isNotNull(displayObj, "AlphaTask can only be applied to AppObjects with attached display objects.");

        if (0 == _elapsedTime) {
            _from = displayObj.alpha;
        }

        _elapsedTime += dt;

        displayObj.alpha = _interpolator.interpolate(_from, _to, _elapsedTime, _totalTime);

        return (_elapsedTime >= _totalTime);
    }

    override public function clone () :ObjectTask
    {
        return new AlphaTask(_to, _totalTime, _interpolator);
    }

    protected var _interpolator :Interpolator;

    protected var _to :Number;
    protected var _from :Number;

    protected var _totalTime :Number = 0;
    protected var _elapsedTime :Number = 0;
}

}
