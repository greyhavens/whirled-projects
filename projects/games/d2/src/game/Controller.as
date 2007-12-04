package game {

import flash.events.Event;
import flash.geom.Point;    
import flash.geom.Rectangle;

import com.whirled.WhirledGameControl;

import units.Tower;
import units.Unit;

public class Controller
    implements UnloadListener
{
    public function Controller (main :Main, board :Board)
    {
        _board = board;
        _main = main;
        _whirled = main.whirled;
    }

    public function handleUnload () :void
    {
        trace("CONTROLLER UNLOAD");
    }

    public function playerReady () :void
    {
        _whirled.playerReady();
    }
    
    public function forceQuitGame (showLobby :Boolean = true) :void
    {
        _whirled.backToWhirled(showLobby);
    }
    
    public function requestAddTower (tower :Tower) :void
    {
        var serialized :Object = tower.serialize();
        serialized.guid = Unit.makeGuid(); // give the request a brand new guid
        _whirled.sendMessage(Validator.REQUEST_ADD, serialized);
    }

    public function updateSpawnerDifficulty (playerIndex :int, difficulty :int) :void
    {
        var serialized :Object = { playerIndex: playerIndex, difficulty: difficulty };
        _whirled.sendMessage(Monitor.SPAWNER_DIFFICULTY, serialized);
    }

    /** TODO
    public function removeTower (def :Tower) :void
    {
        // sends a request to everyone to remove a tower
    }

    public function updateTower (def :Tower) :void
    {
        // sends a request to everyone to update a tower
    }
    */
    
    public function readyToSpawn (playerId :int) :void
    {
        _whirled.set(Monitor.SPAWNERREADY, true, playerId);
    }

    public function changeScore (playerId :int, delta :Number) :void
    {
        // just change the score. we don't need to request it from the validator,
        // because there's no risk of contention. but only do this for this player.
        if (playerId == _main.myIndex) {
            var currentScore :Number = _whirled.get(Monitor.SCORE_SET, playerId) as Number;
            _whirled.set(Monitor.SCORE_SET, currentScore + delta, playerId);
        }
    }

    public function changeMoney (playerId :int, delta :Number) :void
    {
        // just change the money. 
        if (playerId == _main.myIndex) {
            var currentMoney :Number = _whirled.get(Monitor.MONEY_SET, playerId) as Number;
            _whirled.set(Monitor.MONEY_SET, currentMoney + delta, playerId);
        }
    }

    public function changeSpawnGroup (playerId :int, spawnGroup :int) :void
    {
        // only change this player's spawn group index
        if (playerId == _main.myIndex) {
            _whirled.set(Monitor.SPAWNGROUPS, spawnGroup, playerId);
        }
    }

    public function decrementHealth (attackerPlayer :int, targetPlayer :int) :void
    {
        // only decrement the score if this is single player, or if this client
        // is the one that succeeded in attacking the other
        if (_main.myIndex == 1 || attackerPlayer == _main.myIndex) {
            var currentHealth :Number = _whirled.get(Monitor.HEALTH_SET, targetPlayer) as Number;
            _whirled.set(Monitor.HEALTH_SET, currentHealth - 1, targetPlayer);
        }
    }

    public function playerLost (player :int) :void
    {
        if (player == _main.myIndex) {
            _whirled.sendMessage(Validator.REQUEST_END_ROUND, player);
        }
    }

    protected var _board :Board;
    protected var _main :Main;
    protected var _whirled :WhirledGameControl;
}
}
