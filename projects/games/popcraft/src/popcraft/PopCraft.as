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
import popcraft.game.*;
import popcraft.game.mpbattle.*;
import popcraft.game.story.*;
import popcraft.net.*;
import popcraft.server.Server;
import popcraft.ui.*;
import popcraft.util.*;

[SWF(width="700", height="500", frameRate="30")]
public class PopCraft extends Sprite
{
    public static var log :Log = Log.getLog(PopCraft);

    protected static function DEBUG_REMOVE_ME () :void
    {
        var c :Class = Server;
    }

    public function PopCraft ()
    {
        DEBUG_REMOVE_ME(); //

        ClientContext.mainSprite = this;

        // setup GameControl
        ClientContext.gameCtrl = new GameControl(this, false);
        var isConnected :Boolean = ClientContext.gameCtrl.isConnected();

        ClientContext.seatingMgr.init(ClientContext.gameCtrl);
        ClientContext.lobbyConfig.init(ClientContext.gameCtrl, ClientContext.seatingMgr);

        _events.registerListener(this, Event.REMOVED_FROM_STAGE, handleUnload);

        // draw a black background
        var g :Graphics = this.graphics;
        g.beginFill(0);
        g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
        g.endFill();

        // set a clip rect
        this.scrollRect = new Rectangle(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);

        // setup main loop
        ClientContext.mainLoop = new MainLoop(this,
            (isConnected ? ClientContext.gameCtrl.local : this.stage));
        ClientContext.mainLoop.setup();

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
        ClientContext.randStreamPuzzle = Rand.addStream();

        // init the cookie manager
        ClientContext.userCookieMgr = new UserCookieManager(Constants.USER_COOKIE_VERSION);
        ClientContext.userCookieMgr.addDataSource(ClientContext.levelMgr);
        ClientContext.userCookieMgr.addDataSource(ClientContext.globalPlayerStats);
        ClientContext.userCookieMgr.addDataSource(ClientContext.endlessLevelMgr);
        ClientContext.userCookieMgr.addDataSource(ClientContext.prizeMgr);
        ClientContext.userCookieMgr.addDataSource(ClientContext.savedPlayerBits);

        if (ClientContext.gameCtrl.isConnected()) {
            // if we're connected to Whirled, keep the game centered and draw a pretty
            // tiled background behind it
            _events.registerListener(ClientContext.gameCtrl.local, SizeChangedEvent.SIZE_CHANGED,
                handleSizeChanged)

            handleSizeChanged();

            // and don't show the "rematch" button - we have a UI for it in-game
            ClientContext.gameCtrl.local.setShowReplay(false);

            // get level packs
            ClientContext.reloadLevelPacks();

            // if the player purchases level packs while the game is in progress, update our
            // level packs
            _events.registerListener(
                ClientContext.gameCtrl.player,
                GameContentEvent.PLAYER_CONTENT_ADDED,
                function (...ignored) :void {
                    ClientContext.reloadLevelPacks();
                });

        }

        ClientContext.mainLoop.run();

        // Before we kick off our loading mode, we need to load an initial set of resources
        // required to actually show the loading screen.
        Resources.loadInitialResources(
            function () :void {
                ClientContext.mainLoop.unwindToMode(new LoadingMode());
            },
            function (loadErr :String) :void {
                ClientContext.mainLoop.unwindToMode(new GenericLoadErrorMode(loadErr));
            });
    }

    protected function handleSizeChanged (...ignored) :void
    {
        var size :Point = ClientContext.gameCtrl.local.getSize();
        ClientContext.mainSprite.x = (size.x * 0.5) - (Constants.SCREEN_SIZE.x * 0.5);
        ClientContext.mainSprite.y = (size.y * 0.5) - (Constants.SCREEN_SIZE.y * 0.5);
    }

    protected function handleUnload (...ignored) :void
    {
        _events.freeAllHandlers();
        ClientContext.mainLoop.shutdown();
    }

    public function loadResources (completeCallback :Function, errorCallback :Function) :void
    {
        function loadSingleOrMultiplayerResources () :void {
            if (Resources.queueLevelPackResources(ClientContext.isMultiplayer ?
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
import com.whirled.contrib.simplegame.util.Rand;
import popcraft.game.endless.SavedEndlessGame;
import popcraft.lobby.MultiplayerLobbyMode;

class LoadingMode extends GenericLoadingMode
{
    override protected function setup () :void
    {
        _loadingResources = true;
        ClientContext.userCookieMgr.readCookie();
        ClientContext.mainSprite.loadResources(resourceLoadComplete, onLoadError);
    }

    override public function update (dt :Number) :void
    {
        super.update(dt);

        _elapsedTime += dt;
        if (Constants.DEBUG_EXTEND_LOAD_SEQUENCE && _elapsedTime < EXTENDED_LOADING_TIME) {
            return;
        }

        if (!_loadingResources && !ClientContext.userCookieMgr.isLoadingCookie) {
            if (ClientContext.seatingMgr.allPlayersPresent) {
                startGame();
            } else {
                this.loadingText = "Waiting for players";
            }
        }
    }

    protected function startGame () :void
    {
        if (ClientContext.isMultiplayer) {
            ClientContext.mainLoop.unwindToMode(new MultiplayerLobbyMode());
        } else {
            LevelSelectMode.create();
        }

        // award the player any prizes they haven't gotten yet
        ClientContext.prizeMgr.checkPrizes();
    }

    protected function resourceLoadComplete () :void
    {
        _loadingResources = false;
    }

    protected function onLoadError (err :String) :void
    {
        ClientContext.mainLoop.unwindToMode(new GenericLoadErrorMode(err));
    }

    protected var _loadingResources :Boolean;
    protected var _elapsedTime :Number = 0;

    protected static const EXTENDED_LOADING_TIME :Number = 4;
}
