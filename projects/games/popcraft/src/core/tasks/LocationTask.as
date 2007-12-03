package core.tasks {

import com.threerings.util.Assert;

import core.ObjectTask;
import core.util.Interpolator;
import core.util.LinearInterpolator;
import core.util.CubicInterpolator;

import flash.geom.Point;

public class LocationTask extends ObjectTask
{
    public static function LocationTaskLinear (loc :Point, time :Number) :LocationTask
    {
        return new LocationTask(loc, time, new LinearInterpolator());
    }

    public static function LocationTaskSmooth (loc :Point, time :Number) :LocationTask
    {
        return new LocationTask(loc, time, new CubicInterpolator());
    }

    public function LocationTask (loc :Point, time :Number = 0, interpolator :Interpolator = new LinearInterpolator())
    {
        Assert.isTrue(null != loc);
        Assert.isTrue(null != interpolator);
        Assert.isTrue(time >= 0);

        _to = loc;
        _totalTime = time;
        _interpolator = interpolator;
    }

    override public function update (dt :Number, obj :AppObject) :uint
    {
        if (0 == _elapsedTime) {
            _from.x = obj.x;
            _from.y = obj.y;
        }

        _elapsedTime += dt;

        obj.x = _interpolator.interpolate(_from.x, _to.x, _elapsedTime, _totalTime);
        obj.y = _interpolator.interpolate(_from.y, _to.y, _elapsedTime, _totalTime);

        return (_elapsedTime >= _totalTime ? ObjectTask.STATUS_COMPLETE : ObjectTask.STATUS_INCOMPLETE);
    }

    override public function clone () :ObjectTask
    {
        return new LocationTask(_to, _totalTime, _interpolator);
    }

    protected var _interpolator :Interpolator;
    protected var _from :Point;
    protected var _to :Point;
    protected var _totalTime :Number = 0;
    protected var _elapsedTime :Number = 0;
}

}
