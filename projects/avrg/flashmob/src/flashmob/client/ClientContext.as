package flashmob.client {

import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.simplegame.MainLoop;

public class ClientContext
{
    public static var mainLoop :MainLoop;
    public static var gameCtrl :AVRGameControl;
    public static var localPlayerId :int;

    public static function get isLocalPlayerPartied () :Boolean
    {
        return (gameCtrl.isConnected() && gameCtrl.game.getPlayerInfo(localPlayerId).partyId != 0);
    }

    public static function quit () :void
    {
        if (gameCtrl.isConnected()) {
            gameCtrl.player.deactivateGame();
        }
    }
}

}
