//
// $Id$

package popcraft {

import com.threerings.util.Log;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.audio.AudioManager;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.util.Rand;
import com.whirled.game.GameContentEvent;
import com.whirled.game.GameControl;
import com.whirled.game.SizeChangedEvent;

import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;

import popcraft.data.*;
import popcraft.game.mpbattle.*;
import popcraft.net.*;
import popcraft.game.*;
import popcraft.game.story.*;
import popcraft.ui.*;
import popcraft.util.*;

[SWF(width="700", height="500", frameRate="30")]
public class PopCraft extends Sprite
{
    public static var log :Log = Log.getLog(PopCraft);

    public function PopCraft ()
    {
        AppContext.mainSprite = this;

        // setup GameControl
        AppContext.gameCtrl = new GameControl(this, false);
        var isConnected :Boolean = AppContext.gameCtrl.isConnected();

        SeatingManager.init();

        _events.registerListener(this, Event.REMOVED_FROM_STAGE, handleUnload);

        // draw a black background
        var g :Graphics = this.graphics;
        g.beginFill(0);
        g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
        g.endFill();

        // set a clip rect
        this.scrollRect = new Rectangle(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);

        // setup main loop
        AppContext.mainLoop = new MainLoop(this,
            (isConnected ? AppContext.gameCtrl.local : this.stage));
        AppContext.mainLoop.setup();

        // custom resource factories
        var rm :ResourceManager = ResourceManager.instance;
        rm.registerResourceType(Constants.RESTYPE_LEVEL, LevelResource);
        rm.registerResourceType(Constants.RESTYPE_ENDLESS, EndlessLevelResource);
        rm.registerResourceType(Constants.RESTYPE_GAMEDATA, GameDataResource);
        rm.registerResourceType(Constants.RESTYPE_GAMEVARIANTS, GameVariantsResource);

        // sound volume
        AudioManager.instance.masterControls.volume(
            Constants.DEBUG_DISABLE_AUDIO ? 0 : Constants.SOUND_MASTER_VOLUME);

        // create a new random stream for the puzzle
        AppContext.randStreamPuzzle = Rand.addStream();

        // init the cookie manager
        AppContext.userCookieMgr = new UserCookieManager(Constants.USER_COOKIE_VERSION);
        AppContext.userCookieMgr.addDataSource(AppContext.levelMgr);
        AppContext.userCookieMgr.addDataSource(AppContext.globalPlayerStats);
        AppContext.userCookieMgr.addDataSource(AppContext.endlessLevelMgr);
        AppContext.userCookieMgr.addDataSource(AppContext.prizeMgr);
        AppContext.userCookieMgr.addDataSource(AppContext.savedPlayerBits);

        if (AppContext.gameCtrl.isConnected()) {
            // if we're connected to Whirled, keep the game centered and draw a pretty
            // tiled background behind it
            _events.registerListener(AppContext.gameCtrl.local, SizeChangedEvent.SIZE_CHANGED,
                handleSizeChanged)

            handleSizeChanged();

            // and don't show the "rematch" button - we have a UI for it in-game
            AppContext.gameCtrl.local.setShowReplay(false);

            // get level packs
            AppContext.reloadLevelPacks();

            // if the player purchases level packs while the game is in progress, update our
            // level packs
            _events.registerListener(
                AppContext.gameCtrl.player,
                GameContentEvent.PLAYER_CONTENT_ADDED,
                function (...ignored) :void {
                    AppContext.reloadLevelPacks();
                });

        }

        AppContext.mainLoop.run();
        AppContext.mainLoop.pushMode(new LoadingMode(this));
    }

    protected function handleSizeChanged (...ignored) :void
    {
        var size :Point = AppContext.gameCtrl.local.getSize();
        AppContext.mainSprite.x = (size.x * 0.5) - (Constants.SCREEN_SIZE.x * 0.5);
        AppContext.mainSprite.y = (size.y * 0.5) - (Constants.SCREEN_SIZE.y * 0.5);
    }

    protected function handleUnload (...ignored) :void
    {
        _events.freeAllHandlers();
        AppContext.mainLoop.shutdown();
    }

    public function loadResources (completeCallback :Function, errorCallback :Function) :void
    {
        function loadSingleOrMultiplayerResources () :void {
            if (Resources.queueLevelPackResources(AppContext.isMultiplayer ?
                Resources.MP_LEVEL_PACK_RESOURCES :
                Resources.SP_LEVEL_PACK_RESOURCES)) {
                ResourceManager.instance.loadQueuedResources(completeCallback, errorCallback);

            } else {
                completeCallback();
            }
        }

        Resources.loadBaseResources(loadSingleOrMultiplayerResources, errorCallback);
    }

    protected var _events :EventHandlerManager = new EventHandlerManager();
}

}

import popcraft.*;
import popcraft.game.*;
import popcraft.ui.GenericLoadingMode;

import com.whirled.contrib.simplegame.resource.ResourceManager;
import popcraft.ui.GenericLoadErrorMode;
import popcraft.game.story.LevelSelectMode;
import popcraft.game.mpbattle.MultiplayerLobbyMode;
import com.whirled.contrib.simplegame.util.Rand;
import popcraft.game.endless.SavedEndlessGame;

class LoadingMode extends GenericLoadingMode
{
    public function LoadingMode (mainSprite :PopCraft)
    {
        _mainSprite = mainSprite;
    }

    override protected function setup () :void
    {
        _loadingResources = true;
        AppContext.userCookieMgr.readCookie();
        _mainSprite.loadResources(resourceLoadComplete, onLoadError);
    }

    override public function update (dt :Number) :void
    {
        super.update(dt);
        if (!_loadingResources && !AppContext.userCookieMgr.isLoadingCookie) {
            if (SeatingManager.allPlayersPresent) {
                startGame();
            } else {
                this.loadingText = "Waiting for players";
            }
        }
    }

    protected function startGame () :void
    {
        if (AppContext.isMultiplayer) {
            AppContext.mainLoop.unwindToMode(new MultiplayerLobbyMode());
        } else {
            LevelSelectMode.create();
        }

        // award the player any prizes they haven't gotten yet
        AppContext.prizeMgr.checkPrizes();
    }

    protected function resourceLoadComplete () :void
    {
        _loadingResources = false;
    }

    protected function onLoadError (err :String) :void
    {
        AppContext.mainLoop.unwindToMode(new GenericLoadErrorMode(err));
    }

    protected var _mainSprite :PopCraft;
    protected var _loadingResources :Boolean;
}
