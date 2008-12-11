package redrover {

import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.simplegame.ObjectMessage;
import com.whirled.contrib.simplegame.ObjectTask;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.components.SceneComponent;

public class TintTask
    implements ObjectTask
{
    public function TintTask (rgbStart :uint, amountStart :uint, rgbTarget :uint, amountTarget :uint,
        time :Number, interpolator :Function)
    {
        _rgbStart = rgbStart;
        _amountStart = amountStart;
        _rgbTarget = rgbTarget;
        _amountTarget = amountTarget;
        _time = time;
        _interp = interpolator;
    }

    public function update (dt :Number, obj :SimObject) :Boolean
    {
        var sceneObj :SceneComponent = (obj as SceneComponent);
        if (sceneObj == null) {
            throw new Error("TintTask can only be applied to objects that implement SceneComponent");
        }

        var color :ComponentColor
        if (_elapsedTime == 0) {
            if (_scratchColor == null) {
                _scratchColor = new ComponentColor();
            }

            decomposeColor(_rgbStart, _scratchColor);
            _r0 = _scratchColor.r;
            _g0 = _scratchColor.g;
            _b0 = _scratchColor.b;

            decomposeColor(_rgbTarget, _scratchColor);
            _r1 = _scratchColor.r;
            _g1 = _scratchColor.g;
            _b1 = _scratchColor.b;
        }

        _elapsedTime += dt;

        var totalMs :Number = _time * 1000;
        var elapsedMs :Number = Math.min(_elapsedTime * 1000, totalMs);

        _scratchColor.r = _interp(elapsedMs, _r0, (_r1 - _r0), totalMs);
        _scratchColor.g = _interp(elapsedMs, _g0, (_g1 - _g0), totalMs);
        _scratchColor.b = _interp(elapsedMs, _b0, (_b1 - _b0), totalMs);
        var amount :Number = _interp(elapsedMs, _amountStart, (_amountTarget - _amountStart),
            totalMs);

        sceneObj.displayObject.filters =
            [ new ColorMatrix().tint(composeColor(_scratchColor), amount).createFilter() ];

        return (_elapsedTime >= _time);
    }

    public function clone () :ObjectTask
    {
        return new TintTask(_rgbStart, _amountStart, _rgbTarget, _amountTarget, _time, _interp);
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }

    protected static function decomposeColor (rgbColor :uint, color :ComponentColor) :void
    {
        color.r = (rgbColor & 0xFF) / 255;
        color.g = ((rgbColor & 0xFF00) >> 8) / 255;
        color.b = ((rgbColor & 0xFF0000) >> 16) / 255;
    }

    protected static function composeColor (color :ComponentColor) :uint
    {
        return uint((color.r * 255) & 0xFF) |
               uint(((color.g * 255) << 8) & 0xFF00) |
               uint(((color.b * 255) << 16) & 0xFF0000);
    }

    protected var _rgbStart :uint, _rgbTarget :uint;
    protected var _amountStart :Number, _amountTarget :Number;
    protected var _time :Number;
    protected var _interp :Function;

    protected var _r0 :Number, _g0 :Number, _b0 :Number;
    protected var _r1 :Number, _g1 :Number, _b1 :Number;

    protected var _elapsedTime :Number = 0;

    protected static var _scratchColor :ComponentColor;
}

}

class ComponentColor
{
    public var r :Number;
    public var g :Number;
    public var b :Number;

    public static function decomposeColor (rgbColor :uint, color :ComponentColor) :void
    {
        color.r = (rgbColor & 0xFF) / 255;
        color.g = ((rgbColor & 0xFF00) >> 8) / 255;
        color.b = ((rgbColor & 0xFF0000) >> 16) / 255;
    }

    public static function composeColor (color :ComponentColor) :uint
    {
        return uint((color.r * 255) & 0xFF) |
               uint(((color.g * 255) << 8) & 0xFF00) |
               uint(((color.b * 255) << 16) & 0xFF0000);
    }

    public function ComponentColor (r :Number = 0, g :Number = 0, b :Number = 0)
    {
        this.r = r;
        this.g = g;
        this.b = b;
    }
}
