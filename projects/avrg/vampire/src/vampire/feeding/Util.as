package vampire.feeding {

import com.whirled.contrib.simplegame.net.MessageManager;

import vampire.feeding.net.*;

public class Util
{
    public static function initMessageManager (mgr :MessageManager) :void
    {
        mgr.addMessageType(CreateBonusMsg);
        mgr.addMessageType(CurrentScoreMsg);
        mgr.addMessageType(ClientReadyMsg);
        mgr.addMessageType(StartRoundMsg);
        mgr.addMessageType(RoundOverMsg);
        mgr.addMessageType(RoundScoreMsg);
        mgr.addMessageType(GameEndedMsg);
        mgr.addMessageType(RoundResultsMsg);
        mgr.addMessageType(ClientQuitMsg);
        mgr.addMessageType(NoMoreFeedingMsg);
        mgr.addMessageType(ClientBootedMsg);
    }
}

}
