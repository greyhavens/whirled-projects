package flashmob.data {

import com.threerings.util.ArrayUtil;

import flash.utils.ByteArray;

public class SpectacleSet
{
    public var spectacles :Array = [];

    public function getSpectacle (id :int) :Spectacle
    {
        return ArrayUtil.findIf(spectacles,
            function (spec :Spectacle) :Boolean {
                return spec.id == id;
            });
    }

    public static function fromBytes (ba :ByteArray) :SpectacleSet
    {
        return (ba != null ? new SpectacleSet().fromBytes(ba) : null);
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        ba = (ba != null ? ba : new ByteArray());

        ba.writeInt(spectacles.length);
        for each (var spectacle :Spectacle in spectacles) {
            spectacle.toBytes(ba);
        }

        return ba;
    }

    public function fromBytes (ba :ByteArray) :SpectacleSet
    {
        var count :int = ba.readInt();
        spectacles = ArrayUtil.create(count, null);
        for (var ii :int = 0; ii < count; ++ii) {
            spectacles[ii] = Spectacle.fromBytes(ba);
        }

        return this;
    }
}

}
