package vampire.feeding {

import com.whirled.contrib.simplegame.net.MessageManager;

import vampire.feeding.net.*;

public class Util
{
    public static function initMessageManager (mgr :MessageManager) :void
    {
        mgr.addMessageType(CreateBonusMsg);
        mgr.addMessageType(CurrentScoreMsg);
    }
}

}
