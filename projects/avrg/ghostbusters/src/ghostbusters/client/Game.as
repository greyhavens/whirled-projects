//
// $Id$
//
// TODO: A dead player should not change state back to default/fight automatically.
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

[SWF(width="700", height="500")]
public class Game extends Sprite
{
    public static const DEBUG :Boolean = false;
    public static const FRAMES_PER_REPORT :int = 300;

    public static var log :Log = Log.getLog(Game);

    public static var control :AVRGameControl;

    public static var panel :GamePanel;

    public static var stageSize :Rectangle;
    public static var scrollSize :Rectangle;
    public static var roomBounds :Rectangle;

    public static var ourRoomId :int;
    public static var ourPlayerId :int;

    public static var random :Random;

    public function Game ()
    {
        random = new Random();

        control = new AVRGameControl(this);
        if (!control.isConnected()) {
            return;
        }
        ourPlayerId = control.player.getPlayerId();

        var gameController :GameController = new GameController();

        addChild(panel = gameController.panel);

        control.local.setHitPointTester(panel.hitTestPoint);

        addEventListener(Event.ADDED_TO_STAGE, handleAdded);
        addEventListener(Event.REMOVED_FROM_STAGE, handleUnload);

        control.room.addEventListener(
            AVRGamePlayerEvent.ENTERED_ROOM, function (event :Event) :void {
                newRoom();
            });

        control.local.addEventListener(
            AVRGameControlEvent.SIZE_CHANGED, function (event :Event) :void {
                newSize();
                reloadView();
            });
    }

    // TODO: move this
    public static function relative (cur :int, max :int) :Number
    {
        return (max > 0) ? (cur / max) : 1;
    }

    // TODO: move this
    public static function get state () :String
    {
        var state :Object = control.room.props.get(Codes.PROP_STATE);
        return (state is String) ? state as String : Codes.STATE_SEEKING;
    }

    protected function handleUnload (event :Event) :void
    {
        log.info("Removed from stage - Unloading...");
    }

    protected function handleAdded (event :Event) :void
    {
        log.info("Added to stage: Initializing...");
        newSize();
        newRoom();
        reloadView();
//        gameController.panel.showSplash();
    }

    protected function newSize () :void
    {
        var resized :Boolean = false;

        var newSize :Rectangle = control.local.getStageSize();
        if (newSize != null) {
            stageSize = newSize;
            log.debug("Setting stage size: " + stageSize);
            resized = true;

        } else if (stageSize != null) {
            log.warning("Eek - null stage size -- keeping old data.");

        } else {
            log.warning("Eek - null stage size -- hard coding at 700x500");
            stageSize = new Rectangle(0, 0, 700, 500);
        }

        newSize = control.local.getStageSize(false);
        if (newSize != null) {
            scrollSize = newSize;
            log.debug("Setting scroll size: " + scrollSize);
            resized = true;

        } else if (scrollSize != null) {
            log.warning("Eek - null scroll size -- keeping old data.");

        } else {
            log.warning("Eek - null scroll size -- hard coding at 700x500");
            scrollSize = new Rectangle(0, 0, 700, 500);
        }
    }

    protected function newRoom () :void
    {
        ourRoomId = control.room.getRoomId();

        var newBounds :Rectangle = control.room.getRoomBounds();
        if (newBounds != null) {
            roomBounds = newBounds;
            log.debug("Setting room bounds: " + roomBounds);

        } else if (roomBounds != null) {
            log.warning("Eek - null room bounds -- keeping old data.");

        } else {
            log.warning("Eek - null room bounds -- hard coding at 700x500");
            roomBounds = new Rectangle(0, 0, 700, 500);
        }

        panel.newGhost();
    }

    protected function reloadView () :void
    {
        panel.reloadView();
    }
}
}
