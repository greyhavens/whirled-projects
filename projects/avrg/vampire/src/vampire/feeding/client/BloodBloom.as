package vampire.feeding.client {

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.resource.ResourceManager;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;

import vampire.feeding.*;
import vampire.feeding.net.*;

public class BloodBloom extends FeedingGameClient
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
        ClientCtx.playerData = playerData.clone();
        ClientCtx.gameCompleteCallback = gameCompleteCallback;
        ClientCtx.msgMgr = new ClientMsgMgr(gameId, ClientCtx.gameCtrl);
        Util.initMessageManager(ClientCtx.msgMgr);
        ClientCtx.roundMgr = new GameRoundMgr(ClientCtx.msgMgr);

        _events.registerListener(this, Event.ADDED_TO_STAGE, onAddedToStage);
        _events.registerListener(ClientCtx.msgMgr, ClientMsgEvent.MSG_RECEIVED, onMsgReceived);

        // If the resources aren't loaded, wait for them to load
        if (!_resourcesLoaded) {
            var timer :Timer = new Timer(50);
            timer.addEventListener(TimerEvent.TIMER, checkResourcesLoaded);
            timer.start();

            function checkResourcesLoaded (...ignored) :void {
                if (_resourcesLoaded) {
                    timer.removeEventListener(TimerEvent.TIMER, checkResourcesLoaded);
                    timer.stop();
                    maybeReportReady();
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
        ClientCtx.roundMgr.shutdown();

        ClientCtx.init(); // release any memory we might be holding onto here

        log.info("Quitting BloodBloom");
    }

    override public function get playerData () :PlayerFeedingData
    {
        return ClientCtx.playerData;
    }

    protected function onMsgReceived (e :ClientMsgEvent) :void
    {
        if (e.msg is StartGameMsg) {
            if (ClientCtx.gameStarted) {
                log.warning("Received StartGameMsg after game already started!");
                return;
            }

            var startGameMsg :StartGameMsg = e.msg as StartGameMsg;
            ClientCtx.gameStarted = true;
            ClientCtx.playerIds = startGameMsg.playerIds;
            ClientCtx.preyId = startGameMsg.preyId;
            ClientCtx.preyBloodType = startGameMsg.preyBloodType;
            ClientCtx.isAiPrey = (ClientCtx.preyId == Constants.NULL_PLAYER);

        } else if (e.msg is PlayerLeftMsg) {
            if (!ClientCtx.gameStarted) {
                log.warning("Received PlayerLeftMsg before game started!");
                return;
            }

            var playerLeftMsg :PlayerLeftMsg = e.msg as PlayerLeftMsg;
            ArrayUtil.removeFirst(ClientCtx.playerIds, playerLeftMsg.playerId);

        } else if (e.msg is GameEndedMsg || e.msg is ClientBootedMsg) {
            // We were booted from the game, or it ended prematurely for some reason
            ClientCtx.quit(false);

        } else if (e.msg is NoMoreFeedingMsg) {
            ClientCtx.noMoreFeeding = true;
        }
    }

    protected function onAddedToStage (...ignored) :void
    {
        _addedToStage = true;
        maybeReportReady();
    }

    protected function maybeReportReady () :void
    {
        if (_addedToStage && _resourcesLoaded) {
            if (ClientCtx.playerData.timesPlayed == 0) {
                ClientCtx.mainLoop.pushMode(new WaitForOtherPlayersMode());
                ClientCtx.mainLoop.pushMode(new NewPlayerIntroMode());
            } else {
                ClientCtx.mainLoop.pushMode(new WaitForOtherPlayersMode());
                ClientCtx.roundMgr.reportReadyForNextRound();
            }
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
