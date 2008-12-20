package flashmob.data {

import com.threerings.util.ArrayUtil;

import flash.geom.Rectangle;
import flash.utils.ByteArray;

public class Pattern
{
    public var timeLimit :int;  // number of seconds
    public var locs :Array = []; // Array<PatternLoc>

    public function getBounds () :Rectangle
    {
        var minX :Number = Number.MAX_VALUE;
        var maxX :Number = Number.MIN_VALUE;
        var minY :Number = Number.MAX_VALUE;
        var maxY :Number = Number.MIN_VALUE;

        for each (var loc :PatternLoc in locs) {
            minX = Math.min(minX, loc.x);
            maxX = Math.max(maxX, loc.x);
            minY = Math.min(minY, loc.y);
            maxY = Math.max(maxY, loc.y);
        }

        return new Rectangle(minX, minY, maxX - minX, maxY - minY);
    }

    public function offsetLocs (xOffset :Number, yOffset :Number) :void
    {
        for each (var loc :PatternLoc in locs) {
            loc.x += xOffset;
            loc.y += yOffset;
        }
    }

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
