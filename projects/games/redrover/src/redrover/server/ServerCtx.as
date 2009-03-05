package redrover.server {

import com.whirled.contrib.simplegame.net.BasicMessageManager;
import com.whirled.game.GameControl;

import redrover.SeatingManager;

public class ServerCtx
{
    public static var gameCtrl :GameControl;
    public static var seatingMgr :SeatingManager = new SeatingManager();
    public static var levels :Array = [];
}

}
