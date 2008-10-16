package popcraft {

import com.threerings.util.ArrayUtil;

import flash.utils.ByteArray;

public class PlayerStats
    implements UserCookieDataSource
{
    public var mpGamesPlayed :Array;        // Array of ints, one for each multiplayer game type
    public var mpGamesWon :Array;           // ditto
    public var resourcesGathered :Array;    // Array of ints, one for each resource type
    public var spellsCast :Array;           // Array of ints, one for each spell type
    public var creaturesCreated :Array;     // Array of ints, one for each creature type
    public var creaturesKilled :Array;      // ditto
    public var creaturesLostToDaytime :Array; // ditto
    public var totalGameTime :Number;
    public var hasMorbidInfection :Boolean; // the viral trophy!

    public function PlayerStats ()
    {
        this.initStats();
    }

    public function get totalGamesPlayed () :int
    {
        return sumInts(mpGamesPlayed);
    }

    public function get totalGamesWon () :int
    {
        return sumInts(mpGamesWon);
    }

    public function get totalGamesLost () :int
    {
        return this.totalGamesPlayed - this.totalGamesWon;
    }

    public function get totalResourcesGathered () :int
    {
        return sumInts(resourcesGathered);
    }

    public function get totalSpellsCast () :int
    {
        return sumInts(spellsCast);
    }

    public function get totalCreaturesCreated () :int
    {
        return sumInts(creaturesCreated);
    }

    public function get totalCreaturesKilled () :int
    {
        return sumInts(creaturesKilled);
    }

    public function get totalCreaturesLostToDaytime () :int
    {
        return sumInts(creaturesLostToDaytime);
    }

    public function writeCookieData (cookie :ByteArray) :void
    {
        writeIntsToCookie(mpGamesPlayed, cookie);
        writeIntsToCookie(mpGamesWon, cookie);
        writeIntsToCookie(resourcesGathered, cookie);
        writeIntsToCookie(spellsCast, cookie);
        writeIntsToCookie(creaturesCreated, cookie);
        writeIntsToCookie(creaturesKilled, cookie);
        writeIntsToCookie(creaturesLostToDaytime, cookie);

        cookie.writeDouble(totalGameTime);
        cookie.writeBoolean(hasMorbidInfection);
    }

    public function readCookieData (version :int, cookie :ByteArray) :void
    {
        this.initStats();

        readIntsFromCookie(mpGamesPlayed, cookie);
        readIntsFromCookie(mpGamesWon, cookie);
        readIntsFromCookie(resourcesGathered, cookie);
        readIntsFromCookie(spellsCast, cookie);
        readIntsFromCookie(creaturesCreated, cookie);
        readIntsFromCookie(creaturesKilled, cookie);
        readIntsFromCookie(creaturesLostToDaytime, cookie);

        totalGameTime = cookie.readDouble();
        hasMorbidInfection = cookie.readBoolean();
    }

    public function get minCookieVersion () :int
    {
        return 0;
    }

    public function cookieReadFailed () :Boolean
    {
        this.initStats();
        return true;
    }

    public function combineWith (other :PlayerStats) :void
    {
        combineNumericArrays(mpGamesPlayed, other.mpGamesPlayed);
        combineNumericArrays(mpGamesWon, other.mpGamesWon);
        combineNumericArrays(resourcesGathered, other.resourcesGathered);
        combineNumericArrays(spellsCast, other.spellsCast);
        combineNumericArrays(creaturesCreated, other.creaturesCreated);
        combineNumericArrays(creaturesKilled, other.creaturesKilled);
        combineNumericArrays(creaturesLostToDaytime, other.creaturesLostToDaytime);

        totalGameTime += other.totalGameTime;
        hasMorbidInfection ||= other.hasMorbidInfection;
    }

    protected function initStats () :void
    {
        mpGamesPlayed = ArrayUtil.create(Constants.TEAM_ARRANGEMENT_NAMES.length, 0);
        mpGamesWon = ArrayUtil.create(Constants.TEAM_ARRANGEMENT_NAMES.length, 0);
        resourcesGathered = ArrayUtil.create(Constants.RESOURCE__LIMIT, 0);
        spellsCast = ArrayUtil.create(Constants.CASTABLE_SPELL_TYPE__LIMIT, 0);
        creaturesCreated = ArrayUtil.create(Constants.UNIT_TYPE__PLAYER_CREATURE_LIMIT, 0);
        creaturesKilled = ArrayUtil.create(Constants.UNIT_TYPE__PLAYER_CREATURE_LIMIT, 0);
        creaturesLostToDaytime = ArrayUtil.create(Constants.UNIT_TYPE__PLAYER_CREATURE_LIMIT, 0);

        totalGameTime = 0;
        hasMorbidInfection = false;
    }

    protected static function sumInts (arr :Array) :int
    {
        var total :int;
        for each (var val :int in arr) {
            total += val;
        }

        return total;
    }

    protected static function readIntsFromCookie (arr :Array, cookie :ByteArray) :void
    {
        for (var i :int = 0; i < arr.length; ++i) {
            arr[i] = cookie.readInt();
        }
    }

    protected static function writeIntsToCookie (arr :Array, cookie :ByteArray) :void
    {
        for each (var val :int in arr) {
            cookie.writeInt(val);
        }
    }

    protected static function combineNumericArrays (into :Array, from :Array) :void
    {
        for (var i :int = 0; i < into.length; ++i) {
            into[i] += from[i];
        }
    }
}

}
