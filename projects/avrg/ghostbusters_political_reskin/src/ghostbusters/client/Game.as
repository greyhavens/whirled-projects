//
// $Id$
//
// TODO: Do something better when the players win and when they lose

package ghostbusters.client {

import flash.display.DisplayObject;
import flash.display.Sprite;

import flash.events.Event;

import flash.geom.Rectangle;

import com.whirled.avrg.AVRGameAvatar;
import com.whirled.avrg.AVRGameControl;
import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.avrg.AVRGamePlayerEvent;

import com.threerings.util.Log;
import com.threerings.util.Random;

import ghostbusters.client.util.GhostModel;
import ghostbusters.client.util.PlayerModel;
import ghostbusters.data.Codes;

public class Game extends Sprite
{
    public static const DEBUG :Boolean = false;
    public static const FRAMES_PER_REPORT :int = 300;

    public static var control :AVRGameControl;

    public static var panel :GamePanel;

    public static var ourRoomId :int;
    public static var ourPlayerId :int;

    public static var random :Random;

    public function Game (ctrl :AVRGameControl)
    {
        Game.control = ctrl;

        random = new Random();

        if (!ctrl.isConnected()) {
            return;
        }


        ourPlayerId = control.player.getPlayerId();

        var gameController :GameController = new GameController();

        addChild(panel = gameController.panel);

        //SKIN we don't need this?
        control.local.setHitPointTester(panel.hitTestPoint);

        addEventListener(Event.ADDED_TO_STAGE, handleAdded);
        addEventListener(Event.REMOVED_FROM_STAGE, handleUnload);

        control.room.addEventListener(
            AVRGamePlayerEvent.ENTERED_ROOM, function (event :Event) :void {
                newRoom();
            });
    }

    // TODO: move this
    public static function relative (cur :int, max :int) :Number
    {
        return (max > 0) ? (cur / max) : 1;
    }

    public static function get state () :String
    {
        var state :Object = control.room.props.get(Codes.PROP_STATE);
        return (state is String) ? state as String : Codes.STATE_SEEKING;
    }

    public static function amDead () :Boolean
    {
        return int(control.player.props.get(Codes.PROP_MY_HEALTH)) == 0;
    }

    protected function handleUnload (event :Event) :void
    {
        log.info("Removed from stage - Unloading...");
    }

    protected function handleAdded (event :Event) :void
    {
        log.info("Added to stage: Initializing...");
        newRoom();
//        gameController.panel.showSplash();
    }

    protected function newRoom () :void
    {
        ourRoomId = control.room.getRoomId();
    }

    protected static const log :Log = Log.getLog(Game);
}
}
