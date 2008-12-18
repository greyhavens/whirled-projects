package flashmob.data {

import com.threerings.util.ArrayUtil;

import flash.utils.ByteArray;

public class Pattern
{
    public var timeLimit :int;  // number of seconds
    public var locs :Array = []; // Array<PatternLoc>

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        ba = (ba != null ? ba : new ByteArray());

        ba.writeInt(timeLimit);
        ba.writeInt(locs.length);
        for each (var loc :PatternLoc in locs) {
            loc.toBytes(ba);
        }

        return ba;
    }

    public function fromBytes (ba :ByteArray) :Pattern
    {
        timeLimit = ba.readInt();

        var numLocs :int = ba.readInt();
        locs = ArrayUtil.create(numLocs);
        for (var ii :int = 0; ii < numLocs; ++ii) {
            locs[ii] = new PatternLoc().fromBytes(ba);
        }

        return this;
    }

}

}
