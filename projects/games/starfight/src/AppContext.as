package {

import com.whirled.game.GameControl;

import flash.display.Sprite;

import client.GameView;

/**
 * Storage for globally-accessible data and managers.
 */
public class AppContext
{
    public static var game :GameManager;
    public static var gameCtrl :GameControl;
    public static var board :BoardController;

    // TEMP - to be removed post-refactor
    public static var mainSprite :Sprite;
    public static var gameView :GameView;
}

}
