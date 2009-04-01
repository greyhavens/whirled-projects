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
//    public static var npBlood :NonPlayerAvatarsBloodMonitor;
    public static var trophies :Trophies;
    public static var time :Number;

    /** Highest ever score.  This is used to scale the coin payouts. */
    public static var topBloodBloomScore :Number = 200;

    public static var serverLogBroadcast: AVRGAgentLogTarget;

    public static function getPlayerName(playerId :int) :String
    {
        var player :PlayerData = server.getPlayer(playerId);

        if(player == null || player.room == null) {
            return "Player " + playerId;
        }
        var avatar :AVRGameAvatar = player.room.ctrl.getAvatarInfo(playerId);
        if(avatar == null) {
            return "Player " + playerId;
        }
        return avatar.name;
    }


    public static function trace2(msg :String) :void
    {
        serverLogBroadcast.log(msg);
    }

    public static function init (gameCtrl :AVRServerGameControl) :void
    {
        ctrl = gameCtrl;
        msg = new BasicMessageManager();
        vampire.Util.initMessageManager(msg);
    }


}
}