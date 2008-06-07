//
// $Id$

package {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.audio.AudioManager;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.util.Rand;
import com.whirled.game.GameControl;

import flash.display.Sprite;
import flash.events.Event;

import popcraft.*;
import popcraft.data.*;
import popcraft.net.*;
import popcraft.sp.*;
import popcraft.util.*;

[SWF(width="700", height="500", frameRate="30")]
public class PopCraft extends Sprite
{
    public function PopCraft ()
    {
        // setup GameControl
        AppContext.gameCtrl = new GameControl(this, false);
        var isConnected :Boolean = AppContext.gameCtrl.isConnected();
        var multiplayer :Boolean = isConnected && (AppContext.gameCtrl.game.seating.getPlayerIds().length > 1);

        this.graphics.beginFill(0);
        this.graphics.drawRect(0, 0, 700, 500);
        this.graphics.endFill();

        this.addEventListener(Event.REMOVED_FROM_STAGE, handleUnload);

        // setup main loop
        AppContext.mainLoop = new MainLoop(this, (isConnected ? AppContext.gameCtrl.local : this.stage));
        AppContext.mainLoop.setup();

        // custom resource factories
        ResourceManager.instance.registerResourceType("level", LevelResource);
        ResourceManager.instance.registerResourceType("gameData", GameDataResource);
        ResourceManager.instance.registerResourceType("gameVariants", GameVariantsResource);

        // sound volume
        AudioManager.instance.masterControls.volume(Constants.SOUND_MASTER_VOLUME);

        // create a new random stream for the puzzle
        AppContext.randStreamPuzzle = Rand.addStream();

        // init other managers
        AppContext.levelMgr = new LevelManager();

        // init the cookie manager and read cookie data
        AppContext.cookieMgr = new UserCookieManager();
        AppContext.cookieMgr.addDataSource(AppContext.levelMgr);
        AppContext.cookieMgr.readCookie();

        if (multiplayer) {
            GameContext.gameType = GameContext.GAME_TYPE_MULTIPLAYER;

            // show the team-selection screen if > 2 players are playing
            if (AppContext.gameCtrl.game.seating.getPlayerIds().length > 2) {
                AppContext.mainLoop.pushMode(new GameLobbyMode());
            } else {
                AppContext.mainLoop.pushMode(new GameMode());
            }

        } else {
            AppContext.mainLoop.pushMode(new LevelSelectMode());
        }

        // kick off the MainLoop
        // LoadingMode will pop itself from the stack when loading is complete
        AppContext.mainLoop.run();
        AppContext.mainLoop.pushMode(new LoadingMode());
    }

    protected function handleUnload (...ignored) :void
    {
        AppContext.mainLoop.shutdown();
    }
}

}
