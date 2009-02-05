package vampire.server
{
import com.whirled.avrg.AVRGameAvatar;
import com.whirled.avrg.AVRServerGameControl;

import vampire.data.MinionHierarchy;
import vampire.net.MessageManager;
    
public class ServerContext
{
    public static var msg :MessageManager;
    public static var ctrl :AVRServerGameControl;
    
    public static var minionHierarchy :MinionHierarchy = new MinionHierarchy();
    
    public static var nonPlayers :NonPlayerAvatars = new NonPlayerAvatars();
    
    public static var _serverLogBroadcast: AVRGAgentLogTarget;
    
    public static function getPlayerName( playerId :int) :String
    {
        var player :Player = VServer.getPlayer(playerId);
        
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
        _serverLogBroadcast.log( msg );
    }
    

}
}