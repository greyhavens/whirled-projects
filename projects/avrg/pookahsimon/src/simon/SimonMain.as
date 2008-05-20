//
// $Id$

package simon {

import com.threerings.util.Log;
import com.whirled.AVRGameAvatar;
import com.whirled.AVRGameControl;
import com.whirled.AVRGameControlEvent;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.Sprite;
import flash.events.Event;

[SWF(width="700", height="500")]
public class SimonMain extends Sprite
{
    public static var control :AVRGameControl;
    public static var model :Model;

    public static var localPlayerId :int;

    public static function get localPlayerName () :String
    {
        return SimonMain.getPlayerName(localPlayerId);
    }

    public static function get minPlayersToStart () :int
    {
        return (Constants.FORCE_SINGLEPLAYER || !control.isConnected() ? 1 : Constants.MIN_MP_PLAYERS_TO_START);
    }

    public static function quit () :void
    {
        if (control.isConnected()) {
            control.deactivateGame();
            control.setAvatarState("Default");
        }
    }

    public function SimonMain ()
    {
        log.info("Simon verson " + Constants.VERSION);

        addEventListener(Event.ADDED_TO_STAGE, handleAdded);
        addEventListener(Event.REMOVED_FROM_STAGE, handleUnload);

        // instantiate MainLoop singleton
        new MainLoop(this);
        MainLoop.instance.setup();

        // load resources
        Resources.load(handleResourcesLoaded, handleResourceLoadError);

        // hook up controller
        control = new AVRGameControl(this);
        control.addEventListener(AVRGameControlEvent.LEFT_ROOM, leftRoom);
        control.addEventListener(AVRGameControlEvent.GOT_CONTROL, gotControl);
    }

    protected function handleResourcesLoaded () :void
    {
        _resourcesLoaded = true;
        this.maybeBeginGame();
    }

    protected function handleResourceLoadError (err :String) :void
    {
        log.warning("Resource load error: " + err);
    }

    protected function maybeBeginGame () :void
    {
        if (_addedToStage && _resourcesLoaded) {
            model.setup();

            MainLoop.instance.pushMode(new GameMode());
            MainLoop.instance.run();
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

    protected function handleAdded (event :Event) :void
    {
        log.info("Added to stage: Initializing...");

        log.info(control.isConnected() ? "playing online game" : "playing offline game");

        model = (control.isConnected() && !Constants.FORCE_SINGLEPLAYER ? new OnlineModel() : new OfflineModel());

        localPlayerId = (control.isConnected() ? control.getPlayerId() : 666);

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
        if (control.isConnected()) {
            control.setAvatarState("Default");
            control.deactivateGame();
        }
    }

    protected function gotControl (evt :AVRGameControlEvent) :void
    {
        log.debug("gotControl(): " + evt);
    }

    protected var _addedToStage :Boolean;
    protected var _resourcesLoaded :Boolean;

    protected static var log :Log = Log.getLog(SimonMain);
}

}
