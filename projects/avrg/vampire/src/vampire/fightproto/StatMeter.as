package vampire.fightproto {

import flash.display.Sprite;
import flash.geom.Point;
import flash.text.TextField;

public class StatMeter extends Sprite
{
    public static const SMALL :int = 0;
    public static const LARGE :int = 1;

    public function StatMeter (size :int, color :uint, label :String = "")
    {
        _size = size;
        _label = label;

        var rectSize :Point = RECT_SIZES[size];

        _rectMeter = new RectMeterView();
        _rectMeter.foregroundColor = color;
        _rectMeter.backgroundColor = 0xffffff;
        _rectMeter.outlineColor = 0;
        _rectMeter.meterWidth = rectSize.x;
        _rectMeter.meterHeight = rectSize.y;
        addChild(_rectMeter);

        _tf = TextBits.createText("");
        addChild(_tf);
    }

    public function updateDisplay () :void
    {
        _rectMeter.updateDisplay();

        var cur :int = int(this.value);
        var max :int = int(this.maxValue);
        TextBits.initTextField(_tf, _label + cur + "/" + max, TEXT_SIZES[_size], 0, 0);
        _tf.x = (this.width - _tf.width) * 0.5;
        _tf.y = (this.height - _tf.height) * 0.5;
    }

    public function get needsDisplayUpdate () :Boolean
    {
        return _rectMeter.needsDisplayUpdate;
    }

    public function get maxValue () :Number
    {
        return _rectMeter.maxValue;
    }

    public function set maxValue (val :Number) :void
    {
        _rectMeter.maxValue = val;
    }

    public function get minValue () :Number
    {
        return _rectMeter.minValue;
    }

    public function set minValue (val :Number) :void
    {
        _rectMeter.minValue = val;
    }

    public function get value () :Number
    {
        return _rectMeter.value;
    }

    public function set value (val :Number) :void
    {
        _rectMeter.value = val;
    }

    protected var _size :int;
    protected var _label :String;
    protected var _rectMeter :RectMeterView;
    protected var _tf :TextField;

    protected static const RECT_SIZES :Array = [
        new Point(100, 15),
        new Point(200, 20)
    ];

    protected static const TEXT_SIZES :Array = [ 1, 1.2 ];
}

}
