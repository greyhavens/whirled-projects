package vampire.feeding {

import com.threerings.util.ArrayUtil;

import flash.utils.ByteArray;

public class PlayerFeedingData
{
    public function PlayerFeedingData ()
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

    public function canCollectStrainFromPlayer (strainType :int, playerId :int) :Boolean
    {
        return (getStrainCount(strainType) < Constants.MAX_COLLECTIONS_PER_STRAIN &&
                !ArrayUtil.contains(getStrainData(strainType), playerId));
    }

    public function hasCollectedStrainFromPlayer (strainType :int, playerId :int) :Boolean
    {
        return ArrayUtil.contains(getStrainData(strainType), playerId);
    }

    public function getStrainCount (strainType :int) :int
    {
        return getStrainData(strainType).length;
    }

    public function isEqual (other :PlayerFeedingData) :Boolean
    {
        return (this == other ? true : com.threerings.util.Util.equals(toBytes(), other.toBytes()));
    }

    public function clone () :PlayerFeedingData
    {
        var theClone :PlayerFeedingData = new PlayerFeedingData();
        var bytes :ByteArray = toBytes();
        bytes.position = 0;
        theClone.fromBytes(bytes);
        return theClone;
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        if (ba == null) {
            ba = new ByteArray();
        }

        ba.writeByte(_playerStrain);

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

        _playerStrain = ba.readByte();

        for (var strain :int = 0; strain < Constants.NUM_SPECIAL_STRAINS; ++strain) {
            var strainData :Array = getStrainData(strain);
            var numPlayers :int = ba.readByte();
            for (var ii :int = 0; ii < numPlayers; ++ii) {
                strainData.push(ba.readInt());
            }
        }
    }

    public function set playerStrain (val :int) :void
    {
        _playerStrain = val;
    }

    public function get playerStrain () :int
    {
        return _playerStrain;
    }

    protected function getStrainData (strainType :int) :Array
    {
        return _collectedStrains[strainType];
    }

    protected function init () :void
    {
        _playerStrain = 0;
        _collectedStrains = [];
        for (var ii :int = 0; ii < Constants.NUM_SPECIAL_STRAINS; ++ii) {
            _collectedStrains.push([]);
        }
    }

    protected var _playerStrain :int;
    protected var _collectedStrains :Array; // Array<Array<playerId>>
}

}
