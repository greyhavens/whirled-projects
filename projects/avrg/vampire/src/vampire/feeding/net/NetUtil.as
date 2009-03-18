package vampire.feeding.net {

import com.whirled.contrib.simplegame.net.MessageManager;

import vampire.feeding.net.*;

public class NetUtil
{
    public static function initMessageManager (mgr :MessageManager) :void
    {
        mgr.addMessageType(CreateMultiplierMsg);
        mgr.addMessageType(ClientReadyMsg);
        mgr.addMessageType(GetRoundScores);
        mgr.addMessageType(RoundScoreMsg);
        mgr.addMessageType(GameEndedMsg);
        mgr.addMessageType(RoundOverMsg);
        mgr.addMessageType(ClientQuitMsg);
        mgr.addMessageType(NoMoreFeedingMsg);
        mgr.addMessageType(ClientBootedMsg);
        mgr.addMessageType(RoundStartingSoonMsg);
        mgr.addMessageType(AwardTrophyMsg);
        mgr.addMessageType(CloseLobbyMsg);
    }
}

}
