package vampire.server
{
import com.whirled.avrg.AVRGameAvatar;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.contrib.simplegame.net.BasicMessageManager;

import vampire.Util;

public class ServerContext
{
    public static var msg :BasicMessageManager;
    public static var ctrl :AVRServerGameControl;
    public static var server :GameServer;
    public static var lineage :LineageServer;

    /** Highest ever score.  This is used to scale the coin payouts. */
    public static var topBloodBloomScore :Number = 1000;

    public static function init (gameCtrl :AVRServerGameControl) :void
    {
        ctrl = gameCtrl;
        msg = new BasicMessageManager();
        vampire.Util.initMessageManager(msg);
    }
}
}