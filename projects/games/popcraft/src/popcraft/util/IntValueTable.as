package popcraft.util {

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
    public function IntValueTable (values :Array)
    {
        Assert.isNotNull(values);
        _values = values;

        if (_values.length == 0) {
            _values.push(0);
            _values.push(0);
        } else if (_values.length == 1) {
            _values.push(_values[0]);
        }

        _lastValue = _values[_values.length - 2];
        _scaleValue = _values[_values.length - 1];
    }

    public function getValueAt (index :uint) :int
    {
        if (index <= (_values.length - 2)) {
            return _values[index];
        } else {
            return _lastValue + (_scaleValue * (index - (_values.length - 2)));
        }
    }

    protected var _values :Array;
    protected var _lastValue :int;
    protected var _scaleValue :int;
}

}
