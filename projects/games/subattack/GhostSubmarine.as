//
// $Id$

package {

import flash.display.DisplayObject;

import flash.events.Event;

import flash.utils.getTimer; // function import

import com.threerings.util.Log;

import com.whirled.WhirledGameControl;

public class GhostSubmarine extends Submarine
{
    public static const FUTURE_SHOW :int = 250;

    public function GhostSubmarine (
        playerId :int, playerIdx :int, playerName :String, startx :int, starty :int,
        board :Board, gameCtrl :WhirledGameControl)
    {
        super(playerId, playerIdx, playerName, startx, starty, board, gameCtrl);

        addEventListener(Event.ADDED_TO_STAGE, handleAddRemove);
        addEventListener(Event.REMOVED_FROM_STAGE, handleAddRemove);
    }

    override public function addPoints (points :int, show :Boolean = true) :void
    {
        // don't even think about it
    }

    public function updateQueuedActions (xx :int, yy :int, orient :int, actions :Array) :void
    {
        _x = xx;
        _y = yy;
        _orient = orient;
        _futureActions = [];

        for (var ii :int = 0; ii < actions.length; ii += 2) {
            queueAction(Number(actions[ii]), int(actions[ii + 1]));
        }

        updateVisual();
        updateLocation();

        checkAlpha();
    }

    override public function queueAction (now :Number, action :int) :void
    {
        super.queueAction(now, action);

        // perform it immediately, since we're a ghost
        _movedOrShot = false;
        performActionInternal(action);
    }

    protected function checkAlpha () :void
    {
        var show :Boolean = (_futureActions.length > 0) &&
            (getTimer() - Number(_futureActions[0]) > FUTURE_SHOW);

        this.alpha = show ? .8 : 0;
    }

    override protected function performActionInternal (action :int) :int
    {
        switch (action) {
        case Action.SHOOT:
        case Action.BUILD:
        case Action.RESPAWN:
            return OK;

        default:
            return super.performActionInternal(action);
        }
    }

    override protected function configureVisual (playerIdx :int, playerName :String) :void
    {
        addChild(new FUTURE_MOVE() as DisplayObject);
        this.alpha = 0;
    }

    override protected function updateVisual () :void
    {
        // Don't.
    }

    protected function handleAddRemove (event :Event) :void
    {
        if (event.type == Event.ADDED_TO_STAGE) {
            addEventListener(Event.ENTER_FRAME, handleFrame);
        } else {
            removeEventListener(Event.ENTER_FRAME, handleFrame);
        }
    }

    protected function handleFrame (event :Event) :void
    {
        checkAlpha();
    }

    [Embed(source="rsrc/futuremove.png")]
    protected static const FUTURE_MOVE :Class;
}
}
