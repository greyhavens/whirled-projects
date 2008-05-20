//
// $Id$

package bingo {

import com.threerings.util.Log;
import com.whirled.AVRGameAvatar;
import com.whirled.AVRGameControl;
import com.whirled.AVRGameControlEvent;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Rectangle;

[SWF(width="700", height="500")]
public class BingoMain extends Sprite
{
    public static var control :AVRGameControl;
    public static var model :Model;
    public static var ourPlayerId :int;

    public function BingoMain ()
    {
        log.info("Bingo version " + Constants.VERSION);

        addEventListener(Event.ADDED_TO_STAGE, handleAdded);
        addEventListener(Event.REMOVED_FROM_STAGE, handleUnload);

        // instantiate MainLoop singleton
        new MainLoop(this);
        MainLoop.instance.setup();

        // load resources
        ResourceManager.instance.pendResourceLoad("swf", "ui",     { embeddedClass: Resources.SWF_UI });
        ResourceManager.instance.pendResourceLoad("swf", "board",  { embeddedClass: Resources.SWF_BOARD });
        ResourceManager.instance.pendResourceLoad("swf", "intro",  { embeddedClass: Resources.SWF_INTRO });
        ResourceManager.instance.pendResourceLoad("swf", "help",   { embeddedClass: Resources.SWF_HELP });

        ResourceManager.instance.load(handleResourcesLoaded, handleResourceLoadError);
    }

    public static function quit () :void
    {
        if (control.isConnected()) {
            control.deactivateGame();
        }
    }

    public static function getScreenBounds () :Rectangle
    {
        if (control.isConnected()) {
            return control.getStageSize(true);
        } else {
            return new Rectangle(0, 0, 700, 500);
        }
    }

    public static function getPlayerName (playerId :int) :String
    {
        if (control.isConnected()) {
            var avatar :AVRGameAvatar = control.getAvatarInfo(playerId);
            if (null != avatar) {
                return avatar.name;
            }
        }

        return "player " + playerId.toString();
    }

    protected function maybeShowIntro () :void
    {
        if (_addedToStage && _resourcesLoaded) {

            control = new AVRGameControl(this);
            control.addEventListener(AVRGameControlEvent.LEFT_ROOM, leftRoom);
            control.addEventListener(AVRGameControlEvent.GOT_CONTROL, gotControl);

            log.info(control.isConnected() ? "playing online game" : "playing offline game");

            ourPlayerId = (control.isConnected() ? control.getPlayerId() : 666);

            new BingoItemManager(); // init singleton

            model = (control.isConnected() && !Constants.FORCE_SINGLEPLAYER ? new OnlineModel() : new OfflineModel());
            model.setup();

            MainLoop.instance.pushMode(new IntroMode());
            MainLoop.instance.run();
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

        model.destroy();

        MainLoop.instance.shutdown();
    }

    protected function leftRoom (e :Event) :void
    {
        log.debug("leftRoom");
        if (control.isConnected()) {
            log.debug("deactivating game");
            control.deactivateGame();
        }
    }

    protected function gotControl (evt :AVRGameControlEvent) :void
    {
        log.debug("gotControl(): " + evt);
    }

    protected var _addedToStage :Boolean;
    protected var _resourcesLoaded :Boolean;

    protected static var log :Log = Log.getLog(BingoMain);
}
}
