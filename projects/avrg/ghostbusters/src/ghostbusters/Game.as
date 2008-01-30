//
// $Id$

package ghostbusters {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Rectangle;

import flash.events.Event;

import com.whirled.AVRGameControl;
import com.whirled.AVRGameControlEvent;
import com.whirled.MobControl;

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.threerings.util.Random;

import ghostbusters.fight.FightController;

import ghostbusters.seek.HidingGhost;
import ghostbusters.seek.SeekController;

[SWF(width="700", height="500")]
public class Game extends Sprite
{
    public static const DEBUG :Boolean = false;

    public static var log :Log = Log.getLog(Game);

    public static var control :AVRGameControl;

    public static var gameController :GameController;
    public static var seekController :SeekController;
    public static var fightController :FightController;

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

        gameController = new GameController();
        seekController = new SeekController();
        fightController = new FightController();

        addChild(gameController.panel);

        control.setMobSpriteExporter(exportMobSprite);
        control.setHitPointTester(gameController.panel.hitTestPoint);

        addEventListener(Event.ADDED_TO_STAGE, handleAdded);
        addEventListener(Event.REMOVED_FROM_STAGE, handleUnload);

        control.addEventListener(AVRGameControlEvent.ENTERED_ROOM, enteredRoom);
        control.addEventListener(AVRGameControlEvent.SIZE_CHANGED, sizeChanged);

        control.addEventListener(AVRGameControlEvent.PLAYER_ENTERED, playerEntered);
        control.addEventListener(AVRGameControlEvent.PLAYER_LEFT, playerLeft);
    }

    protected function handleUnload (event :Event) :void
    {
        log.info("Removed from stage - Unloading...");

        gameController.shutdown();
        fightController.shutdown();
        seekController.shutdown();
    }

    protected function handleAdded (event :Event) :void
    {
        log.info("Added to stage: Initializing...");
        sizeChanged();
        enteredRoom();
        gameController.enterState(GameModel.STATE_INTRO);
    }

    protected function sizeChanged (... ignored) :void
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

        if (resized) {
            gameController.panel.resized();
        }
    }

    protected function enteredRoom (... ignored) :void
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

        gameController.panel.resized();
    }

    protected function playerEntered (evt :AVRGameControlEvent) :void
    {
    }

    protected function playerLeft (evt :AVRGameControlEvent) :void
    {
    }

    public function exportMobSprite (id :String, ctrl :MobControl) :DisplayObject
    {
        if (id == Codes.MOB_ID_GHOST) {
            return Game.fightController.panel.getGhostSprite(ctrl);
        }
        log.warning("Unknown MOB requested [id=" + id + "]");
        return null;
    }
}
}
