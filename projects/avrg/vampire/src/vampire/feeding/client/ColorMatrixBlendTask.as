package vampire.feeding.client {

import com.threerings.flash.FilterUtil;
import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.simplegame.ObjectMessage;
import com.whirled.contrib.simplegame.ObjectTask;
import com.whirled.contrib.simplegame.SimObject;

import flash.display.DisplayObject;
import flash.filters.ColorMatrixFilter;

import mx.effects.easing.*;

public class ColorMatrixBlendTask
    implements ObjectTask
{
    public static function colorize (disp :DisplayObject, fromColor :uint, toColor :uint,
        time :Number, interpolator :Function = null, preserveFilters :Boolean = false)
        :ColorMatrixBlendTask
    {
        return new ColorMatrixBlendTask(
            disp,
            new ColorMatrix().colorize(fromColor, 1),
            new ColorMatrix().colorize(toColor, 1),
            time,
            interpolator,
            preserveFilters);
    }

    public function ColorMatrixBlendTask (disp :DisplayObject, cmFrom :ColorMatrix,
        cmTo :ColorMatrix, time :Number, interpolator :Function = null,
        preserveFilters :Boolean = false)
    {
        _disp = disp;
        _from = cmFrom;
        _to = cmTo;
        _totalTime = time;
        _interpolator = (interpolator != null ? interpolator : mx.effects.easing.Linear.easeNone);
        _preserveFilters = preserveFilters;
    }

    public function update (dt :Number, obj :SimObject) :Boolean
    {
        _elapsedTime += dt;

        var amount :Number = _interpolator(
            Math.min(_elapsedTime, _totalTime),
            0,
            1,
            _totalTime);

        var filter :ColorMatrixFilter = _from.clone().blend(_to, amount).createFilter();

        // If _preserveFilters is set, we'll preserve any filters already on the DisplayObject
        // when adding the new filter. This can be an expensive operation, so it's false by default.
        if (_preserveFilters) {
            if (_oldFilter != null) {
                FilterUtil.removeFilter(_disp, _oldFilter);
            }
            FilterUtil.addFilter(_disp, filter);
            _oldFilter = filter;

        } else {
            _disp.filters = [ filter ];
        }

        return (_elapsedTime >= _totalTime);
    }

    public function clone () :ObjectTask
    {
        return new ColorMatrixBlendTask(
            _disp,
            _from,
            _to,
            _totalTime,
            _interpolator,
            _preserveFilters);
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
    protected var _preserveFilters :Boolean;

    protected var _oldFilter :ColorMatrixFilter;

    protected var _elapsedTime :Number = 0;
}

}
