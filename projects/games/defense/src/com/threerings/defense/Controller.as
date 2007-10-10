package com.threerings.defense {

import flash.events.Event;
import flash.geom.Point;    
import flash.geom.Rectangle;

import com.whirled.WhirledGameControl;

import com.threerings.defense.units.Tower;
import com.threerings.defense.units.Unit;

public class Controller
{
    public function Controller (board :Board, whirled :WhirledGameControl)
    {
        _board = board;
        _whirled = whirled;
    }

    public function handleUnload (event : Event) :void
    {
        trace("CONTROLLER UNLOAD");
    }

    public function playerReady () :void
    {
        _whirled.playerReady();
    }
    
    public function forceQuitGame () :void
    {
        _whirled.backToWhirled();
    }
    
    public function requestAddTower (tower :Tower) :void
    {
        var serialized :Object = tower.serialize();
        serialized.guid = Unit.makeGuid(); // give the request a brand new guid
        _whirled.sendMessage(Validator.REQUEST_ADD, serialized);
    }

    public function removeTower (/* def :Tower */) :void
    {
        // sends a request to everyone to remove a tower
    }

    public function updateTower (/* def :Tower */) :void
    {
        // sends a request to everyone to update a tower
    }

    public function changeScore (playerId :int, delta :Number) :void
    {
        // just change the score. we don't need to request it from the validator,
        // because there's no risk of contention. but only do this for this player.
        if (playerId == _board.getMyPlayerIndex()) {
            var currentScore :Number = _whirled.get(Monitor.SCORE_SET, playerId) as Number;
            _whirled.set(Monitor.SCORE_SET, currentScore + delta, playerId);
        }
    }

    public function changeMoney (playerId :int, delta :Number) :void
    {
        // just change the money. 
        if (playerId == _board.getMyPlayerIndex()) {
            var currentMoney :Number = _whirled.get(Monitor.MONEY_SET, playerId) as Number;
            _whirled.set(Monitor.MONEY_SET, currentMoney + delta, playerId);
        }
    }

    public function decrementHealth (attackerPlayer :int, targetPlayer :int) :void
    {
        // only decrement the score if this is single player, or if this client
        // is the one that succeeded in attacking the other
        if (_board.getPlayerCount() == 1 || attackerPlayer == _board.getMyPlayerIndex()) {
            var currentHealth :Number = _whirled.get(Monitor.HEALTH_SET, targetPlayer) as Number;
            _whirled.set(Monitor.HEALTH_SET, currentHealth - 1, targetPlayer);
        }
    }

    public function playerLost (player :int) :void
    {
        if (player == _board.getMyPlayerIndex()) {
            _whirled.sendMessage(Validator.REQUEST_END_ROUND, player);
        }
    }

    protected var _board :Board;
    protected var _whirled :WhirledGameControl;
}
}
