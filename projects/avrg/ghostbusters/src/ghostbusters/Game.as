//
// $Id$

package ghostbusters {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Rectangle;

import flash.events.Event;

import com.whirled.AVRGameControl;
import com.whirled.MobControl;

import com.threerings.util.Log;

import ghostbusters.fight.FightController;

import ghostbusters.seek.HidingGhost;
import ghostbusters.seek.SeekController;

[SWF(width="700", height="500")]
public class Game extends Sprite
{
    public static const DEBUG :Boolean = false;

    public static var log :Log = Log.getLog(Game);

    public static var control :AVRGameControl;

    public static var stageSize :Rectangle;

    public static var gameController :GameController;
    public static var seekController :SeekController;
    public static var fightController :FightController;

    public function Game ()
    {
        addEventListener(Event.REMOVED_FROM_STAGE, handleUnload);

        var control :AVRGameControl = new AVRGameControl(this);

        gameController = new GameController(control);
        seekController = new SeekController(control);
        fightController = new FightController(control);

        addChild(gameController.panel);

        control.setMobSpriteExporter(exportMobSprite);
        control.setHitPointTester(gameController.panel.hitTestPoint);

        this.addEventListener(Event.ADDED_TO_STAGE, handleAdded);
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

        stageSize = control.getStageSize();
        if (stageSize == null) {
            log.debug("Eek! Could not find room size!");
            stageSize = new Rectangle(0, 0, 700, 500);
        }

        gameController.enterState(GameModel.STATE_INTRO);
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
