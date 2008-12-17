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

[SWF(width="700", height="500")]
public class FlashMobClient extends Sprite
{
    public function FlashMobClient ()
    {
        AppContext.init();
        Resources.loadResources(onResourcesLoaded, onResourceLoadErr);

        addEventListener(Event.ADDED_TO_STAGE, handleAdded);
        addEventListener(Event.REMOVED_FROM_STAGE, handleUnload);
    }

    protected function tryStartGame () :void
    {
        if (_addedToStage && _resourcesLoaded) {
            ClientContext.gameCtrl = new AVRGameControl(this);
        }
    }

    protected function onResourcesLoaded () :void
    {
        _resourcesLoaded = true;
        tryStartGame();
    }

    protected function onResourceLoadErr (err :String) :void
    {
        log.warning("Can't start, resource load error: " + err);
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
    }

    protected var _addedToStage :Boolean;
    protected var _resourcesLoaded :Boolean;

    protected static var log :Log = Log.getLog(FlashMobClient);
}
}
