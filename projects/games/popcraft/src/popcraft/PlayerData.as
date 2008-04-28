package popcraft {

import com.whirled.contrib.simplegame.SimObjectRef;

import popcraft.battle.PlayerBaseUnit;

/**
 * Encapsulates public information about a player in the game.
 */
public class PlayerData
{
    public function PlayerData (playerId :uint, teamId :uint)
    {
        _playerId = playerId;
        _teamId = teamId;

        var whirledIds :Array;
        var playerNames :Array;

        if (AppContext.gameCtrl.isConnected()) {
            whirledIds = AppContext.gameCtrl.game.seating.getPlayerIds();
            playerNames = AppContext.gameCtrl.game.seating.getPlayerNames();
        } else {
            whirledIds = playerNames = [];
        }

        _whirledId = (playerId < whirledIds.length ? whirledIds[_playerId] : 0);
        _playerName = (playerId < playerNames.length ? playerNames[_playerId]: "Unknown player " + playerId);
    }

    public function get playerId () :uint
    {
        return _playerId;
    }

    public function get teamId () :uint
    {
        return _teamId;
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

    public function get baseRef () :SimObjectRef
    {
        return _baseRef;
    }

    public function get base () :PlayerBaseUnit
    {
        return _baseRef.object as PlayerBaseUnit;
    }

    public function set base (val :PlayerBaseUnit) :void
    {
        _baseRef = val.ref;
    }

    public function get isAlive () :Boolean
    {
        // If this is called before the game has been completely set up,
        // _baseRef will be null and (null != this.base) will NPE. We can
        // assume, in this situation, that the player is alive.
        return (null == _baseRef || null != this.base);
    }

    public function get targetedEnemyId () :uint
    {
        return _targetedEnemyId;
    }

    public function set targetedEnemyId (val :uint) :void
    {
        _targetedEnemyId = val;
    }

    protected var _playerId :uint;  // an unsigned integer corresponding to the player's seating position
    protected var _teamId :uint;
    protected var _whirledId :int;  // the oid assigned to this player on Whirled
    protected var _playerName :String;
    protected var _leftGame :Boolean;
    protected var _targetedEnemyId :uint;
    protected var _baseRef :SimObjectRef;

}

}
