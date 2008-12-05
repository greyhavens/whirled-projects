// 
// $Id$

package locksmith.model {

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.threerings.util.ValueEvent;

import com.whirled.game.GameControl;
import com.whirled.game.StateChangedEvent;

import com.whirled.contrib.EventHandlerManager;

[Event(name="turnStarted", type="com.threerings.util.ValueEvent")]

public class TurnManager extends ModelManager
{
    public static const PLAYER :String = "TurnManagerPlayer";

    public static const TURN_ANIMATION_TIME :int = 3000; // in ms

    public static const TURN_CHANGED :String = "turnStarted";

    public function TurnManager (gameCtrl :GameControl, eventMgr :EventHandlerManager)
    {
        super(gameCtrl, eventMgr);
        manageProperties(PLAYER);

        // When single-player AI is in, dispatching a turn changed event from this manager is how
        // the game will fake turns against the AI, so we just always dispatch the event, and the 
        // game turn logic only needs to work one way.
        _eventMgr.registerListener(_gameCtrl.game, StateChangedEvent.TURN_CHANGED, turnChanged);
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
        _gameCtrl.game.startNextTurn();
    }

    public function assignPlayers () :void
    {
        requireServer();
        var players :Array = Player.values();
        var playerIds :Array = _gameCtrl.game.seating.getPlayerIds();
        if (players.length != playerIds.length) {
            log.warning("Woah, we've got the wrong number of players! [" + playerIds.length + "]");
            return;
        }
        ArrayUtil.shuffle(players);
        startBatch();
        for (var ii :int = 0; ii < playerIds.length; ii++) {
            setIn(PLAYER, playerIds[ii], players[ii].name(), true);
        }
        commitBatch();
        _playersAssigned = true;
    }

    override protected function managedPropertyUpdated (prop :String, oldValue :Object, 
        newValue :Object, key :int = -1) :void
    {
        // NOOP we have to override this method or the super class will throw an error
    }

    protected function turnChanged (event :StateChangedEvent) :void
    {
        if (_playersAssigned) {
            dispatchEvent(new ValueEvent(TURN_CHANGED, turnHolder));
        }
    }

    protected var _playersAssigned :Boolean = false;

    private static const log :Log = Log.getLog(TurnManager);
}
}
