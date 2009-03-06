package redrover.server {

import com.whirled.game.GameControl;

import redrover.SeatingManager;
import redrover.net.GameMessageMgr;
import redrover.net.WhirledBridge;

public class ServerCtx
{
    public static var gameCtrl :GameControl;
    public static var bridge :WhirledBridge;
    public static var msgMgr :GameMessageMgr;
    public static var seatingMgr :SeatingManager = new SeatingManager();
    public static var levels :Array = [];
}

}
