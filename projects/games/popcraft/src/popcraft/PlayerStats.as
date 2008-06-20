package popcraft {

import com.threerings.util.ArrayUtil;

import flash.utils.ByteArray;

public class PlayerStats
    implements UserCookieDataSource
{
    public var gamesPlayed :Array;  // Array of ints, one for each multiplayer game type
    public var gamesWon :Array;     // ditto
    public var resourcesGathered :Array; // Array of ints, one for each resource type
    public var spellsCast :Array; // Array of ints, one for each spell type
    public var totalGameTime :Number;
    public var creaturesCreated :int;
    public var creaturesKilled :int;
    public var hasMorbidInfection :Boolean; // the viral trophy!

    public function PlayerStats ()
    {
        this.initStats();
    }

    public function get totalGamesPlayed () :int
    {
        return sumInts(gamesPlayed);
    }

    public function get totalGamesWon () :int
    {
        return sumInts(gamesWon);
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

    public function writeCookieData (cookie :ByteArray) :void
    {
        for each (var gamesPlayedOfType :int in gamesPlayed) {
            cookie.writeInt(gamesPlayedOfType);
        }

        for each (var gamesWonOfType :int in gamesWon) {
            cookie.writeInt(gamesWonOfType);
        }

        for each (var resAmount :int in resourcesGathered) {
            cookie.writeInt(resAmount);
        }

        for each (var spellAmount :int in spellsCast) {
            cookie.writeInt(spellAmount);
        }

        cookie.writeDouble(totalGameTime);
        cookie.writeInt(creaturesCreated);
        cookie.writeInt(creaturesKilled);
        cookie.writeBoolean(hasMorbidInfection);
    }

    public function readCookieData (cookie :ByteArray) :void
    {
        this.initStats();

        for (var i :int = 0; i < gamesPlayed.length; ++i) {
            gamesPlayed[i] = cookie.readInt();
        }

        for (i = 0; i < gamesWon.length; ++i) {
            gamesWon[i] = cookie.readInt();
        }

        for (i = 0; i < resourcesGathered.length; ++i) {
            resourcesGathered[i] = cookie.readInt();
        }

        for (i = 0; i < spellsCast.length; ++i) {
            spellsCast[i] = cookie.readInt();
        }

        totalGameTime = cookie.readDouble();
        creaturesCreated = cookie.readInt();
        creaturesKilled = cookie.readInt();
        hasMorbidInfection = cookie.readBoolean();
    }

    public function readFailed () :Boolean
    {
        this.initStats();
        return true;
    }

    protected function initStats () :void
    {
        gamesPlayed = ArrayUtil.create(Constants.TEAM_ARRANGEMENT_NAMES.length, 0);
        gamesWon = ArrayUtil.create(Constants.TEAM_ARRANGEMENT_NAMES.length, 0);
        resourcesGathered = ArrayUtil.create(Constants.RESOURCE__LIMIT, 0);
        spellsCast = ArrayUtil.create(Constants.SPELL_TYPE__LIMIT, 0);
        totalGameTime = 0;
        creaturesCreated = 0;
        creaturesKilled = 0;
        hasMorbidInfection = true;
    }

    protected static function sumInts (arr :Array) :int
    {
        var total :int;
        for each (var thisAmount :int in arr) {
            total += thisAmount;
        }

        return total;
    }
}

}
