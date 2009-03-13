package vampire.server
{
import com.whirled.avrg.AVRGameAvatar;
import com.whirled.avrg.AVRServerGameControl;

import vampire.data.LineageServer;
import vampire.net.VMessageManager;

public class ServerContext
{
    public static var msg :VMessageManager;
    public static var ctrl :AVRServerGameControl;
    public static var vserver :VServer;
    public static var lineage :LineageServer;
    public static var nonPlayersBloodMonitor :NonPlayerAvatarsBloodMonitor;
    public static var trophies :Trophies;
    public static var time :Number;

    /** Highest ever score.  This is used to scale the coin payouts. */
    public static var topBloodBloomScore :Number = 200;

    public static var serverLogBroadcast: AVRGAgentLogTarget;

    public static function getPlayerName( playerId :int) :String
    {
        var player :Player = vserver.getPlayer(playerId);

        if( player == null || player.room == null) {
            return "Player " + playerId;
        }
        var avatar :AVRGameAvatar = player.room.ctrl.getAvatarInfo( playerId );
        if( avatar == null ) {
            return "Player " + playerId;
        }
        return avatar.name;
    }


    public static function trace2( msg :String ) :void
    {
        serverLogBroadcast.log( msg );
    }


}
}