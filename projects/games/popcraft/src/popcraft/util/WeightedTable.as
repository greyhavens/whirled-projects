package popcraft.util {

import com.threerings.util.Assert;

import com.whirled.contrib.core.util.Rand;

public class WeightedTable
{
    /**
     * Creates a new WeightedTable.
     * "dataTable" must be an array of object/number pairs. Each number in the array
     * corresponds to its object's weight, relative to the rest of the objects in the table.
     */
    public function WeightedTable (var dataTable :Array, defaultRandStreamId = Rand.STREAM_COSMETIC)
    {
        Assert.isNotNull(dataTable);
        Assert.isTrue(dataTable.length % 2 == 0);

        _defaultRandStreamId = defaultRandStreamId;

        // populate the table
        _maxVal = 0;
        for (var i :uint = 0; i < dataTable.length / 2; ++i) {
            var data :* = dataTable[i * 2];
            var weight :Number = dataTable[(i * 2) + 1];

            _maxVal += weight;

            var entry :TableEntry = new TableEntry();
            entry.val = _maxVal;
            entry.data = data;
            _table.push(entry);
        }
    }

    public function nextEntry (randStreamId :int = -1) :*
    {
        var val :Number = Rand.nextNumberRange(0, _maxVal, (randStreamId >= 0 ? randStreamId : _defaultRandStreamId));
        return this.findEntry(val).data;
    }

    protected function findEntry (val :Number) :TableEntry
    {
        Assert.isTrue(val >= 0 && val < _maxVal);

        var lo :uint = 0;
        var hi :uint = _table.length - 1;

        var entry :TableEntry;

        // binary-search the table for the appropriate entry
        for (;;) {
            var index :uint = lo + ((hi - lo) / 2);
            entry = _table[index];

            if (lo == hi) {
                // found it
                break;
            } else if (entry.val < val) {
                // too low
                lo = index + 1;
            } else {
                hi = index - 1;
            }
        }

        Assert.isNotNull(entry);
        Assert.isTrue(entry.val >= val);

        return entry;
    }

    public function get length () :uint
    {
        return _table.length;
    }

    protected var _table :Array;
    protected var _defaultRandStreamId :uint;

    protected var _maxVal :Number;

}

}

class TableEntry
{
    public var val :Number;
    public var data :*;
}
