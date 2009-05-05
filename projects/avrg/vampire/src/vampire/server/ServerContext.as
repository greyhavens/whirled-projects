package vampire.server
{
import com.threerings.util.Log;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.contrib.simplegame.net.BasicMessageManager;
import com.whirled.contrib.simplegame.net.MessageManager;

import vampire.Util;
import vampire.data.VConstants;
import vampire.server.feeding.FeedingManager;

public class ServerContext
{
    public static var msg :MessageManager;
    public static var ctrl :AVRServerGameControl;
    public static var server :GameServer;

    public static var lineage :LineageServer;
    public static var feedback :Feedback;
    public static var feedingManager :FeedingManager;

    public static function init (gameCtrl :AVRServerGameControl) :void
    {
        ctrl = gameCtrl;
        msg = new BasicMessageManager();
        vampire.Util.initMessageManager(msg);

        if (VConstants.LOCAL_DEBUG_MODE || VConstants.MODE_DEV) {
            Log.setLevel("", Log.DEBUG);
        }
        else {
            Log.setLevel("", Log.ERROR);
        }



    }
}
}