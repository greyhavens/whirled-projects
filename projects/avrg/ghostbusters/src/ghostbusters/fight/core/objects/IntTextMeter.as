package ghostbusters.fight.core.objects {

import ghostbusters.fight.core.AppObject;
import ghostbusters.fight.core.components.MeterComponent;
import flash.display.DisplayObject;
import flash.text.TextField;

public class IntTextMeter extends AppObject
    implements MeterComponent
{
    public function IntTextMeter ()
    {
        _display = new TextField();
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

    public function get textColor () :uint
    {
        return _display.textColor;
    }

    public function set textColor (val :uint) :void
    {
        _display.textColor = textColor;
    }

    public function get font () :String
    {
        return _display.defaultTextFormat.font;
    }

    public function set font (newFont :String) :void
    {
        _display.defaultTextFormat.font = newFont;
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
        var textString :String = Math.floor(_value) + "/" + Math.floor(_maxValue);
        _display.text = textString;
        _display.width = _display.textWidth + 3;
        _display.height = _display.textHeight + 3;
    }

    protected var _dirty :Boolean;

    protected var _maxValue :Number;
    protected var _minValue :Number;
    protected var _value :Number;

    protected var _display :TextField;
}

}
