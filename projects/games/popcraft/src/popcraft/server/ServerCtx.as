package popcraft.server {

import com.whirled.game.GameControl;

import popcraft.LobbyConfig;
import popcraft.SeatingManager;

public class ServerCtx
{
    public static var gameCtrl :GameControl;
    public static var seatingMgr :SeatingManager = new SeatingManager();
    public static var lobbyConfig :LobbyConfig = new LobbyConfig();
}

}
