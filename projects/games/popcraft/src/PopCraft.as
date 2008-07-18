//
// $Id$

package {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.audio.AudioManager;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.util.Rand;
import com.whirled.game.GameControl;
import com.whirled.game.SizeChangedEvent;

import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;

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
        AppContext.mainSprite = this;

        // setup GameControl
        AppContext.gameCtrl = new GameControl(this, false);
        var isConnected :Boolean = AppContext.gameCtrl.isConnected();
        var multiplayer :Boolean = isConnected && (AppContext.gameCtrl.game.seating.getPlayerIds().length > 1);

        SeatingManager.init();

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
        AppContext.globalPlayerStats = new PlayerStats();

        // init the cookie manager
        UserCookieManager.addDataSource(AppContext.levelMgr);
        UserCookieManager.addDataSource(AppContext.globalPlayerStats);

        if (multiplayer) {
            GameContext.gameType = GameContext.GAME_TYPE_MULTIPLAYER;
            AppContext.mainLoop.pushMode(new GameLobbyMode());
        } else {
            GameContext.gameType = GameContext.GAME_TYPE_SINGLEPLAYER;
            AppContext.mainLoop.pushMode(new LevelSelectMode());
        }

        // if we're connected to Whirled, keep the game centered and draw a pretty
        // tiled background behind it
        if (AppContext.gameCtrl.isConnected()) {
            AppContext.gameCtrl.local.addEventListener(SizeChangedEvent.SIZE_CHANGED, handleSizeChanged);
            this.handleSizeChanged();
        }

        // LoadingMode will pop itself from the stack when loading is complete
        AppContext.mainLoop.run();
        AppContext.mainLoop.pushMode(new LoadingMode());
    }

    protected function handleSizeChanged (...ignored) :void
    {
        var size :Point = AppContext.gameCtrl.local.getSize();
        AppContext.mainSprite.x = (size.x * 0.5) - (Constants.SCREEN_SIZE.x * 0.5);
        AppContext.mainSprite.y = (size.y * 0.5) - (Constants.SCREEN_SIZE.y * 0.5);
    }

    protected function handleUnload (...ignored) :void
    {
        if (AppContext.gameCtrl.isConnected()) {
            AppContext.gameCtrl.local.removeEventListener(SizeChangedEvent.SIZE_CHANGED, handleSizeChanged);
        }

        AppContext.mainLoop.shutdown();
    }
}

}
