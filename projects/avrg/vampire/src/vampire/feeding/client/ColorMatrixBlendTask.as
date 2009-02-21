package vampire.feeding.client {

import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.simplegame.ObjectMessage;
import com.whirled.contrib.simplegame.ObjectTask;
import com.whirled.contrib.simplegame.SimObject;

import flash.display.DisplayObject;

import mx.effects.easing.*;

public class ColorMatrixBlendTask
    implements ObjectTask
{
    public static function colorize (disp :DisplayObject, fromColor :uint, toColor :uint,
        time :Number, interpolator :Function = null) :ColorMatrixBlendTask
    {
        return new ColorMatrixBlendTask(
            disp,
            new ColorMatrix().colorize(fromColor, 1),
            new ColorMatrix().colorize(toColor, 1),
            time,
            interpolator);
    }

    public function ColorMatrixBlendTask (disp :DisplayObject, cmFrom :ColorMatrix,
        cmTo :ColorMatrix, time :Number, interpolator :Function = null)
    {
        _disp = disp;
        _from = cmFrom;
        _to = cmTo;
        _totalTime = time;
        _interpolator = (interpolator != null ? interpolator : mx.effects.easing.Linear.easeNone);
    }

    public function update (dt :Number, obj :SimObject) :Boolean
    {
        _elapsedTime += dt;

        var amount :Number = _interpolator(
            Math.min(_elapsedTime, _totalTime),
            0,
            1,
            _totalTime);

        var blended :ColorMatrix = _from.clone().blend(_to, amount);
        _disp.filters = [ blended.createFilter() ];

        return (_elapsedTime >= _totalTime);
    }

    public function clone () :ObjectTask
    {
        return new ColorMatrixBlendTask(_disp, _from, _to, _totalTime, _interpolator);
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }

    protected var _disp :DisplayObject;
    protected var _from :ColorMatrix;
    protected var _to :ColorMatrix;
    protected var _totalTime :Number;
    protected var _interpolator :Function;

    protected var _elapsedTime :Number = 0;
}

}
