//
// $Id$

package ghostbusters.server {

import com.threerings.util.Log;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.avrg.server.PlayerServerSubControl;
import com.whirled.net.MessageReceivedEvent;

import ghostbusters.data.Codes;

public class Player
{
    public static var log :Log = Log.getLog(Player);

    public function Player (ctrl :PlayerServerSubControl)
    {
        _ctrl = ctrl;
        _playerId = ctrl.getPlayerId();

        _ctrl.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, handleMessage);
        _ctrl.addEventListener(AVRGamePlayerEvent.ENTERED_ROOM, enteredRoom);
        _ctrl.addEventListener(AVRGamePlayerEvent.LEFT_ROOM, leftRoom);

        _level = int(_ctrl.props.get(Codes.PROP_MY_LEVEL));
        if (_level == 0) {
            // this person has never played Ghosthunters before
            _level = 1;
            _ctrl.props.set(Codes.PROP_MY_LEVEL, _level, true);
            _health = _maxHealth = calculateMaxHealth();

        } else {
            _health = int(_ctrl.props.get(Codes.PROP_MY_HEALTH));
            _maxHealth = calculateMaxHealth();
        }
    }

    public function get ctrl () :PlayerServerSubControl
    {
        return _ctrl;
    }

    public function get playerId () :int
    {
        return _playerId;
    }

    public function get level () :int
    {
        return _level;
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

    public function damage (damage :int) :Boolean
    {
        log.debug("Doing " + damage + " damage to a player with health " + _health);

        // let the clients in the room know of the attack
        _room.ctrl.sendMessage(Codes.SMSG_PLAYER_ATTACKED, _playerId);

        if (damage >= health) {
            // the blow killed the player: let all the clients in the room know that too
            _room.ctrl.sendMessage(Codes.SMSG_PLAYER_DEATH, _playerId);
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

        // handle messages that make (at least some) sense even if we're between rooms
        if (msg == Codes.CMSG_PLAYER_REVIVE) {
            setHealth(_maxHealth);
        }

        // if we're nowhere, drop out
        if (_room == null) {
            return;
        }

        if (msg == Codes.CMSG_GHOST_ZAP) {
            if (_room.checkState(Codes.STATE_SEEKING)) {
                _room.ghostZap(this);
            }

        } else if (msg == Codes.CMSG_MINIGAME_RESULT) {
            if (_room.checkState(Codes.STATE_FIGHTING)) {
                var bits :Array = event.value as Array;
                if (bits != null) {
                    _room.minigameCompletion(this, Boolean(bits[0]), int(bits[1]), int(bits[2]));
                }
            }

        } else if (msg == Codes.CMSG_LANTERN_POS) {
            _room.updateLanternPos(_playerId, event.value as Array);
        }
    }

    protected function setHealth (health :int) :void
    {
        // update our runtime state
        _health = Math.max(0, Math.min(health, _maxHealth));

        // persist it, too
        _ctrl.props.set(Codes.PROP_MY_HEALTH, _health, true);

        // and if we're in a room, update the room properties
        if (_room != null) {
            _room.updatePlayerHealth(_playerId, _health);
        }
    }

    protected function calculateMaxHealth () :int
    {
        // level 1 has 1 health, after that a 25% gain per level
        return 100 * (Math.pow(1.25, _level));
    }

    protected var _ctrl :PlayerServerSubControl;
    protected var _room :Room;

    protected var _playerId :int;
    protected var _level :int;
    protected var _health :int;
    protected var _maxHealth :int;
}
}
