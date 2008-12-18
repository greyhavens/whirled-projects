package flashmob.server {

import com.whirled.avrg.*;

public class ServerContext
{
    public static var gameCtrl :AVRServerGameControl;

    public static function getPlayerRoom (playerId :int) :int
    {
        var ctrl :PlayerSubControlServer = gameCtrl.getPlayer(playerId);
        return (ctrl != null ? ctrl.getRoomId() : 0);
    }

    public static function getPlayerInfo (playerId :int) :PlayerInfo
    {
        var ctrl :PlayerSubControlServer = gameCtrl.getPlayer(playerId);
        return (ctrl != null ? ctrl.getPlayerInfo() : null);
    }
}

}
