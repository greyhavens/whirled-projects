package vampire.feeding.client {

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.threerings.util.Util;
import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.resource.ResourceManager;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.PropertyChangedEvent;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Dictionary;
import flash.utils.Timer;

import vampire.feeding.*;
import vampire.feeding.net.*;

public class BloodBloom extends FeedingClient
{
    public static function init (hostSprite :Sprite, gameCtrl :AVRGameControl) :void
    {
        if (_inited) {
            throw new Error("init has already been called");
        }

        // Init simplegame
        var config :Config = new Config();
        config.hostSprite = hostSprite;
        _sg = new SimpleGame(config);

        ClientCtx.gameCtrl = gameCtrl;
        ClientCtx.mainLoop = _sg.ctx.mainLoop;
        ClientCtx.rsrcs = _sg.ctx.rsrcs;
        ClientCtx.audio = _sg.ctx.audio;

        if (Constants.DEBUG_DISABLE_AUDIO) {
            ClientCtx.audio.masterControls.volume(0);
        }

        loadResources();

        _inited = true;
    }

    public function BloodBloom (gameId :int, playerData :PlayerFeedingData,
                                gameCompleteCallback :Function)
    {
        if (!_inited) {
            throw new Error("FeedingGameClient.init has not been called");
        }

        ClientCtx.init();
        ClientCtx.props = new GamePropGetControl(gameId, ClientCtx.gameCtrl.room.props);
        ClientCtx.playerData = playerData.clone();
        ClientCtx.gameCompleteCallback = gameCompleteCallback;
        ClientCtx.msgMgr = new ClientMsgMgr(gameId, ClientCtx.gameCtrl);
        FeedingUtil.initMessageManager(ClientCtx.msgMgr);

        _events.registerListener(this, Event.ADDED_TO_STAGE,
            function (...ignored) :void {
                _addedToStage = true;
                maybeFinishInit();
            });

        // If the resources aren't loaded, wait for them to load
        if (!_resourcesLoaded) {
            var timer :Timer = new Timer(50);
            timer.addEventListener(TimerEvent.TIMER, checkResourcesLoaded);
            timer.start();

            function checkResourcesLoaded (...ignored) :void {
                if (_resourcesLoaded) {
                    timer.removeEventListener(TimerEvent.TIMER, checkResourcesLoaded);
                    timer.stop();
                    maybeFinishInit();
                }
            }
        }

        ClientCtx.mainLoop.run();
    }

    override public function shutdown () :void
    {
        _events.freeAllHandlers();
        ClientCtx.mainLoop.shutdown();
        ClientCtx.audio.stopAllSounds();

        ClientCtx.msgMgr.shutdown();

        ClientCtx.init(); // release any memory we might be holding onto here

        log.info("Quitting BloodBloom");
    }

    override public function get playerData () :PlayerFeedingData
    {
        return ClientCtx.playerData;
    }

    protected function onPropChanged (e :PropertyChangedEvent) :void
    {
        if (e.name == Props.ALL_PLAYERS) {
            updatePlayers();
        } else if (e.name == Props.PREY_ID) {
            updatePreyId();
        } else if (e.name == Props.PREY_BLOOD_TYPE) {
            updatePreyBloodType();
        } else if (e.name == Props.PREY_IS_AI) {
            updatePreyIsAi();
        } else if (e.name == Props.MODE) {
            updateMode();
        }
    }

    protected function updatePlayers () :void
    {
        var playerDict :Dictionary = ClientCtx.props.get(Props.ALL_PLAYERS) as Dictionary;
        if (playerDict == null) {
            ClientCtx.playerIds = [];
        } else {
            ClientCtx.playerIds = Util.keys(playerDict);
        }

        if (!ArrayUtil.contains(ClientCtx.playerIds, ClientCtx.preyId)) {
            ClientCtx.preyId = Constants.NULL_PLAYER;
        }
    }

    protected function updatePreyId () :void
    {
        ClientCtx.preyId = ClientCtx.props.get(Props.PREY_ID) as int;
    }

    protected function updatePreyBloodType () :void
    {
        ClientCtx.preyBloodType = ClientCtx.props.get(Props.PREY_BLOOD_TYPE) as int;
    }

    protected function updatePreyIsAi () :void
    {
        ClientCtx.preyIsAi = ClientCtx.props.get(Props.PREY_IS_AI) as Boolean;
    }

    protected function updateMode () :void
    {
        var modeName :String = ClientCtx.props.get(Props.MODE) as String;
        if (modeName != null && modeName == _curModeName) {
            log.warning("updateMode failed: we're already in this mode", "mode", modeName);
            return;
        }

        log.info("Changing mode", "mode", modeName);

        if (modeName == Constants.MODE_LOBBY) {
            ClientCtx.mainLoop.unwindToMode(new LobbyMode());

        } else if (modeName == Constants.MODE_PLAYING) {
            var gamePlayers :Array = Util.keys(ClientCtx.props.get(Props.GAME_PLAYERS));
            if (ArrayUtil.contains(gamePlayers, ClientCtx.localPlayerId)) {
                ClientCtx.mainLoop.unwindToMode(new GameMode());
            } else {
                log.info("A round is being played, but we're not in it.");
                ClientCtx.mainLoop.unwindToMode(new WaitingForNextRoundMode());
            }
        }

        _curModeName = modeName;
    }

    protected function onMsgReceived (e :ClientMsgEvent) :void
    {
        if (e.msg is GameEndedMsg || e.msg is ClientBootedMsg) {
            // We were booted from the game, or it ended prematurely for some reason
            ClientCtx.quit(false);
        }
    }

    protected function maybeFinishInit () :void
    {
        if (!_addedToStage || !_resourcesLoaded) {
            return;
        }

        if (ClientCtx.isConnected) {
            _events.registerListener(ClientCtx.msgMgr, ClientMsgEvent.MSG_RECEIVED, onMsgReceived);
            _events.registerListener(ClientCtx.props, PropertyChangedEvent.PROPERTY_CHANGED,
                onPropChanged, false, int.MAX_VALUE);
            _events.registerListener(ClientCtx.props, ElementChangedEvent.ELEMENT_CHANGED,
                onPropChanged, false, int.MAX_VALUE);

            updatePlayers();
            updatePreyId();
            updatePreyBloodType();
            updateMode();

        } else {
            ClientCtx.mainLoop.pushMode(new GameMode());
        }
    }

    protected static function loadResources () :void
    {
        var rm :ResourceManager = ClientCtx.rsrcs;

        rm.queueResourceLoad("swf",   "blood",          { embeddedClass: SWF_BLOOD });
        rm.queueResourceLoad("image", "bg",             { embeddedClass: IMG_BG });

        rm.queueResourceLoad("sound", "sfx_heartbeat",  { embeddedClass: SFX_HEARTBEAT });
        rm.queueResourceLoad("sound", "sfx_red_burst",  { embeddedClass: SFX_RED_BURST });
        rm.queueResourceLoad("sound", "sfx_white_burst", { embeddedClass: SFX_WHITE_BURST });
        rm.queueResourceLoad("sound", "sfx_got_blood",  { embeddedClass: SFX_GOT_BLOOD });
        rm.queueResourceLoad("sound", "sfx_got_special_strain",  { embeddedClass: SFX_GOT_SPECIAL_STRAIN });
        rm.queueResourceLoad("sound", "sfx_popped_special_strain",  { embeddedClass: SFX_POPPED_SPECIAL_STRAIN });
        rm.queueResourceLoad("sound", "mus_main_theme",      { embeddedClass: MUS_MAIN_THEME, type: "music" });

        rm.loadQueuedResources(
            function () :void {
                _resourcesLoaded = true;
            },
            function (err :String) :void {
                log.error("Error loading resources: " + err);
            });
    }

    protected var _addedToStage :Boolean;
    protected var _events :EventHandlerManager = new EventHandlerManager();
    protected var _curModeName :String;

    protected static var _inited :Boolean;
    protected static var _sg :SimpleGame;
    protected static var _resourcesLoaded :Boolean;
    protected static var log :Log = Log.getLog(BloodBloom);

    [Embed(source="../../../../rsrc/feeding/blood.swf", mimeType="application/octet-stream")]
    protected static const SWF_BLOOD :Class;
    [Embed(source="../../../../rsrc/feeding/bg.png", mimeType="application/octet-stream")]
    protected static const IMG_BG :Class;

    [Embed(source="../../../../rsrc/feeding/heartbeat.mp3")]
    protected static const SFX_HEARTBEAT :Class;
    [Embed(source="../../../../rsrc/feeding/red_burst.mp3")]
    protected static const SFX_RED_BURST :Class;
    [Embed(source="../../../../rsrc/feeding/white_burst.mp3")]
    protected static const SFX_WHITE_BURST :Class;
    [Embed(source="../../../../rsrc/feeding/got_blood.mp3")]
    protected static const SFX_GOT_BLOOD :Class;
    [Embed(source="../../../../rsrc/feeding/got_special_strain.mp3")]
    protected static const SFX_GOT_SPECIAL_STRAIN :Class;
    [Embed(source="../../../../rsrc/feeding/popped_special_strain.mp3")]
    protected static const SFX_POPPED_SPECIAL_STRAIN :Class;

    [Embed(source="../../../../rsrc/feeding/music.mp3")]
    protected static const MUS_MAIN_THEME :Class;
}

}
