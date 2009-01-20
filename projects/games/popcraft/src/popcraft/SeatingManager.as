package popcraft {

import com.threerings.util.ArrayUtil;
import com.whirled.game.GameControl;
import com.whirled.game.OccupantChangedEvent;

public class SeatingManager
{
    public function init (gameCtrl :GameControl) :void
    {
        _gameCtrl = gameCtrl;

        if (_gameCtrl.isConnected()) {
            _numExpectedPlayers = _gameCtrl.game.seating.getPlayerIds().length;
            _playersPresent = ArrayUtil.create(_numExpectedPlayers, false);
            _localPlayerSeat = _gameCtrl.game.seating.getMyPosition();
            updatePlayers();

            // Use a high priority for these event handlers. We want to process them before
            // anyone else does.
            _gameCtrl.game.addEventListener(OccupantChangedEvent.OCCUPANT_ENTERED,
                                                      updatePlayers, false, int.MAX_VALUE);
            _gameCtrl.game.addEventListener(OccupantChangedEvent.OCCUPANT_LEFT,
                                                      updatePlayers, false, int.MAX_VALUE);

        } else {
            _numExpectedPlayers = 1;
            _numPlayers = 1;
            _localPlayerSeat = 0;
            _lowestOccupiedSeat = 0;
        }
    }

    public function get numExpectedPlayers () :int
    {
        return _numExpectedPlayers;
    }

    public function get numPlayers () :int
    {
        return _numPlayers;
    }

    public function get allPlayersPresent () :Boolean
    {
        return _numExpectedPlayers == _numPlayers;
    }

    public function get localPlayerSeat () :int
    {
        return _localPlayerSeat;
    }

    public function get localPlayerOccupantId () :int
    {
        return getPlayerOccupantId(_localPlayerSeat);
    }

    public function get isLocalPlayerGuest () :Boolean
    {
        // NB: this won't return true until Whirled games are given memberIds
        return (localPlayerOccupantId < 0);
    }

    public function isPlayerPresent (playerSeat :int) :Boolean
    {
        return _playersPresent[playerSeat];
    }

    public function getPlayerName (playerSeat :int) :String
    {
        var playerName :String;
        if (_gameCtrl.isConnected() && playerSeat < _numExpectedPlayers) {
            playerName = _gameCtrl.game.seating.getPlayerNames()[playerSeat];
        }

        return (null != playerName ? playerName : "[Unknown Player: " + playerSeat + "]");
    }

    public function getPlayerOccupantId (playerSeat :int) :int
    {
        if (_gameCtrl.isConnected() && playerSeat < _numExpectedPlayers) {
            return _gameCtrl.game.seating.getPlayerIds()[playerSeat];
        } else {
            return 0;
        }
    }

    public function getPlayerSeat (playerId :int) :int
    {
        if (_gameCtrl.isConnected()) {
            return _gameCtrl.game.seating.getPlayerPosition(playerId);
        } else {
            return 0;
        }
    }

    public function getPlayerIds () :Array
    {
        if (_gameCtrl.isConnected()) {
            return _gameCtrl.game.seating.getPlayerIds();
        } else {
            return [ 0 ];
        }
    }

    public function get isLocalPlayerInControl () :Boolean
    {
        return _localPlayerSeat == _lowestOccupiedSeat;
    }

    protected function updatePlayers (...ignored) :void
    {
        var playerIds :Array = _gameCtrl.game.seating.getPlayerIds();
        _numPlayers = 0;
        _lowestOccupiedSeat = -1;
        for (var seatIndex :int = 0; seatIndex < playerIds.length; ++seatIndex) {
            var playerId :int = playerIds[seatIndex];
            var playerPresent :Boolean = (playerId != 0);

            if (playerPresent) {
                ++_numPlayers;
                if (_lowestOccupiedSeat < 0) {
                    _lowestOccupiedSeat = seatIndex;
                }
            }

            _playersPresent[seatIndex] = playerPresent;
        }
    }

    protected var _gameCtrl :GameControl;
    protected var _playersPresent :Array;
    protected var _numExpectedPlayers :int;  // the number of players who initially joined the game
    protected var _numPlayers :int;          // the number of players in the game right now
    protected var _lowestOccupiedSeat :int;
    protected var _localPlayerSeat :int;
}

}
