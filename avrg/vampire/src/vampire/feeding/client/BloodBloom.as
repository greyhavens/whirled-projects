package vampire.feeding.client {

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.threerings.util.Util;
import com.whirled.avrg.AVRGameControl;
import com.threerings.util.EventHandlerManager;
import com.whirled.contrib.LevelPackManager;
import com.whirled.contrib.ManagedTimer;
import com.whirled.contrib.TimerManager;
import com.whirled.contrib.namespc.*;
import com.threerings.flashbang.*;
import com.threerings.flashbang.resource.ResourceManager;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.PropertyChangedEvent;

import flash.display.Sprite;

import vampire.feeding.*;
import vampire.feeding.net.*;
import vampire.feeding.variant.Variant;

public class BloodBloom extends FeedingClient
{
    public static var log :Log = Log.getLog(BloodBloom);

    public static function init (hostSprite :Sprite, gameCtrl :AVRGameControl) :void
    {
        if (_inited) {
            throw new Error("init has already been called");
        }

        _hostSprite = hostSprite;

        // Init simplegame
        _sg = new FlashbangApp(new Config());

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

    public function BloodBloom (settings :FeedingClientSettings)
    {
        if (!_inited) {
            throw new Error("FeedingGameClient.init has not been called");
        }

        ClientCtx.init();
        ClientCtx.clientSettings = settings;

        if (!ClientCtx.clientSettings.spOnly) {
            ClientCtx.props = new NamespacePropGetControl(String(settings.mpGameId),
                ClientCtx.gameCtrl.room.props);
            ClientCtx.msgMgr = new ClientMsgMgr(settings.mpGameId, ClientCtx.gameCtrl);
            FeedingUtil.initMessageManager(ClientCtx.msgMgr);
        }

        // If the resources aren't loaded, wait for them to load
        if (!_resourcesLoaded) {
            var timer :ManagedTimer = _timerMgr.runForever(50, checkResourcesLoaded);
            function checkResourcesLoaded (...ignored) :void {
                if (_resourcesLoaded) {
                    timer.cancel();
                    maybeFinishInit();
                }
            }
        } else {
            maybeFinishInit();
        }

        ClientCtx.mainLoop.run(_hostSprite);
    }

    override public function shutdown () :void
    {
        if (_hasShutdown) {
            return;
        }

        _events.registerOneShotCallback(ClientCtx.mainLoop, MainLoop.HAS_STOPPED,
            function (...ignored) :void {
                _events.freeAllHandlers();
                _timerMgr.shutdown();
                ClientCtx.audio.stopAllSounds();

                if (ClientCtx.msgMgr != null) {
                    ClientCtx.msgMgr.shutdown();
                }

                ClientCtx.init(); // release any memory we might be holding onto here

                log.info("Quitting BloodBloom");
            });

        ClientCtx.mainLoop.popAllModes();
        ClientCtx.mainLoop.stop();
        _hasShutdown = true;
    }

    override public function get playerData () :PlayerFeedingData
    {
        return ClientCtx.clientSettings.playerData;
    }

    protected function loadLevelPacks () :void
    {
        ClientCtx.gameCtrl.game.getLevelPacks();
    }

    protected function onPropChanged (e :PropertyChangedEvent) :void
    {
        if (e.name == Props.MODE_NAME) {
            updateMode();
        } else if (e.name == Props.VARIANT_ID) {
            updateVariant();
        }
    }

    protected function updateMode () :void
    {
        var modeName :String = ClientCtx.props.get(Props.MODE_NAME) as String;
        if (modeName != null && modeName == _curModeName) {
            log.warning("updateMode failed: we're already in this mode", "mode", modeName);
            return;
        }

        log.info("Changing mode", "mode", modeName);

        if (modeName == Constants.MODE_LOBBY) {
            ClientCtx.mainLoop.unwindToMode(
                new LobbyMode(LobbyMode.LOBBY, ClientCtx.lastRoundResults));

        } else if (modeName == Constants.MODE_PLAYING) {
            var gamePlayers :Array = Util.keys(ClientCtx.props.get(Props.GAME_PLAYERS));
            if (ArrayUtil.contains(gamePlayers, ClientCtx.localPlayerId)) {
                ClientCtx.mainLoop.unwindToMode(new GameMode());
            } else {
                log.info("A round is being played, but we're not in it.");
                ClientCtx.mainLoop.unwindToMode(new LobbyMode(LobbyMode.WAIT_FOR_NEXT_ROUND));
            }
        }

        _curModeName = modeName;
    }

    protected function updateVariant () :void
    {
        var variant :int = ClientCtx.props.get(Props.VARIANT_ID) as int;

        if (ClientCtx.variantSettings != null) {
            log.error("Variant changed!", "newVariant", variant);

        } else if (variant > Variant.INVALID) {
            ClientCtx.variantSettings = Variant.getSettings(variant);
        }
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
        if (/*!_addedToStage ||*/ !_resourcesLoaded) {
            return;
        }

        if (ClientCtx.clientSettings.spOnly) {
            ClientCtx.variantSettings = ClientCtx.clientSettings.spActivityParams.variantSettings;
            ClientCtx.mainLoop.unwindToMode(new LobbyMode(LobbyMode.LOBBY));

        } else {
            _events.registerListener(ClientCtx.msgMgr, ClientMsgEvent.MSG_RECEIVED, onMsgReceived);
            _events.registerListener(ClientCtx.props, PropertyChangedEvent.PROPERTY_CHANGED,
                onPropChanged, false, int.MAX_VALUE);
            _events.registerListener(ClientCtx.props, ElementChangedEvent.ELEMENT_CHANGED,
                onPropChanged, false, int.MAX_VALUE);

            updateVariant();
            updateMode();
        }
    }

    protected static function loadResources () :void
    {
        var rm :ResourceManager = ClientCtx.rsrcs;

        rm.queueResourceLoad("swf",   "blood",          { embeddedClass: SWF_BLOOD });

        rm.queueResourceLoad("sound", "sfx_heartbeat",  { embeddedClass: SFX_HEARTBEAT });
        rm.queueResourceLoad("sound", "sfx_red_burst",  { embeddedClass: SFX_RED_BURST });
        rm.queueResourceLoad("sound", "sfx_white_burst", { embeddedClass: SFX_WHITE_BURST });
        rm.queueResourceLoad("sound", "sfx_got_blood",  { embeddedClass: SFX_GOT_BLOOD });
        rm.queueResourceLoad("sound", "sfx_got_special_strain",  { embeddedClass: SFX_GOT_SPECIAL_STRAIN });
        rm.queueResourceLoad("sound", "sfx_popped_special_strain",  { embeddedClass: SFX_POPPED_SPECIAL_STRAIN });

        if (ClientCtx.isConnected) {
            var levelPacks :LevelPackManager = new LevelPackManager();
            levelPacks.init(ClientCtx.gameCtrl.game.getLevelPacks());
            var url :String = levelPacks.getMediaURL("mus_main_theme");
            if (url != null) {
                rm.queueResourceLoad("sound", "mus_main_theme", { url: url, type: "music", completeImmediately: true });
            } else {
                log.warning("Missing mus_main_theme level pack");
            }

            url = levelPacks.getMediaURL("mus_corruption_theme");
            if (url != null) {
                rm.queueResourceLoad("sound", "mus_corruption_theme", { url: url, type: "music", completeImmediately: true});
            } else {
                log.warning("Missing mus_corruption_theme level pack");
            }
        }

        rm.loadQueuedResources(
            function () :void {
                _resourcesLoaded = true;
            },
            function (err :String) :void {
                log.error("Error loading resources: " + err);
            });
    }

    //protected var _addedToStage :Boolean;
    protected var _hasShutdown :Boolean;
    protected var _events :EventHandlerManager = new EventHandlerManager();
    protected var _timerMgr :TimerManager = new TimerManager();
    protected var _curModeName :String;

    protected static var _inited :Boolean;
    protected static var _hostSprite :Sprite;
    protected static var _sg :FlashbangApp;
    protected static var _resourcesLoaded :Boolean;

    [Embed(source="../../../../rsrc/feeding/blood.swf", mimeType="application/octet-stream")]
    protected static const SWF_BLOOD :Class;

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
}

}
