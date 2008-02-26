//
// $Id$

package bingo {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Rectangle;

import flash.events.Event;

import com.whirled.AVRGameControl;
import com.whirled.AVRGameControlEvent;

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.threerings.util.Random;

[SWF(width="700", height="500")]
public class BingoMain extends Sprite
{
    public static const DEBUG :Boolean = false;
    public static const FRAMES_PER_REPORT :int = 300;

    public static var log :Log = Log.getLog(BingoMain);

    public static var control :AVRGameControl;

    //public static var gameController :GameController;

    public function BingoMain ()
    {
        control = new AVRGameControl(this);
        /*ourPlayerId = control.getPlayerId();

        gameController = new GameController();

        addChild(gameController.panel);
        
        control.setHitPointTester(gameController.panel.hitTestPoint);*/

        addEventListener(Event.ADDED_TO_STAGE, handleAdded);
        addEventListener(Event.REMOVED_FROM_STAGE, handleUnload);

        control.addEventListener(AVRGameControlEvent.ENTERED_ROOM, enteredRoom);

        control.addEventListener(AVRGameControlEvent.PLAYER_ENTERED, playerEntered);
        control.addEventListener(AVRGameControlEvent.PLAYER_LEFT, playerLeft);

        control.addEventListener(AVRGameControlEvent.GOT_CONTROL, gotControl);
    }

    protected function handleUnload (event :Event) :void
    {
        log.info("Removed from stage - Unloading...");

        //gameController.shutdown();
    }

    protected function handleAdded (event :Event) :void
    {
        log.info("Added to stage: Initializing...");
        
        /*enteredRoom();
        gameController.enterState(GameModel.STATE_INTRO);*/
    }

    protected function enteredRoom (... ignored) :void
    {
        if (!control.hasControl()) {
            // ensure that in every room we visit, someone has control
            control.requestControl();
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
}
}
