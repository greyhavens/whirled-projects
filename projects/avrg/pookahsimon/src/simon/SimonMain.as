//
// $Id$

package simon {

import com.threerings.util.Log;
import com.threerings.util.MultiLoader;
import com.whirled.AVRGameAvatar;
import com.whirled.AVRGameControl;
import com.whirled.AVRGameControlEvent;

import flash.display.Sprite;
import flash.events.Event;
import flash.system.ApplicationDomain;

[SWF(width="700", height="500")]
public class SimonMain extends Sprite
{
    public static var control :AVRGameControl;
    public static var model :Model;
    public static var controller :Controller;
    public static var resourcesDomain :ApplicationDomain;
    public static var sprite :Sprite;

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

        sprite = this;

        addEventListener(Event.ADDED_TO_STAGE, handleAdded);
        addEventListener(Event.REMOVED_FROM_STAGE, handleUnload);

        control = new AVRGameControl(this);

        control.addEventListener(AVRGameControlEvent.LEFT_ROOM, leftRoom);

        control.addEventListener(AVRGameControlEvent.PLAYER_ENTERED, playerEntered);
        control.addEventListener(AVRGameControlEvent.PLAYER_LEFT, playerLeft);

        control.addEventListener(AVRGameControlEvent.GOT_CONTROL, gotControl);

        resourcesDomain = new ApplicationDomain();
        MultiLoader.getLoaders(Resources.SWF_RAINBOW, handleResourcesLoaded, false, resourcesDomain);
    }

    protected function handleResourcesLoaded (results :Object) :void
    {
        _resourcesLoaded = true;
        this.maybeBeginGame();
    }

    protected function maybeBeginGame () :void
    {
        if (_addedToStage && _resourcesLoaded) {
            model.setup();
            controller.setup();
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
        controller = new Controller(this, model);

        localPlayerId = (control.isConnected() ? control.getPlayerId() : 666);

        _addedToStage = true;

        this.maybeBeginGame();
    }

    protected function handleUnload (event :Event) :void
    {
        log.info("Removed from stage - Unloading...");

        controller.destroy();
        model.destroy();
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

    protected function playerEntered (evt :AVRGameControlEvent) :void
    {
    }

    protected function playerLeft (evt :AVRGameControlEvent) :void
    {
    }

    protected var _addedToStage :Boolean;
    protected var _resourcesLoaded :Boolean;

    protected static var log :Log = Log.getLog(SimonMain);
}

}
