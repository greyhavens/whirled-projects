package vampire.feeding {

import com.whirled.contrib.messagemgr.MessageManager;

import flash.utils.Dictionary;

import vampire.feeding.net.*;

public class FeedingUtil
{
    public static function initMessageManager (mgr :MessageManager) :void
    {
        mgr.addMessageType(CreateMultiplierMsg);
        mgr.addMessageType(GetRoundScores);
        mgr.addMessageType(RoundScoreMsg);
        mgr.addMessageType(GameEndedMsg);
        mgr.addMessageType(RoundOverMsg);
        mgr.addMessageType(ClientQuitMsg);
        mgr.addMessageType(ClientBootedMsg);
        mgr.addMessageType(RoundStartingSoonMsg);
        mgr.addMessageType(AwardTrophyMsg);
        mgr.addMessageType(CloseLobbyMsg);
        mgr.addMessageType(RoundTimeLeftMsg);
    }

    public static function arrayToDict (arr :Array) :Dictionary
    {
        var dict :Dictionary = new Dictionary();
        for each (var obj :* in arr) {
            dict[obj] = false;
        }

        return dict;
    }
}

}
