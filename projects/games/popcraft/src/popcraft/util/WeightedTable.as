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
    public function WeightedTable (dataTable :Array, defaultRandStreamId :uint)
    {
        Assert.isNotNull(dataTable);
        Assert.isTrue(dataTable.length % 2 == 0);

        _defaultRandStreamId = defaultRandStreamId;

        // populate the table
        _maxVal = 0;
        for (var i :uint = 0; i < dataTable.length / 2; ++i) {
            var data :* = dataTable[i * 2];
            var weight :Number = dataTable[(i * 2) + 1];

            var entry :TableEntry = new TableEntry();
            entry.min = _maxVal;
            entry.max = _maxVal + weight;
            entry.data = data;

            _table.push(entry);

            _maxVal += weight;
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
        var hi :uint = (_table.length > 0 ? _table.length - 1 : 0);

        var entry :TableEntry;

        // binary-search the table for the appropriate entry
        for (;;) {
            var index :uint = lo + ((hi - lo) / 2);
            entry = _table[index];

            if (val >= entry.min && val < entry.max) {
                // found it
                break;
            } else if (val >= entry.max) {
                lo = index + 1;
            } else {
                hi = index - 1;
            }
        }

        Assert.isNotNull(entry);
        Assert.isTrue(val >= entry.min && val < entry.max);

        return entry;
    }

    public function get length () :uint
    {
        return _table.length;
    }

    public static function unitTest () :void
    {
        var table :WeightedTable;
        var entry :int;

        // single entry
        table = new WeightedTable([5, 0.8], Rand.STREAM_COSMETIC);
        testNextEntry(0.4, 5, "1 entry");

        // two entries, equal weight
        table = new WeightedTable([1, 1, 2, 1], Rand.STREAM_COSMETIC);
        testNextEntry(0.8, 1, "2 entries - 1");
        testNextEntry(1, 2, "2 entries - 2");
        testNextEntry(1.67, 2, "2 entries - 3");

        // 5 entries
        table = new WeightedTable([
            1, 0.1,
            2, 0.5,
            3, 1,
            4, 0.8,
            5, 0.05
        ], Rand.STREAM_COSMETIC);
        testNextEntry(0.05, 1, "5 entries - 1");
        testNextEntry(0.59, 2, "5 entries - 2");
        testNextEntry(0.62, 3, "5 entries - 3");
        testNextEntry(2, 4, "5 entries - 4");
        testNextEntry(2.401, 5, "5 entries - 5");


        function testNextEntry (val :Number, expectedOutput :int, desc :String) :void
        {
            entry = table.findEntry(val).data;
            trace(desc + ": " + (expectedOutput === entry ? "pass" : "fail"));
        }
    }

    protected var _table :Array = new Array();
    protected var _defaultRandStreamId :uint;

    protected var _maxVal :Number;

}

}

class TableEntry
{
    public var min :Number;
    public var max :Number;
    public var data :*;
}
