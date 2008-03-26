//
// $Id$

package bingo {

import com.threerings.util.Log;
import com.threerings.util.MultiLoader;
import com.whirled.AVRGameAvatar;
import com.whirled.AVRGameControl;
import com.whirled.AVRGameControlEvent;
import com.whirled.contrib.simplegame.*;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.system.ApplicationDomain;

[SWF(width="700", height="500")]
public class BingoMain extends Sprite
{
    public static var control :AVRGameControl;
    public static var model :Model;
    public static var resourcesDomain :ApplicationDomain;

    public static var ourPlayerId :int;

    public static var sprite :Sprite;

    public function BingoMain ()
    {
        log.info("Bingo version " + Constants.VERSION);

        sprite = this;

        addEventListener(Event.ADDED_TO_STAGE, handleAdded);
        addEventListener(Event.REMOVED_FROM_STAGE, handleUnload);

        control = new AVRGameControl(this);

        control.addEventListener(AVRGameControlEvent.LEFT_ROOM, leftRoom);

        control.addEventListener(AVRGameControlEvent.GOT_CONTROL, gotControl);

        resourcesDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
        MultiLoader.getLoaders([ Resources.SWF_UI, Resources.SWF_BOARD ], handleResourcesLoaded, false, resourcesDomain);

        // instantiate MainLoop singleton
        new MainLoop(this);
    }

    public static function quit () :void
    {
        if (control.isConnected()) {
            control.deactivateGame();
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

    protected function maybeBeginGame () :void
    {
        if (_addedToStage && _resourcesLoaded) {

            new BingoItemManager(); // init singleton

            model.setup();

            MainLoop.instance.pushMode(new IntroMode());
            MainLoop.instance.run();
        }
    }

    protected function handleResourcesLoaded (results :Object) :void
    {
        _resourcesLoaded = true;
        this.maybeBeginGame();
    }

    protected function handleAdded (event :Event) :void
    {
        log.info("Added to stage: Initializing...");

        log.info(control.isConnected() ? "playing online game" : "playing offline game");

        model = (control.isConnected() && !Constants.FORCE_SINGLEPLAYER ? new OnlineModel() : new OfflineModel());

        ourPlayerId = (control.isConnected() ? control.getPlayerId() : 666);

        _addedToStage = true;

        this.maybeBeginGame();
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
