package flashmob.data {

import com.threerings.util.ArrayUtil;

import flash.geom.Rectangle;
import flash.utils.ByteArray;

public class Spectacle
{
    public static const VERSION :int = 0;

    public var version :int = VERSION;
    public var name :String;
    public var numPlayers :int;
    public var creatingPartyId :int;
    public var avatarId :int;
    public var patterns :Array = [];

    public static function fromBytes (ba :ByteArray) :Spectacle
    {
        return (ba != null ? new Spectacle().fromBytes(ba) : null);
    }

    public function normalize () :void
    {
        // offsets each location in each pattern so that the first pattern's top-left
        // location is at (0, 0)
        if (patterns.length > 0) {
            var bounds :Rectangle = Pattern(patterns[0]).getBounds();
            for each (var pattern :Pattern in patterns) {
                pattern.offsetLocs(-bounds.x, -bounds.y);
            }
        }
    }

    public function getBounds () :Rectangle
    {
        var minX :Number = Number.MAX_VALUE;
        var maxX :Number = Number.MIN_VALUE;
        var minY :Number = Number.MAX_VALUE;
        var maxY :Number = Number.MIN_VALUE;

        for each (var pattern :Pattern in patterns) {
            var bounds :Rectangle = pattern.getBounds();
            minX = Math.min(minX, bounds.left);
            maxX = Math.max(maxX, bounds.right);
            minY = Math.min(minY, bounds.top);
            maxY = Math.max(maxY, bounds.bottom);
        }

        return new Rectangle(minX, minY, maxX - minX, maxY - minY);
    }

    public function get numPatterns () :int
    {
        return (patterns != null ? patterns.length : 0);
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        ba = (ba != null ? ba : new ByteArray());

        ba.writeByte(version);
        ba.writeUTF(name);
        ba.writeShort(numPlayers);
        ba.writeInt(creatingPartyId);
        ba.writeInt(avatarId);
        ba.writeByte(patterns.length);
        for each (var pattern :Pattern in patterns) {
            pattern.toBytes(ba);
        }

        return ba;
    }

    public function fromBytes (ba :ByteArray) :Spectacle
    {
        version = ba.readByte();
        name = ba.readUTF();
        numPlayers = ba.readShort();
        creatingPartyId = ba.readInt();
        avatarId = ba.readInt();

        var numPatterns :int = ba.readByte();
        patterns = ArrayUtil.create(numPatterns);
        for (var ii :int = 0; ii < numPatterns; ++ii) {
            patterns[ii] = new Pattern().fromBytes(ba);
        }

        return this;
    }

    public function toString () :String
    {
        return "[name=" + name +
            " players=" + numPlayers +
            " numPatterns=" + numPatterns +
            "]";
    }

}

}
