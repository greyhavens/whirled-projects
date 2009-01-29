package popcraft {

import com.threerings.util.ArrayUtil;
import com.threerings.util.HashMap;

import flash.utils.ByteArray;

public class PrizeManager
    implements UserCookieDataSource
{
    public function PrizeManager ()
    {
        _trophyPrizeMap = new HashMap();
        for (var ii :int = 0; ii < TROPHY_PRIZES.length; ii += 3) {
            var trophyPrize :TrophyPrize = new TrophyPrize(
                TROPHY_PRIZES[ii],
                TROPHY_PRIZES[ii + 1],
                TROPHY_PRIZES[ii + 2]);
            _trophyPrizeMap.put(trophyPrize.trophyName, trophyPrize);
        }

        init();
    }

    public function checkPrizes () :void
    {
        var prizes :Array = [];

        if (ClientCtx.hasCompleatLevelPack || ClientCtx.hasAcademyLevelPack) {
            prizes.push(LADYFINGERS);
        }

        if (ClientCtx.hasCompleatLevelPack) {
            prizes.push(ACADEMY);
        }

        for (var ii :int = 0; ii < TROPHY_PRIZES.length; ii += 2) {
            var trophyName :String = TROPHY_PRIZES[ii];
            var prizeId :int = TROPHY_PRIZES[ii + 1];
            if (ClientCtx.hasTrophy(trophyName)) {
                prizes.push(prizeId);
            }
        }

        if (prizes.length > 0) {
            awardPrizes(prizes);
        }
    }

    public function awardPrizeForTrophy (trophyName :String) :void
    {
        var trophyPrize :TrophyPrize = _trophyPrizeMap.get(trophyName);
        if (trophyPrize != null && trophyPrize.playerHasRequiredLevelPack) {
            awardPrize(trophyPrize.prizeId);
        }
    }

    public function awardPrize (prizeId :int) :void
    {
        awardPrizes([ prizeId ]);
    }

    public function awardPrizes (prizeIds :Array) :void
    {
        if (!ClientCtx.gameCtrl.isConnected()) {
            return;
        }

        var prizeAwarded :Boolean;
        for each (var prizeId :int in prizeIds) {
            if (!_prizesAwarded[prizeId]) {
                ClientCtx.gameCtrl.player.awardPrize(PRIZE_IDENTS[prizeId])
                _prizesAwarded[prizeId] = true;
                prizeAwarded = true;
            }
        }

        if (prizeAwarded) {
            ClientCtx.userCookieMgr.needsUpdate();
        }
    }

    public function writeCookieData (cookie :ByteArray) :void
    {
        cookie.writeInt(_prizesAwarded.length);
        for each (var prizeAwarded :Boolean in _prizesAwarded) {
            cookie.writeBoolean(prizeAwarded);
        }
    }

    public function readCookieData (version :int, cookie :ByteArray) :void
    {
        init();

        var numEntries :int = cookie.readInt();
        for (var ii :int = 0; ii < numEntries; ++ii) {
            var prizeAwarded :Boolean = cookie.readBoolean();
            if (ii < _prizesAwarded.length) {
                _prizesAwarded[ii] = prizeAwarded;
            }
        }
    }

    public function get minCookieVersion () :int
    {
        return 1;
    }

    public function cookieReadFailed () :Boolean
    {
        init();
        return true;
    }

    protected function init () :void
    {
        _prizesAwarded = ArrayUtil.create(PRIZE_IDENTS.length, false);
    }

    protected var _prizesAwarded :Array;
    protected var _behemothAwarded :Boolean;
    protected var _jackAwarded :Boolean;
    protected var _ralphAwarded :Boolean;
    protected var _ivyAwarded :Boolean;
    protected var _trophyPrizeMap :HashMap;

    // Cookie version >= 1
    protected static const LADYFINGERS :int = 0;   // buy Compleat or Weardd Academy
    protected static const BEHEMOTH :int = 1;      // get the "Magna Cum Laude" trophy
    protected static const JACK :int = 2;          // get the "Admired" trophy
    protected static const RALPH :int = 3;         // get the "Head of the Class" trophy
    protected static const IVY :int = 4;           // get the "Collaborator" trophy
    // Cookie version >= 3
    protected static const ACADEMY :int = 5;       // buy Compleat

    protected static const PRIZE_IDENTS :Array = [
        "ladyfingers_avatar",
        "behemoth_avatar",
        "jack_avatar",
        "ralph_avatar",
        "ivy_avatar",
        "academy_furni",
    ];

    protected static const TROPHY_PRIZES :Array = [
        Trophies.MAGNACUMLAUDE,
        BEHEMOTH,
        [ Constants.COMPLEAT_LEVEL_PACK_NAME, Constants.INCIDENT_LEVEL_PACK_NAME ],

        Trophies.ENDLESS_COMPLETION_TROPHIES[2],
        JACK,
        [ Constants.COMPLEAT_LEVEL_PACK_NAME, Constants.ACADEMY_LEVEL_PACK_NAME ],

        Trophies.HEAD_OF_THE_CLASS,
        RALPH,
        [ Constants.COMPLEAT_LEVEL_PACK_NAME, Constants.ACADEMY_LEVEL_PACK_NAME ],

        Trophies.COLLABORATOR,
        IVY,
        [ Constants.COMPLEAT_LEVEL_PACK_NAME, Constants.ACADEMY_LEVEL_PACK_NAME ],
    ];
}

}

import popcraft.*;

class TrophyPrize
{
    public var trophyName :String;
    public var prizeId :int;
    public var requiredLevelPacks :Array;

    public function TrophyPrize (trophyName :String, prizeId :int, requiredLevelPacks :Array)
    {
        this.trophyName = trophyName;
        this.prizeId = prizeId;
        this.requiredLevelPacks = requiredLevelPacks;
    }

    public function get playerHasRequiredLevelPack () :Boolean
    {
        if (requiredLevelPacks == null || requiredLevelPacks.length == 0) {
            return true;
        }

        for each (var packName :String in requiredLevelPacks) {
            if (ClientCtx.playerLevelPacks.isLevelPack(packName)) {
                return true;
            }
        }

        return false;
    }
}
