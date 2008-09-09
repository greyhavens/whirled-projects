//
// $Id$

package simon {

import com.threerings.util.Log;
import com.whirled.avrg.AVRGameAvatar;
import com.whirled.avrg.AVRGameControl;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.avrg.AVRGameRoomEvent;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.Sprite;
import flash.events.Event;

[SWF(width="700", height="500")]
public class SimonMain extends Sprite
{
    public static var log :Log = Log.getLog("simon");

    public static var control :AVRGameControl;
    public static var model :Model;

    public static var localPlayerId :int;

    public static function get localPlayerName () :String
    {
        return SimonMain.getPlayerName(localPlayerId);
    }

    public static function quit () :void
    {
        if (control.isConnected()) {
            control.player.setAvatarState("Default");
            control.player.deactivateGame();
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
        control.player.addEventListener(AVRGamePlayerEvent.ENTERED_ROOM, enteredRoom);
    }

    protected function handleResourcesLoaded () :void
    {
        log.info("Resources loaded");
        _resourcesLoaded = true;
        this.maybeBeginGame();
    }

    protected function handleResourceLoadError (err :String) :void
    {
        log.warning("Resource load error: " + err);
    }

    protected function maybeBeginGame () :void
    {
        if (_addedToStage && _resourcesLoaded && _enteredRoom) {
            model.setup();

            control.agent.sendMessage(Constants.MSG_PLAYERREADY);

            MainLoop.instance.pushMode(new GameMode());
            MainLoop.instance.run();
        }
    }

    public static function getPlayerName (playerId :int) :String
    {
        if (control.isConnected()) {
            var avatar :AVRGameAvatar = control.room.getAvatarInfo(playerId);
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

        // TODO: formalize initialization?
        localPlayerId = (control.isConnected() ? control.player.getPlayerId() : 666);

        _addedToStage = true;

        this.maybeBeginGame();
    }

    protected function handleUnload (event :Event) :void
    {
        log.info("Removed from stage - Unloading...");

        model.destroy();

        MainLoop.instance.shutdown();
    }

    protected function enteredRoom (e :AVRGamePlayerEvent) :void
    {
        log.info("Entered room");
        _enteredRoom = true;
        maybeBeginGame();
    }

    protected var _addedToStage :Boolean;
    protected var _resourcesLoaded :Boolean;
    protected var _enteredRoom :Boolean;
}

}
