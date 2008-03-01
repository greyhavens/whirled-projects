//
// $Id$

package bingo {

import com.threerings.util.Log;
import com.whirled.AVRGameAvatar;
import com.whirled.AVRGameControl;
import com.whirled.AVRGameControlEvent;

import flash.display.Sprite;
import flash.events.Event;

[SWF(width="700", height="500")]
public class BingoMain extends Sprite
{
    public static const DEBUG :Boolean = false;
    public static const FRAMES_PER_REPORT :int = 300;

    public static var log :Log = Log.getLog(BingoMain);

    public static var control :AVRGameControl;
    public static var model :Model;
    public static var controller :Controller;
    
    public static var ourPlayerId :int;

    public function BingoMain ()
    {
        control = new AVRGameControl(this);
        
        new BingoItemManager(); // init singleton

        addEventListener(Event.ADDED_TO_STAGE, handleAdded);
        addEventListener(Event.REMOVED_FROM_STAGE, handleUnload);

        control.addEventListener(AVRGameControlEvent.ENTERED_ROOM, enteredRoom);
        control.addEventListener(AVRGameControlEvent.LEFT_ROOM, leftRoom);

        control.addEventListener(AVRGameControlEvent.PLAYER_ENTERED, playerEntered);
        control.addEventListener(AVRGameControlEvent.PLAYER_LEFT, playerLeft);

        control.addEventListener(AVRGameControlEvent.GOT_CONTROL, gotControl);
        
        control.setHitPointTester(hitTestPoint);
    }
    
    override public function hitTestPoint (x :Number, y :Number, shapeFlag :Boolean = false) :Boolean
    {
        var numChildren :int = this.numChildren;
        
        for (var i :int = 0; i < numChildren; ++i) {
            if (this.getChildAt(i).hitTestPoint(x, y, shapeFlag)) {
                return true;
            }
        }
        return false;
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
        
        model = (control.isConnected() ? new OnlineModel() : new OfflineModel());
        controller = new Controller(this, model);
        
        ourPlayerId = (control.isConnected() ? control.getPlayerId() : 666);
        
        model.setup();
        controller.setup();
        
        this.enteredRoom();
    }

    protected function handleUnload (event :Event) :void
    {
        log.info("Removed from stage - Unloading...");
        
        controller.destroy();
        model.destroy();
    }

    protected function enteredRoom (... ignored) :void
    {
        if (control.isConnected() && !control.hasControl()) {
            // ensure that in every room we visit, someone has control
            control.requestControl();
        }
    }
    
    protected function leftRoom (e :Event) :void
    {
        if (control.isConnected()) {
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
}
}
