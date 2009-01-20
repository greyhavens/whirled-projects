package joingame {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.game.GameControl;

import joingame.net.JoinMessageManager;

public class AppContext
{
    
    public static var gameCtrl :GameControl;
    public static var randStreamPuzzle :uint;
    
    public static var localServer :JoingameServer;
    public static var messageManager :JoinMessageManager;
    
    public static var playerId :int;
    
    public static var isConnected :Boolean;
    
    public static var useServerAgent :Boolean;
    
    public static var isMultiplayer :Boolean;
    
    public static function get isSinglePlayer() :Boolean
    {
        return !isMultiplayer;
    }
    
    public static var isObserver :Boolean;
    public static var gameHeight :int = 500;
    public static var gameWidth :int = 700;
    public static var beginToShowInstructionsTime :int = 0;
    public static var database :Database = new Database();
    
    public static var singlePlayerCookie :UserCookieDataSourcePlayer;
}

}
