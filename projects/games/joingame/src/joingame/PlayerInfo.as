package joingame {

import com.threerings.util.Log;
import com.whirled.contrib.simplegame.SimObjectRef;

import flash.events.EventDispatcher;


/**
 * Encapsulates public information about a player in the game.
 */
public class PlayerInfo extends EventDispatcher
{
    public function PlayerInfo (playerId :int, teamId :int, handicap :Number = 1, playerName :String = null)
    {
        _playerId = playerId;
        _handicap = handicap;

        var whirledIds :Array;
        var playerNames :Array;

        if (AppContext.gameCtrl.isConnected()) {
            whirledIds = AppContext.gameCtrl.game.seating.getPlayerIds();
            playerNames = AppContext.gameCtrl.game.seating.getPlayerNames();
        } else {
            whirledIds = playerNames = [];
        }

        _whirledId = (playerId < whirledIds.length ? whirledIds[_playerId] : 0);

        if (null != playerName) {
            _playerName = playerName;
        } else if (_playerId < playerNames.length && null != playerNames[_playerId])  {
            _playerName = playerNames[_playerId];
        } else {
            _playerName = "Unknown player " + playerId;
        }
    }

    public function get handicap () :Number
    {
        return _handicap;
    }


    public function get playerId () :int
    {
        return _playerId;
    }



    public function get whirledId () :int
    {
        return _whirledId;
    }

    public function get playerName () :String
    {
        return _playerName;
    }

    public function get leftGame () :Boolean
    {
        return _leftGame;
    }

    public function set leftGame (val :Boolean) :void
    {
        _leftGame = val;
    }



    protected var _playerId :int;  // an unsigned integer corresponding to the player's seating position
//    protected var _teamId :int;
    protected var _whirledId :int;  // the oid assigned to this player on Whirled
    protected var _playerName :String;
    protected var _leftGame :Boolean;
//    protected var _targetedEnemyId :int;
//    protected var _baseRef :SimObjectRef;
    protected var _handicap :Number;

    protected static var log :Log = Log.getLog(PlayerInfo);

}

}
