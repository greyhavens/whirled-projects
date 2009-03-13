package vampire.feeding {

import com.threerings.util.ArrayUtil;
import com.threerings.util.ClassUtil;
import com.threerings.util.Log;

import flash.utils.ByteArray;

import vampire.data.VConstants;

public class PlayerFeedingData
{
    public function PlayerFeedingData ()
    {
        init();
    }

    public function get timesPlayed () :int
    {
        return _timesPlayed;
    }

    public function incrementTimesPlayed () :void
    {
        _timesPlayed++;
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

    public function getNumTimesPlayedTutorial (tutorialType :int) :int
    {
        return (tutorialType >= 0 && tutorialType < _tutorialStatus.length ?
                _tutorialStatus[tutorialType] : 0);
    }

    public function incrementNumTimesPlayedTutorial (tutorialType :int) :void
    {
        if (tutorialType < 0) {
            return;
        }

        while (tutorialType >= _tutorialStatus.length) {
            _tutorialStatus.push(0);
        }

        _tutorialStatus[tutorialType] += 1;
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

        ba.writeByte(VERSION);
        ba.writeInt(_timesPlayed);
        ba.writeByte(_playerStrain);

        for (var strain :int = 0; strain < VConstants.UNIQUE_BLOOD_STRAINS; ++strain) {
            var strainData :Array = getStrainData(strain);
            ba.writeByte(strainData.length);
            for each (var playerId :int in strainData) {
                ba.writeInt(playerId);
            }
        }

        ba.writeByte(_tutorialStatus.length);
        for each (var numTimesPlayed :int in _tutorialStatus) {
            ba.writeByte(numTimesPlayed);
        }

        return ba;
    }

    public function fromBytes (ba :ByteArray) :void
    {
        init();

        var version :int = ba.readByte();
        if (version > VERSION) {
            log.warning("PlayerFeedingData version is too new", "version", version,
                        "curVersion", VERSION);
            return;
        }

        _timesPlayed = ba.readInt();
        _playerStrain = ba.readByte();

        for (var strain :int = 0; strain < VConstants.UNIQUE_BLOOD_STRAINS; ++strain) {
            var strainData :Array = getStrainData(strain);
            var numPlayers :int = ba.readByte();
            for (var ii :int = 0; ii < numPlayers; ++ii) {
                strainData.push(ba.readInt());
            }
        }

        var tutorialStatusSize :int = ba.readByte();
        for (ii = 0; ii < tutorialStatusSize; ++ii) {
            var numTimesPlayed :int = ba.readByte();
            _tutorialStatus.push(numTimesPlayed);
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
        _timesPlayed = 0;
        _playerStrain = 0;
        _collectedStrains = [];
        for (var ii :int = 0; ii < VConstants.UNIQUE_BLOOD_STRAINS; ++ii) {
            _collectedStrains.push([]);
        }

        _tutorialStatus = [];
    }

    public function toString() :String
    {
        return ClassUtil.shortClassName(this) + " _collectedStrains=" + _collectedStrains;
    }

    protected var _timesPlayed :int;
    protected var _playerStrain :int;
    protected var _collectedStrains :Array; // Array<Array<playerId>>
    protected var _tutorialStatus :Array; // Array<numTimesPlayed>

    protected static const VERSION :int = 0;

    protected static const log :Log = Log.getLog(PlayerFeedingData);
}

}
