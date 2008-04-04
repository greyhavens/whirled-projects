package popcraft {

import com.whirled.contrib.simplegame.SimObjectRef;

import popcraft.battle.PlayerBaseUnit;

/**
 * Encapsulates public information about a player in the game.
 */
public class PlayerData
{
    public function PlayerData (playerId :uint)
    {
        _playerId = playerId;
    }

    public function get playerId () :uint
    {
        return _playerId;
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
        return (null != this.base);
    }

    public function get targetedEnemyId () :uint
    {
        return _targetedEnemyId;
    }

    public function set targetedEnemyId (val :uint) :void
    {
        _targetedEnemyId = val;
    }

    protected var _playerId :uint;
    protected var _targetedEnemyId :uint;
    protected var _baseRef :SimObjectRef;

}

}
