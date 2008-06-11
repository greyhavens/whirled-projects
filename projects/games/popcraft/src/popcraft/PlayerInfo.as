package popcraft {

import com.threerings.util.Log;
import com.whirled.contrib.simplegame.SimObjectRef;

import flash.events.EventDispatcher;

import popcraft.battle.PlayerBaseUnit;

/**
 * Encapsulates public information about a player in the game.
 */
public class PlayerInfo extends EventDispatcher
{
    public function PlayerInfo (playerId :uint, teamId :uint, playerName :String = null)
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

        if (null != playerName) {
            _playerName = playerName;
        } else if (_playerId < playerNames.length && null != playerNames[_playerId])  {
            _playerName = playerNames[_playerId];
        } else {
            _playerName = "Unknown player " + playerId;
        }
    }

    public function get playerColor () :uint
    {
        return GameContext.gameData.playerColors[_playerId];
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

    public function get isInvincible () :Boolean
    {
        return (null != _baseRef && this.base.isInvincible);
    }

    public function get health () :Number
    {
        var base :PlayerBaseUnit = this.base;
        return (null != base ? base.health : 0);
    }

    public function get maxHealth () :Number
    {
        var base :PlayerBaseUnit = this.base;
        return (null != base ? base.maxHealth : 0);
    }

    public function get healthPercent () :Number
    {
        var base :PlayerBaseUnit = this.base;
        return (null != base ? base.health / base.maxHealth : 0);
    }

    public function get targetedEnemyId () :uint
    {
        return _targetedEnemyId;
    }

    public function set targetedEnemyId (val :uint) :void
    {
        _targetedEnemyId = val;
    }

    public function canPurchaseCreature (unitType :uint) :Boolean
    {
        return true;
    }

    public function creaturePurchased (unitType :uint) :void
    {
        // no-op
    }

    public function canCastSpell (spellType :uint) :Boolean
    {
        return true;
    }

    public function addSpell (spellType :uint, count :uint = 1) :void
    {
        // no-op
    }

    public function spellCast (spellType :uint) :void
    {
        // no-op
    }

    protected var _playerId :uint;  // an unsigned integer corresponding to the player's seating position
    protected var _teamId :uint;
    protected var _whirledId :int;  // the oid assigned to this player on Whirled
    protected var _playerName :String;
    protected var _leftGame :Boolean;
    protected var _targetedEnemyId :uint;
    protected var _baseRef :SimObjectRef;

    protected static var log :Log = Log.getLog(PlayerInfo);

}

}
