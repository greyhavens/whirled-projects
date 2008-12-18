package flashmob.server {

import com.whirled.avrg.*;

import flash.utils.getTimer;

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

    public static function getAvatarInfo (playerId :int) :AVRGameAvatar
    {
        return gameCtrl.getRoom(getPlayerRoom(playerId)).getAvatarInfo(playerId);
    }

    public static function get timeNow () :Number
    {
        return flash.utils.getTimer() / 1000;
    }
}

}
