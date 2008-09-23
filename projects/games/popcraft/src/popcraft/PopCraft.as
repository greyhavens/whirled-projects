//
// $Id$

package popcraft {

import com.whirled.contrib.LevelPacks;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.audio.AudioManager;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.util.Rand;
import com.whirled.game.GameControl;
import com.whirled.game.SizeChangedEvent;

import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;

import popcraft.data.*;
import popcraft.net.*;
import popcraft.sp.*;
import popcraft.sp.story.*;
import popcraft.ui.*;
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

        SeatingManager.init();

        this.graphics.beginFill(0);
        this.graphics.drawRect(0, 0, 700, 500);
        this.graphics.endFill();

        this.addEventListener(Event.REMOVED_FROM_STAGE, handleUnload);

        // set a clip rect
        this.scrollRect = new Rectangle(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);

        // setup main loop
        AppContext.mainLoop = new MainLoop(this,
            (isConnected ? AppContext.gameCtrl.local : this.stage));
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

        if (AppContext.gameCtrl.isConnected()) {
            // if we're connected to Whirled, keep the game centered and draw a pretty
            // tiled background behind it
            AppContext.gameCtrl.local.addEventListener(SizeChangedEvent.SIZE_CHANGED,
                handleSizeChanged);
            this.handleSizeChanged();

            // and don't show the "rematch" button - we have a UI for it in-game
            AppContext.gameCtrl.local.setShowReplay(false);

            // get level packs
            LevelPacks.init(AppContext.gameCtrl.game.getLevelPacks());
        }

        AppContext.mainLoop.pushMode(new LoadingMode());
        AppContext.mainLoop.run();
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
            AppContext.gameCtrl.local.removeEventListener(SizeChangedEvent.SIZE_CHANGED,
                handleSizeChanged);
        }

        AppContext.mainLoop.shutdown();
    }
}

}

import popcraft.*;
import popcraft.ui.GenericLoadingMode;

import com.whirled.contrib.simplegame.resource.ResourceManager;
import popcraft.ui.GenericLoadErrorMode;
import popcraft.sp.story.LevelSelectMode;

class LoadingMode extends GenericLoadingMode
{
    public function LoadingMode ()
    {
        _loadingResources = true;
        UserCookieManager.readCookie();
        Resources.loadBaseResources(loadSingleOrMultiplayerResources, onLoadError);
    }

    protected function loadSingleOrMultiplayerResources () :void
    {
        if (Resources.pendLoadLevelPackResources(AppContext.isMultiplayer ?
            multiplayerLevelPackResources :
            singleplayerLevelPackResources)) {
            ResourceManager.instance.load(resourceLoadComplete, onLoadError);
        }
    }

    override public function update (dt :Number) :void
    {
        super.update(dt);
        if (!_loadingResources && !UserCookieManager.isLoadingCookie) {
            if (SeatingManager.allPlayersPresent) {
                startGame();
            } else {
                this.loadingText = "Waiting for players...";
            }
        }
    }

    protected function startGame () :void
    {
        if (AppContext.isMultiplayer) {
            GameContext.matchType = GameContext.MATCH_TYPE_MULTIPLAYER;
            AppContext.mainLoop.unwindToMode(new GameLobbyMode());
        } else {
            GameContext.matchType = GameContext.MATCH_TYPE_SINGLEPLAYER;
            AppContext.mainLoop.unwindToMode(new LevelSelectMode());
        }
    }

    protected function resourceLoadComplete () :void
    {
        _loadingResources = false;
    }

    protected function onLoadError (err :String) :void
    {
        AppContext.mainLoop.unwindToMode(new GenericLoadErrorMode(err));
    }

    protected var _loadingResources :Boolean;

    protected static const multiplayerLevelPackResources :Array = [
        "multiplayer",
        "zombieBg",
    ];

    protected static const singleplayerLevelPackResources :Array = [
        "prologue",
        "epilogue",
        "manual",
        "boss",
        "levelSelectOverlay",
        "levelSelectUi",
        "portrait_iris",
        "portrait_ivy",
        "portrait_jack",
        "portrait_pigsley",
        "portrait_ralph",
        "portrait_weardd",
    ];
}
