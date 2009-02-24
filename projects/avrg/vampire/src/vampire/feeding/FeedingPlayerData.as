package vampire.feeding {

import com.threerings.util.ArrayUtil;

import flash.utils.ByteArray;

public class FeedingPlayerData
{
    public function FeedingPlayerData ()
    {
        init();
    }

    public function collectStrainFromPlayer (strainType :int, playerId :int) :void
    {
        if (!hasCollectedStrainFromPlayer(strainType, playerId) &&
            getStrainCount(strainType) < Constants.MAX_COLLECTIONS_PER_STRAIN) {
            getStrainData(strainType).push(playerId);
        }
    }

    public function hasCollectedStrainFromPlayer (strainType :int, playerId :int) :Boolean
    {
        return ArrayUtil.contains(getStrainData(strainType), playerId);
    }

    public function getStrainCount (strainType :int) :int
    {
        return getStrainData(strainType).length;
    }

    public function clone () :FeedingPlayerData
    {
        var theClone :FeedingPlayerData = new FeedingPlayerData();
        theClone.fromBytes(toBytes());
        return theClone;
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        if (ba == null) {
            ba = new ByteArray();
        }

        for (var strain :int = 0; strain < Constants.NUM_SPECIAL_STRAINS; ++strain) {
            var strainData :Array = getStrainData(strain);
            ba.writeByte(strainData.length);
            for each (var playerId :int in strainData) {
                ba.writeInt(playerId);
            }
        }

        return ba;
    }

    public function fromBytes (ba :ByteArray) :void
    {
        init();

        for (var strain :int = 0; strain < Constants.NUM_SPECIAL_STRAINS; ++strain) {
            var strainData :Array = getStrainData(strain);
            var numPlayers :int = ba.readByte();
            for (var ii :int = 0; ii < numPlayers; ++ii) {
                strainData.push(ba.readInt());
            }
        }
    }

    protected function getStrainData (strainType :int) :Array
    {
        return _collectedStrains[strainType];
    }

    protected function init () :void
    {
        _collectedStrains = [];
        for (var ii :int = 0; ii < Constants.NUM_SPECIAL_STRAINS; ++ii) {
            _collectedStrains.push([]);
        }
    }

    protected var _collectedStrains :Array; // Array<Array<playerId>>
}

}
