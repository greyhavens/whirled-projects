package flashmob.data {

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;

import flash.utils.ByteArray;

import flashmob.*;

public class Pattern
{
    public var timeLimit :int;  // number of seconds
    public var locs :Array = []; // Array<PatternLoc>

    public function isSimilar (other :Pattern) :Boolean
    {
        if (locs.length != other.locs.length) {
            return false;
        }

        var loc :Vec3D;

        var xsum :Number = 0;
        var ysum :Number = 0;
        var zsum :Number = 0;
        for each (loc in locs) {
            xsum += loc.x;
            ysum += loc.y;
            zsum += loc.z;
        }

        for each (loc in other.locs) {
            xsum -= loc.x;
            ysum -= loc.y;
            zsum -= loc.z;
        }

        return Math.abs(xsum) < Constants.MIN_PATTERN_DIFF &&
               Math.abs(ysum) < Constants.MIN_PATTERN_DIFF &&
               Math.abs(zsum) < Constants.MIN_PATTERN_DIFF;
    }

    public function getBounds () :Rect3D
    {
        var minX :Number = Number.MAX_VALUE;
        var maxX :Number = Number.MIN_VALUE;
        var minY :Number = Number.MAX_VALUE;
        var maxY :Number = Number.MIN_VALUE;
        var minZ :Number = Number.MAX_VALUE;
        var maxZ :Number = Number.MIN_VALUE;

        for each (var loc :Vec3D in locs) {
            minX = Math.min(minX, loc.x);
            maxX = Math.max(maxX, loc.x);
            minY = Math.min(minY, loc.y);
            maxY = Math.max(maxY, loc.y);
            minZ = Math.min(minZ, loc.z);
            maxZ = Math.max(maxZ, loc.z);
        }

        return new Rect3D(minX, minY, minZ, maxX - minX, maxY - minY, maxZ - minZ);
    }

    public function offset (offset :Vec3D) :void
    {
        for each (var loc :Vec3D in locs) {
            loc.x += offset.x;
            loc.y += offset.y;
            loc.z += offset.z;
        }
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        ba = (ba != null ? ba : new ByteArray());

        ba.writeInt(timeLimit);
        ba.writeInt(locs.length);
        for each (var loc :Vec3D in locs) {
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
            locs[ii] = new Vec3D().fromBytes(ba);
        }

        return this;
    }

    public function toString () :String
    {
        var theString :String = "[";
        for (var ii :int = 0; ii < locs.length; ++ii) {
            var loc :Vec3D = locs[ii];
            theString += loc.toString();
            if (ii < locs.length - 1) {
                theString += "\n";
            }
        }

        return theString;
    }

    protected static var log :Log = Log.getLog(Pattern);

}

}
