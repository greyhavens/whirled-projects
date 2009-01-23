//
// $Id$

package bingo.client {

import bingo.*;

import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControl;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.Sprite;
import flash.events.Event;

[SWF(width="700", height="500")]
public class BingoMain extends Sprite
{
    public function BingoMain ()
    {
        addEventListener(Event.ADDED_TO_STAGE, handleAdded);
        addEventListener(Event.REMOVED_FROM_STAGE, handleUnload);

        // setup simplegame
        var config :Config = new Config();
        config.hostSprite = this;
        _sg = new SimpleGame(config);
        ClientCtx.mainLoop = _sg.ctx.mainLoop;
        ClientCtx.rsrcs = _sg.ctx.rsrcs;
        ClientCtx.audio = _sg.ctx.audio;

        // load resources
        ClientCtx.rsrcs.queueResourceLoad("swf", "ui",     { embeddedClass: Resources.SWF_UI });
        ClientCtx.rsrcs.queueResourceLoad("swf", "board",  { embeddedClass: Resources.SWF_BOARD });
        ClientCtx.rsrcs.queueResourceLoad("swf", "intro",  { embeddedClass: Resources.SWF_INTRO });
        ClientCtx.rsrcs.queueResourceLoad("swf", "help",   { embeddedClass: Resources.SWF_HELP });

        ClientCtx.rsrcs.loadQueuedResources(handleResourcesLoaded, handleResourceLoadError);
    }

    protected function maybeShowIntro () :void
    {
        if (_addedToStage && _resourcesLoaded) {
            ClientCtx.gameCtrl = new AVRGameControl(this);
            ClientCtx.gameCtrl.player.addEventListener(AVRGamePlayerEvent.LEFT_ROOM, leftRoom);

            ClientCtx.ourPlayerId = (ClientCtx.gameCtrl.isConnected()
                ? ClientCtx.gameCtrl.player.getPlayerId() : 666);

            ClientCtx.items = new BingoItemManager(ClientBingoItems.ITEMS);

            ClientCtx.model = new Model();
            ClientCtx.model.setup();

            _sg.run();
            ClientCtx.mainLoop.pushMode(new IntroMode());
        }
    }

    protected function handleResourcesLoaded () :void
    {
        _resourcesLoaded = true;
        this.maybeShowIntro();
    }

    protected function handleResourceLoadError (err :String) :void
    {
        log.warning("Resource load error: " + err);
    }

    protected function handleAdded (event :Event) :void
    {
        log.info("Added to stage: Initializing...");

        _addedToStage = true;
        this.maybeShowIntro();
    }

    protected function handleUnload (event :Event) :void
    {
        log.info("Removed from stage - Unloading...");

        ClientCtx.model.destroy();
        _sg.shutdown();
    }

    protected function leftRoom (e :Event) :void
    {
        log.debug("leftRoom");
        ClientCtx.quit();
    }

    protected var _sg :SimpleGame;
    protected var _addedToStage :Boolean;
    protected var _resourcesLoaded :Boolean;

    protected static var log :Log = Log.getLog(BingoMain);
}
}
