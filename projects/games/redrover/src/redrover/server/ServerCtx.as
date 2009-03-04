package redrover.server {

import com.whirled.contrib.LevelPackManager;
import com.whirled.contrib.simplegame.resource.ResourceManager;
import com.whirled.game.GameControl;

import redrover.SeatingManager;

public class ServerCtx
{
    public static var gameCtrl :GameControl;
    public static var seatingMgr :SeatingManager = new SeatingManager();
    public static var rsrcs :ResourceManager = new ResourceManager();
    public static var levelPacks :LevelPackManager = new LevelPackManager();
}

}
