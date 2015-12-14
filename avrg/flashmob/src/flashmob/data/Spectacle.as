package flashmob.data {

import com.threerings.util.ArrayUtil;

import flash.utils.ByteArray;

import flashmob.Rect3D;

public class Spectacle
{
    public static const VERSION :int = 0;

    public var version :int = VERSION;
    public var id :int = -1;
    public var name :String;
    public var numPlayers :int;
    public var highScoringPartyId :int;
    public var creatingPartyId :int;
    public var avatarId :int;
    public var patterns :Array = [];

    public static function fromBytes (ba :ByteArray) :Spectacle
    {
        return (ba != null ? new Spectacle().fromBytes(ba) : null);
    }

    public function getCenter () :Vec3D
    {
        var bounds :Rect3D = getBounds();
        return new Vec3D(
            bounds.x + (bounds.width * 0.5),
            bounds.y + (bounds.height * 0.5),
            bounds.z + (bounds.depth * 0.5));
    }

    public function setCenter (center :Vec3D) :void
    {
        // offsets each location in each pattern so that the center of the spectacle
        // is at the given point
        if (patterns.length > 0) {
            var offset :Vec3D = center.subtract(getCenter());
            for each (var pattern :Pattern in patterns) {
                pattern.offset(offset);
            }
        }
    }

    /*public function normalize () :void
    {
        // offsets each location in each pattern so that the first pattern's top-left
        // location is at (0, 0)
        if (patterns.length > 0) {
            var bounds :Rect3D = Pattern(patterns[0]).getBounds();
            for each (var pattern :Pattern in patterns) {
                pattern.offset(new Vec3D(-bounds.x, -bounds.y, -bounds.z));
            }
        }
    }*/

    public function getBounds () :Rect3D
    {
        var minX :Number = Number.MAX_VALUE;
        var maxX :Number = Number.MIN_VALUE;
        var minY :Number = Number.MAX_VALUE;
        var maxY :Number = Number.MIN_VALUE;
        var minZ :Number = Number.MAX_VALUE;
        var maxZ :Number = Number.MIN_VALUE;

        for each (var pattern :Pattern in patterns) {
            var bounds :Rect3D = pattern.getBounds();
            minX = Math.min(minX, bounds.x);
            maxX = Math.max(maxX, bounds.x + bounds.width);
            minY = Math.min(minY, bounds.y);
            maxY = Math.max(maxY, bounds.y + bounds.height);
            minZ = Math.min(minZ, bounds.z);
            maxZ = Math.max(maxZ, bounds.z + bounds.depth);
        }

        return new Rect3D(minX, minY, minZ, maxX - minX, maxY - minY, maxZ - minZ);
    }

    public function get numPatterns () :int
    {
        return (patterns != null ? patterns.length : 0);
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        ba = (ba != null ? ba : new ByteArray());

        ba.writeByte(version);
        ba.writeInt(id);
        ba.writeUTF(name);
        ba.writeShort(numPlayers);
        ba.writeInt(highScoringPartyId);
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
        id = ba.readInt();
        name = ba.readUTF();
        numPlayers = ba.readShort();
        highScoringPartyId = ba.readInt();
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
            " highScoringPartyId=" + highScoringPartyId +
            " creatingPartyId=" + creatingPartyId +
            " avatarId=" + avatarId +
            "]";
    }

}

}
