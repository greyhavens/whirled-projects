package popcraft {

import flash.utils.ByteArray;

public class PrizeManager
    implements UserCookieDataSource
{
    public function awardPremiumPrize () :void
    {
        if (!_premiumPrizeAwarded && AppContext.gameCtrl.isConnected()) {
            AppContext.gameCtrl.player.awardPrize(PREMIUM_PRIZE_IDENT);
            _premiumPrizeAwarded = true;
            AppContext.userCookieMgr.setNeedsUpdate();
        }
    }

    public function awardScorePrize () :void
    {
        if (!_scorePrizeAwarded && AppContext.gameCtrl.isConnected()) {
            AppContext.gameCtrl.player.awardPrize(SCORE_PRIZE_IDENT);
            _scorePrizeAwarded = true;
            AppContext.userCookieMgr.setNeedsUpdate();
        }
    }

    public function writeCookieData (cookie :ByteArray) :void
    {
        cookie.writeBoolean(_premiumPrizeAwarded);
        cookie.writeBoolean(_scorePrizeAwarded);
    }

    public function readCookieData (version :int, cookie :ByteArray) :void
    {
        _premiumPrizeAwarded = cookie.readBoolean();
        _scorePrizeAwarded = cookie.readBoolean();
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
        _premiumPrizeAwarded = false;
        _scorePrizeAwarded = false;
    }

    protected var _premiumPrizeAwarded :Boolean;
    protected var _scorePrizeAwarded :Boolean;

    protected static const PREMIUM_PRIZE_IDENT :String = "ladyfingers_avatar";
    protected static const SCORE_PRIZE_IDENT :String = "behemoth_avatar";
}

}
