//
// $Id$

package {

import com.whirled.WhirledGameControl;

public class GhostSubmarine extends Submarine
{
    public function GhostSubmarine (
        playerId :int, playerIdx :int, playerName :String, startx :int, starty :int,
        board :Board, gameCtrl :WhirledGameControl)
    {
        super(playerId, playerIdx, playerName, startx, starty, board, gameCtrl);
    }

    public function addNewActions (actions :Array) :void
    {
        for each (var action :int in actions) {
            if (action != Action.SHOOT && action != Action.BUILD && action != Action.RESPAWN) {
                _movedOrShot = false;
                performActionInternal(action);
            }
        }
    }

    public function updateQueuedActions (xx :int, yy :int, orient :int, actions :Array) :void
    {
        _x = xx;
        _y = yy;
        _orient = orient;

        addNewActions(actions);

        updateVisual();
        updateLocation();
    }

    override protected function setupNameLabel (playerName :String) :void
    {
        // Don't.
    }

    override protected function updateDisplayedScore () :void
    {
        // Don't.
    }
}
}
