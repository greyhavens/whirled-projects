package redrover.util {

import com.threerings.util.Assert;

/**
 * A simple utility class that stores a table of values.
 * The last value in the table is the amount to increase requests for
 * out-of-bounds values by.
 * For example, a table that looks like this:
 * [2, 3, 5, 7, 10, 3]
 * represents a value sequence that looks like this:
 * [2, 3, 5, 7, 10, 13, 16, 19, ...]
 */
public class IntValueTable
{
    public function IntValueTable (values :Array, outOfBoundsScaleValue :int)
    {
        _values = values;
        _scaleValue = outOfBoundsScaleValue;
        _lastValue = (values.length > 0 ? values[values.length - 1] : 0);
    }

    public function getValueAt (index :int) :int
    {
        if (index < _values.length) {
            return _values[index];
        } else {
            return _lastValue + (_scaleValue * (index - _values.length + 1));
        }
    }

    public function clone () :IntValueTable
    {
        return new IntValueTable(_values.slice(), _scaleValue);
    }

    public static function fromXml (xmlData :XML) :IntValueTable
    {
        var values :Array = [];
        for each (var indexData :XML in xmlData.Index) {
            values.push(XmlReader.getIntAttr(indexData, "value"));
        }

        var outOfBoundsScaleVal :int;
        var outOfBoundsScaleData :XML = xmlData.OutOfBoundsScale[0];
        if (null != outOfBoundsScaleData) {
            outOfBoundsScaleVal = XmlReader.getIntAttr(outOfBoundsScaleData, "value", 0);
        }

        return new IntValueTable(values, outOfBoundsScaleVal);
    }

    protected var _values :Array;
    protected var _lastValue :int;
    protected var _scaleValue :int;
}

}
