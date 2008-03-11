//
// $Id$

package ghostbusters {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Rectangle;

import flash.events.Event;

import com.whirled.AVRGameAvatar;
import com.whirled.AVRGameControl;
import com.whirled.AVRGameControlEvent;
import com.whirled.MobControl;

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.threerings.util.Random;
import com.threerings.util.StringUtil;

import ghostbusters.fight.FightController;

import ghostbusters.seek.HidingGhost;
import ghostbusters.seek.SeekController;

[SWF(width="700", height="500")]
public class Game extends Sprite
{
    public static const DEBUG :Boolean = false;
    public static const FRAMES_PER_REPORT :int = 300;

    public static var log :Log = Log.getLog(Game);

    public static var control :AVRGameControl;

    public static var gameController :GameController;
    public static var seekController :SeekController;
    public static var fightController :FightController;

    public static var model :GameModel;

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
        ourPlayerId = control.getPlayerId();

        model = new GameModel();

        gameController = new GameController();
        seekController = new SeekController();
        fightController = new FightController();

        addChild(gameController.panel);

        control.setHitPointTester(gameController.panel.hitTestPoint);

        addEventListener(Event.ADDED_TO_STAGE, handleAdded);
        addEventListener(Event.REMOVED_FROM_STAGE, handleUnload);

        control.addEventListener(
            AVRGameControlEvent.ENTERED_ROOM,
            function (... ignored) :void { newRoom(); gameController.panel.reloadView(); });

        control.addEventListener(
            AVRGameControlEvent.SIZE_CHANGED,
            function (... ignored) :void { newSize(); gameController.panel.reloadView(); });

        control.addEventListener(AVRGameControlEvent.PLAYER_ENTERED, playerEntered);
        control.addEventListener(AVRGameControlEvent.PLAYER_LEFT, playerLeft);

        control.addEventListener(AVRGameControlEvent.GOT_CONTROL, gotControl);

        if (control.hasControl() && !control.state.getProperty(Codes.PROP_TICKER_RUNNING)) {
            control.state.setProperty(Codes.PROP_TICKER_RUNNING, true, false);
            control.startTicker(Codes.MSG_TICK, 1000);
        }
    }

    protected function handleUnload (event :Event) :void
    {
        log.info("Removed from stage - Unloading...");

        gameController.shutdown();
        fightController.shutdown();
        seekController.shutdown();

        model.shutdown();
    }

    protected function handleAdded (event :Event) :void
    {
        log.info("Added to stage: Initializing...");
        newSize();
        newRoom();
        gameController.panel.reloadView();
//        gameController.panel.showSplash();
    }

    protected function newSize () :void
    {
        var resized :Boolean = false;

        var newSize :Rectangle = control.getStageSize();
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

        newSize = control.getStageSize(false);
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
        ourRoomId = control.getRoomId();

        var newBounds :Rectangle = control.getRoomBounds();
        if (newBounds != null) {
            roomBounds = newBounds;
            log.debug("Setting room bounds: " + roomBounds);

        } else if (roomBounds != null) {
            log.warning("Eek - null room bounds -- keeping old data.");

        } else {
            log.warning("Eek - null room bounds -- hard coding at 700x500");
            roomBounds = new Rectangle(0, 0, 700, 500);
        }

        model.newRoom();
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
}
}
