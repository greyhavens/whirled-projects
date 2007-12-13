package core.tasks {

import com.threerings.util.Assert;

import core.AppObject;
import core.ObjectTask;
import core.util.Interpolator;
import core.util.MXInterpolatorAdapter;
import core.components.MeterComponent;

import mx.effects.easing.*;

public class MeterValueTask extends ObjectTask
{
    public static function CreateLinear (value :Number, time :Number) :MeterValueTask
    {
        return new MeterValueTask(
            value,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Linear.easeNone));
    }

    public static function CreateSmooth (value :Number, time :Number) :MeterValueTask
    {
        return new MeterValueTask(
            value,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeInOut));
    }

    public static function CreateEaseIn (value :Number, time :Number) :MeterValueTask
    {
        return new MeterValueTask(
            value,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeIn));
    }

    public static function CreateEaseOut (value :Number, time :Number) :MeterValueTask
    {
        return new MeterValueTask(
            value,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeOut));
    }

    public static function CreateWithFunction (value :Number, time :Number, fn :Function) :MeterValueTask
    {
        return new MeterValueTask(
           value,
           time,
           new MXInterpolatorAdapter(fn));
    }

    public function MeterValueTask (
        value :Number,
        time :Number = 0,
        interpolator :Interpolator = null)
    {
        // default to linear interpolation
        if (null == interpolator) {
            interpolator = new MXInterpolatorAdapter(mx.effects.easing.Linear.easeNone);
        }

        Assert.isTrue(time >= 0);

        _to = value;
        _totalTime = time;
        _interpolator = interpolator;
    }

    override public function update (dt :Number, obj :AppObject) :uint
    {
        var meterComponent :MeterComponent = (obj as MeterComponent);
        Assert.isNotNull(meterComponent, "MeterValueTask can only be applied to MeterComponents.");

        if (0 == _elapsedTime) {
            _from = meterComponent.value;
        }

        _elapsedTime += dt;

        meterComponent.value = _interpolator.interpolate(_from, _to, _elapsedTime, _totalTime);

        return (_elapsedTime >= _totalTime ? ObjectTask.STATUS_COMPLETE : ObjectTask.STATUS_INCOMPLETE);
    }

    override public function clone () :ObjectTask
    {
        return new MeterValueTask(_to, _totalTime, _interpolator);
    }

    protected var _interpolator :Interpolator;

    protected var _to :Number;
    protected var _from :Number;

    protected var _totalTime :Number = 0;
    protected var _elapsedTime :Number = 0;
}

}
