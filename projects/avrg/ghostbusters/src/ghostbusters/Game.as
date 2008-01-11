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

        addEventListener(AVRGameControlEvent.PLAYER_MOVED, playerMoved);
        addEventListener(AVRGameControlEvent.SIZE_CHANGED, sizeChanged);
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
        playerMoved();
        gameController.enterState(GameModel.STATE_INTRO);
    }

    protected function sizeChanged (... ignored) :void
    {
        stageSize = control.getStageSize();
        if (stageSize == null) {
            log.debug("Eek! Could not find stage size!");
            stageSize = new Rectangle(0, 0, 700, 500);
        }
    }

    protected function playerMoved (... ignored) :void
    {
        ourRoomId = control.getRoomId();

        roomBounds = control.getRoomBounds();
        if (roomBounds == null) {
            log.debug("Eek! Could not find room size!");
            roomBounds = new Rectangle(0, 0, 700, 500);
        }
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
