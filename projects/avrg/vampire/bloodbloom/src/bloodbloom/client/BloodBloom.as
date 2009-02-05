package bloodbloom.client {

import bloodbloom.*;
import bloodbloom.server.Server;

import com.threerings.util.Log;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.resource.ResourceManager;
import com.whirled.game.GameControl;

import flash.display.Sprite;
import flash.events.Event;

[SWF(width="700", height="500", frameRate="30")]
public class BloodBloom extends Sprite
{
    public static function DEBUG_REMOVE_ME () :void
    {
        var c :Class = Server;
    }

    public function BloodBloom ()
    {
        DEBUG_REMOVE_ME();

        ClientCtx.gameCtrl = new GameControl(this, false);

        _events.registerListener(this, Event.ADDED_TO_STAGE, onAddedToStage);
        _events.registerListener(this, Event.REMOVED_FROM_STAGE, onQuit);

        // Init simplegame
        var config :Config = new Config();
        config.hostSprite = this;
        _sg = new SimpleGame(config);

        ClientCtx.mainLoop = _sg.ctx.mainLoop;
        ClientCtx.rsrcs = _sg.ctx.rsrcs;
        ClientCtx.audio = _sg.ctx.audio;

        _sg.run();

        loadResources();
    }

    protected function loadResources () :void
    {
        var rm :ResourceManager = ClientCtx.rsrcs;

        rm.queueResourceLoad("swf",   "uiBits",         { embeddedClass: SWF_UIBITS });
        rm.queueResourceLoad("image", "bg",             { embeddedClass: IMG_BG });
        rm.queueResourceLoad("image", "artery_blue",    { embeddedClass: IMG_ARTERY_BLUE });
        rm.queueResourceLoad("image", "artery_red",     { embeddedClass: IMG_ARTERY_RED });
        rm.queueResourceLoad("image", "heart",          { embeddedClass: IMG_HEART });
        rm.queueResourceLoad("image", "red_cell",       { embeddedClass: IMG_RED_CELL });
        rm.queueResourceLoad("image", "predator_cursor", { embeddedClass: IMG_PREDATOR_CURSOR });
        rm.queueResourceLoad("image", "prey_cursor",    { embeddedClass: IMG_PREY_CURSOR });
        rm.queueResourceLoad("image", "white_cell",     { embeddedClass: IMG_WHITE_CELL });

        rm.loadQueuedResources(
            function () :void {
                _resourcesLoaded = true;
                maybeStartGame();
            },
            function (err :String) :void {
                log.error("Error loading resources: " + err);
            });
    }

    protected function onAddedToStage (...ignored) :void
    {
        _addedToStage = true;
        maybeStartGame();
    }

    protected function onQuit (...ignored) :void
    {
        _sg.shutdown();
        _events.freeAllHandlers();
    }

    protected function maybeStartGame () :void
    {
        if (_addedToStage && _resourcesLoaded) {
            ClientCtx.mainLoop.pushMode(new SpSplashMode());
        }
    }

    protected var _resourcesLoaded :Boolean;
    protected var _addedToStage :Boolean;

    protected var _sg :SimpleGame;
    protected var _events :EventHandlerManager = new EventHandlerManager();

    protected static var log :Log = Log.getLog(BloodBloom);

    [Embed(source="../../../rsrc/UI_bits.swf", mimeType="application/octet-stream")]
    protected static const SWF_UIBITS :Class;
    [Embed(source="../../../rsrc/bg.png", mimeType="application/octet-stream")]
    protected static const IMG_BG :Class;
    [Embed(source="../../../rsrc/artery_blue.png", mimeType="application/octet-stream")]
    protected static const IMG_ARTERY_BLUE :Class;
    [Embed(source="../../../rsrc/artery_red.png", mimeType="application/octet-stream")]
    protected static const IMG_ARTERY_RED :Class;
    [Embed(source="../../../rsrc/heart.png", mimeType="application/octet-stream")]
    protected static const IMG_HEART :Class;
    [Embed(source="../../../rsrc/red_cell.png", mimeType="application/octet-stream")]
    protected static const IMG_RED_CELL :Class;
    [Embed(source="../../../rsrc/vampire_cursor.png", mimeType="application/octet-stream")]
    protected static const IMG_PREDATOR_CURSOR :Class;
    [Embed(source="../../../rsrc/victim_cursor.png", mimeType="application/octet-stream")]
    protected static const IMG_PREY_CURSOR :Class;
    [Embed(source="../../../rsrc/white_cell.png", mimeType="application/octet-stream")]
    protected static const IMG_WHITE_CELL :Class;
}

}
