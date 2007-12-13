package core.objects {

import core.AppObject;
import core.components.MeterComponent;
import flash.display.Shape;
import flash.display.DisplayObject;

public class RectMeter extends AppObject
    implements MeterComponent
{
    public function RectMeter ()
    {
        _display = new Shape();
    }

    override public function get displayObject () :DisplayObject
    {
        return _display;
    }

    public function get maxValue () :Number
    {
        return _maxValue;
    }

    public function set maxValue (val :Number) :void
    {
        _maxValue = val;
        _minValue = Math.min(_minValue, _maxValue);
        _value = Math.min(_value, _maxValue);
        _value = Math.max(_value, _minValue);

        _dirty = true;
    }

    public function get minValue () :Number
    {
        return _minValue;
    }

    public function set minValue (val :Number) :void
    {
        _minValue = val;
        _maxValue = Math.max(_maxValue, _minValue);
        _value = Math.min(_value, _maxValue);
        _value = Math.max(_value, _minValue);

        _dirty = true;
    }

    public function get value () :Number
    {
        return _value;
    }

    public function set value (val :Number) :void
    {
        _value = Math.min(val, _maxValue);
        _value = Math.max(_value, _minValue);

        _dirty = true;
    }

    public function get outlineColor () :uint
    {
        return _outlineColor;
    }

    public function set outlineColor (val :uint) :void
    {
        _outlineColor = val;
        _dirty = true;
    }

    public function get backgroundColor () :uint
    {
        return _backgroundColor;
    }

    public function set backgroundColor (val :uint) :void
    {
        _backgroundColor = val;
        _dirty = true;
    }

    public function get foregroundColor () :uint
    {
        return _foregroundColor;
    }

    public function set foregroundColor (val :uint) :void
    {
        _foregroundColor = val;
        _dirty = true;
    }

    public function get width () :int
    {
        return _width;
    }

    public function set width (val :int) :void
    {
        _width = val;
        _dirty = true;
    }

    public function get height () :int
    {
        return _height;
    }

    public function set height (val :int) :void
    {
        _height = val;
        _dirty = true;
    }

    // from AppObject
    override protected function update (dt :Number) :void
    {
        if (_dirty) {
            updateDisplay();
        }

        super.update(dt);
    }

    protected function updateDisplay () :void
    {
        var normalizedVal :Number = ((_value - _minValue) / (_maxValue - _minValue));

        var fgStart :Number = 0;
        var fgWidth :Number = normalizedVal * Number(_width);
        var bgStart :Number = fgWidth;
        var bgWidth :Number = Number(_width) - fgWidth;

        _display.graphics.clear();

        if (fgWidth > 0) {
            _display.graphics.beginFill(_foregroundColor);
            _display.graphics.drawRect(fgStart, 0, fgWidth, height);
            _display.graphics.endFill();
        }

        if (bgWidth > 0) {
            _display.graphics.beginFill(_backgroundColor);
            _display.graphics.drawRect(bgStart, 0, bgWidth, height);
            _display.graphics.endFill();
        }

        _display.graphics.lineStyle(1, _outlineColor);
        _display.graphics.drawRect(0, 0, _width, _height);
    }

    protected var _dirty :Boolean;

    protected var _outlineColor :uint;
    protected var _backgroundColor :uint;
    protected var _foregroundColor :uint;
    protected var _width :uint;
    protected var _height :uint;

    protected var _maxValue :Number;
    protected var _minValue :Number;
    protected var _value :Number;

    protected var _display :Shape;
}

}
