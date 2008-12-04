// 
// $Id$

package locksmith.model {

import com.threerings.util.ArrayUtil;

import com.whirled.game.GameControl;

import com.whirled.contrib.EventHandlerManager;

public class TurnManager extends ModelManager
{
    public static const PLAYER :String = "TurnManagerPlayer";

    public static const TURN_ANIMATION_TIME :int = 3000; // in ms

    public function TurnManager (gameCtrl :GameControl, eventMgr :EventHandlerManager)
    {
        super(gameCtrl, eventMgr);
        manageProperties(PLAYER);
    }

    public function get turnHolder () :Player
    {
        return Player.valueOf(getIn(PLAYER, turnHolderId) as String);
    }

    public function get turnHolderId () :int
    {
        return _gameCtrl.game.getTurnHolderId();
    }

    public function get isMyTurn () :Boolean
    {
        requireClient();
        return _gameCtrl.game.isMyTurn();
    }

    public function advanceTurn () :void
    {
        requireServer();
        startNextTurn();
    }

    public function assignPlayers () :void
    {
        requireServer();
        var players :Array = Player.values();
        ArrayUtil.shuffle(players);
        for (var ii :int = 0; ii < players.length; ii++) {
            setIn(PLAYER, ii, players[ii].name());
        }
    }

    override protected function managedPropertyUpdated (prop :String, oldValue :Object, 
        newValue :Object, key :int = -1) :void
    {
        // NOOP we have to override this method or the super class will throw an error
    }
}
}
