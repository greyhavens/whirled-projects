// 
// $Id$

package locksmith.model {

import com.whirled.game.GameControl;

import com.whirled.contrib.EventHandlerManager;

public class TurnManager extends ModelManager
{
    public static const PLAYER :String = "TurnManagerPlayer";

    public function TurnManager (gameCtrl :GameControl, eventMgr :EventHandlerManager)
    {
        super(gameCtrl, eventMgr);
        managerProperties(PLAYER);
    }

    public function get turnHolder () :Player
    {
        // TODO: find Player that currently holds the turn
    }

    public function get turnHolderId () :int
    {
        // TODO: return the whirled player id of the current turn holder
    }

    public function assignPlayers () :void
    {
        requireServer();
        // TODO: assign a Player to both positions.
    }

    override protected function managedPropertyUpdated (prop :String, oldValue :Object, 
        newValue :Object, key :int = -1) :void
    {
        // TODO
    }
}
}
