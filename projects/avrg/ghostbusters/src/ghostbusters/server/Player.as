//
// $Id$

package ghostbusters.server {

import com.threerings.util.Log;

import com.whirled.net.MessageReceivedEvent;

import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.avrg.server.PlayerServerSubControl;

import ghostbusters.Codes;

import flash.utils.Dictionary;

public class Player
{
    public static var log :Log = Log.getLog(Player);

    public function Player (ctrl :PlayerServerSubControl)
    {
        _ctrl = ctrl;

        _ctrl.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, handleMessage);
        _ctrl.addEventListener(AVRGamePlayerEvent.ENTERED_ROOM, enteredRoom);
        _ctrl.addEventListener(AVRGamePlayerEvent.LEFT_ROOM, leftRoom);

        var playerData :Dictionary = Dictionary(_ctrl.props.get(Codes.PROP_PLAYER));
        if (playerData != null) {
            _health = playerData[Codes.PROP_PLAYER_CUR_HEALTH];
            _maxHealth = playerData[Codes.PROP_PLAYER_MAX_HEALTH];
        } else {
            // a new player! TODO: make this depend on level
            _health = _maxHealth = 100;
        }
    }

    public function get ctrl () :PlayerServerSubControl
    {
        return _ctrl;
    }

    public function get playerId () :int
    {
        return _ctrl.getPlayerId();
    }

    public function get health () :int
    {
        return _health;
    }

    public function get maxHealth () :int
    {
        return _maxHealth;
    }

    public function isDead () :Boolean
    {
        return _health == 0;
    }

    public function shutdown () :void
    {
        _ctrl.removeEventListener(AVRGamePlayerEvent.ENTERED_ROOM, enteredRoom);
        _ctrl.removeEventListener(AVRGamePlayerEvent.LEFT_ROOM, leftRoom);
    }

    protected function enteredRoom (evt :AVRGamePlayerEvent) :void
    {
        _room = Server.getRoom(int(evt.value));
        _room.playerEntered(this);
    }

    protected function leftRoom (evt :AVRGamePlayerEvent) :void
    {
        var evtRoom :Room = Server.getRoom(int(evt.value));
        if (evtRoom.roomId != _room.roomId) {
            log.warning("Unexpected leftRoom event [event.roomId=" +
                evtRoom.roomId + ", _roomId=" + _room.roomId + "]");
        }

        _room.playerLeft(this);
        _room = null;
    }

    protected function handleMessage (event: MessageReceivedEvent) :void
    {
        var msg :String = event.name;

        if (msg == Codes.MSG_GHOST_ZAP) {
            if (_room.checkState(Codes.STATE_SEEKING)) {
                _room.ghostZap();
            }

        } else if (msg == Codes.MSG_MINIGAME_RESULT) {
            if (_room.checkState(Codes.STATE_FIGHTING)) {
                var bits :Array = event.value as Array;
                if (bits != null) {
                    _room.minigameCompletion(this, Boolean(bits[0]), int(bits[1]), int(bits[2]));
                }
            }
        } else if (msg == Codes.MSG_PLAYER_REVIVE) {
            setHealth(Math.min(_maxHealth, _health + amount));
        }
    }

    public function damage (damage :int) :Boolean
    {
        log.debug("Doing " + damage + " damage to a player with health " + _health);

        // let the clients in the room know of the attack
        _room.ctrl.sendMessage(Codes.MSG_PLAYER_ATTACKED, playerId);

        if (damage >= health) {
            // the blow killed the player: let all the clients in the room know that too
            _room.ctrl.sendMessage(Codes.MSG_PLAYER_DEATH, playerId);
            setHealth(0);
            return true;
        }

        setHealth(_health - damage);
        return false;
    }

    public function heal (amount :int) :void
    {
        if (!isDead()) {
            setHealth(Math.min(_maxHealth, _health + amount));
        }
    }

    protected function setHealth (health :int) :void
    {
        _health = Math.max(0, Math.min(health, _maxHealth));

        _ctrl.props.setIn(Codes.PROP_PLAYER, Codes.PROP_PLAYER_CUR_HEALTH, _health);
    }

    protected var _ctrl :PlayerServerSubControl;
    protected var _room :Room;

    protected var _health :int;
    protected var _maxHealth :int;
}
}
