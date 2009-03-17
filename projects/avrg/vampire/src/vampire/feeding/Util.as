package vampire.feeding {

import com.whirled.contrib.simplegame.net.MessageManager;

import vampire.feeding.net.*;

public class Util
{
    public static function initMessageManager (mgr :MessageManager) :void
    {
        mgr.addMessageType(CreateMultiplierMsg);
        mgr.addMessageType(ClientReadyMsg);
        mgr.addMessageType(StartRoundMsg);
        mgr.addMessageType(GetRoundScores);
        mgr.addMessageType(RoundScoreMsg);
        mgr.addMessageType(GameEndedMsg);
        mgr.addMessageType(RoundOverMsg);
        mgr.addMessageType(ClientQuitMsg);
        mgr.addMessageType(NoMoreFeedingMsg);
        mgr.addMessageType(ClientBootedMsg);
        mgr.addMessageType(RoundStartingSoonMsg);
        mgr.addMessageType(PlayerLeftMsg);
        mgr.addMessageType(StartGameMsg);
        mgr.addMessageType(AwardTrophyMsg);
    }
}

}
