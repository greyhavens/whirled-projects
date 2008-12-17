//
// $Id$

package flashmob.client {

import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.Sprite;
import flash.events.Event;

import flashmob.*;
import flashmob.client.view.BasicErrorMode;

[SWF(width="700", height="500")]
public class FlashMobClient extends Sprite
{
    public static var log :Log = Log.getLog(FlashMobClient);

    public function FlashMobClient ()
    {
        log.info("Starting game");

        ClientContext.gameCtrl = new AVRGameControl(this);
        ClientContext.localPlayerId = (ClientContext.gameCtrl.isConnected() ?
            ClientContext.gameCtrl.player.getPlayerId() : 0);

        ClientContext.mainLoop = new MainLoop(this,
            (ClientContext.gameCtrl.isConnected() ? ClientContext.gameCtrl.local : this.stage));
        ClientContext.mainLoop.setup();
        ClientContext.mainLoop.run();

        if (!ClientContext.isLocalPlayerPartied) {
            log.info("You must be in a party to play this game");
            ClientContext.mainLoop.unwindToMode(
                new BasicErrorMode("You must be in a party to play this game"));
            return;
        }

        AppContext.init();
        Resources.loadResources(onResourcesLoaded, onResourceLoadErr);

        addEventListener(Event.ADDED_TO_STAGE, handleAdded);
        addEventListener(Event.REMOVED_FROM_STAGE, handleUnload);
    }

    protected function tryStartGame () :void
    {
        if (!_addedToStage || !_resourcesLoaded) {
            return;
        }
    }

    protected function onResourcesLoaded () :void
    {
        _resourcesLoaded = true;
        tryStartGame();
    }

    protected function onResourceLoadErr (err :String) :void
    {
        ClientContext.mainLoop.unwindToMode(new BasicErrorMode("Error loading game:\n" + err));
    }

    protected function handleAdded (event :Event) :void
    {
        log.info("Added to stage: Initializing...");

        _addedToStage = true;
        tryStartGame();
    }

    protected function handleUnload (event :Event) :void
    {
        log.info("Removed from stage - Unloading...");

        ClientContext.mainLoop.shutdown();
    }

    protected var _addedToStage :Boolean;
    protected var _resourcesLoaded :Boolean;
}
}
