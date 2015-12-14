package starfight {

import com.whirled.contrib.Scoreboard;
import com.whirled.game.GameControl;

import starfight.net.MessageManager;

/**
 * Storage for globally-accessible data and managers.
 */
public class AppContext
{
    public static var game :GameController;
    public static var gameCtrl :GameControl;
    public static var board :BoardController;
    public static var local :LocalUtility;
    public static var scores :Scoreboard;
    public static var msgs :MessageManager;
}

}
