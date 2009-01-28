package popcraft {

import com.threerings.util.ArrayUtil;
import com.threerings.util.HashMap;

import flash.utils.ByteArray;

public class PrizeManager
    implements UserCookieDataSource
{
    public static const LADYFINGERS :int = 0;   // buy the game
    public static const BEHEMOTH :int = 1;      // get the "Magna Cum Laude" trophy
    public static const JACK :int = 2;          // get the "Admired" trophy
    public static const RALPH :int = 3;         // get the "Head of the Class" trophy
    public static const IVY :int = 4;           // get the "Collaborator" trophy

    public function PrizeManager ()
    {
        _trophyPrizeMap = new HashMap();
        for (var ii :int = 0; ii < TROPHY_PRIZES.length; ii += 2) {
            var trophyName :String = TROPHY_PRIZES[ii];
            var prizeId :int = TROPHY_PRIZES[ii + 1];
            _trophyPrizeMap.put(trophyName, prizeId);
        }

        init();
    }

    public function checkPrizes () :void
    {
        var prizes :Array = [];

        if (ClientCtx.hasCompleatLevelPack) {
            prizes.push(LADYFINGERS);
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
        var prizeIdObj :* = _trophyPrizeMap.get(trophyName);
        if (prizeIdObj !== undefined) {
            awardPrize(int(prizeIdObj));
        }
    }

    public function awardPrize (prizeId :int) :void
    {
        awardPrizes([ prizeId ]);
    }

    public function awardPrizes (prizeIds :Array) :void
    {
        if (!ClientCtx.hasCompleatLevelPack || !ClientCtx.gameCtrl.isConnected()) {
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

    protected static const PRIZE_IDENTS :Array = [
        "ladyfingers_avatar",
        "behemoth_avatar",
        "jack_avatar",
        "ralph_avatar",
        "ivy_avatar",
    ];

    protected static const TROPHY_PRIZES :Array = [
        Trophies.MAGNACUMLAUDE,                     BEHEMOTH,
        Trophies.ENDLESS_COMPLETION_TROPHIES[2],    JACK,
        Trophies.HEAD_OF_THE_CLASS,                 RALPH,
        Trophies.COLLABORATOR,                      IVY,
    ];
}

}
