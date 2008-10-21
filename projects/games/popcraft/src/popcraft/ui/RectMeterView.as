package popcraft.ui {

import flash.display.Graphics;
import flash.display.Shape;

public class RectMeterView extends Shape
{
    public function get needsDisplayUpdate () :Boolean
    {
        return _needsDisplayUpdate;
    }

    public function get maxValue () :Number
    {
        return _maxValue;
    }

    public function set maxValue (val :Number) :void
    {
        if (val != _maxValue) {
            _maxValue = val;
            _minValue = Math.min(_minValue, _maxValue);
            _value = Math.min(_value, _maxValue);
            _value = Math.max(_value, _minValue);

            _needsDisplayUpdate = true;
        }
    }

    public function get minValue () :Number
    {
        return _minValue;
    }

    public function set minValue (val :Number) :void
    {
        if (val != _minValue) {
            _minValue = val;
            _maxValue = Math.max(_maxValue, _minValue);
            _value = Math.min(_value, _maxValue);
            _value = Math.max(_value, _minValue);

            _needsDisplayUpdate = true;
        }
    }

    public function get value () :Number
    {
        return _value;
    }

    public function set value (val :Number) :void
    {
        val = Math.min(val, _maxValue);
        val = Math.max(val, _minValue);

        if (val != _value) {
            _value = val;
            _needsDisplayUpdate = true;
        }
    }

    public function get outlineSize () :Number
    {
        return _outlineSize;
    }

    public function set outlineSize (val :Number) :void
    {
        if (_outlineSize != val) {
            _outlineSize = val;
            _needsDisplayUpdate = true;
        }
    }

    public function get outlineColor () :uint
    {
        return _outlineColor;
    }

    public function set outlineColor (val :uint) :void
    {
        if (_outlineColor != val) {
            _outlineColor = val;
            _needsDisplayUpdate = true;
        }
    }

    public function get backgroundColor () :uint
    {
        return _backgroundColor;
    }

    public function set backgroundColor (val :uint) :void
    {
        if (_backgroundColor != val) {
            _backgroundColor = val;
            _needsDisplayUpdate = true;
        }
    }

    public function get foregroundColor () :uint
    {
        return _foregroundColor;
    }

    public function set foregroundColor (val :uint) :void
    {
        if (_foregroundColor != val) {
            _foregroundColor = val;
            _needsDisplayUpdate = true;
        }
    }

    public function get meterWidth () :Number
    {
        return _width;
    }

    public function set meterWidth (val :Number) :void
    {
        if (_width != val) {
            _width = val;
            _needsDisplayUpdate = true;
        }
    }

    public function get meterHeight () :Number
    {
        return _height;
    }

    public function set meterHeight (val :Number) :void
    {
        if (_height != val) {
            _height = val;
            _needsDisplayUpdate = true;
        }
    }

    public function updateDisplay () :void
    {
        var normalizedVal :Number = ((_value - _minValue) / (_maxValue - _minValue));

        var fgStart :Number = 0;
        var fgWidth :Number = normalizedVal * _width;
        var bgStart :Number = fgWidth;
        var bgWidth :Number = _width - fgWidth;

        var g :Graphics = this.graphics;

        g.clear();

        if (fgWidth > 0) {
            g.beginFill(_foregroundColor, 1);
            g.drawRect(fgStart, 0, fgWidth, _height);
            g.endFill();
        }

        if (bgWidth > 0) {
            g.beginFill(_backgroundColor, 1);
            g.drawRect(bgStart, 0, bgWidth, _height);
            g.endFill();
        }

        g.lineStyle(_outlineSize, _outlineColor);
        g.drawRect(0, 0, _width, _height);

        _needsDisplayUpdate = false;
    }

    protected var _outlineColor :uint;
    protected var _outlineSize :Number = 1;
    protected var _backgroundColor :uint;
    protected var _foregroundColor :uint;
    protected var _width :Number;
    protected var _height :Number;

    protected var _maxValue :Number = 0;
    protected var _minValue :Number = 0;
    protected var _value :Number = 0;

    protected var _needsDisplayUpdate :Boolean;
}

}
