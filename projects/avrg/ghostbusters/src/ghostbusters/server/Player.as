//
// $Id$

package ghostbusters.server {

import com.threerings.util.Log;

import com.whirled.net.MessageReceivedEvent;

import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.avrg.PlayerServerSubControl;

import ghostbusters.data.Codes;
import ghostbusters.server.util.Formulae;

public class Player
{
    // avatar states
    public static const ST_PLAYER_DEFAULT :String = "Default";
    public static const ST_PLAYER_FIGHT :String = "Fight";
    public static const ST_PLAYER_DEFEAT :String = "Defeat";

    public static var log :Log = Log.getLog(Player);

    public function Player (ctrl :PlayerServerSubControl)
    {
        _ctrl = ctrl;
        _playerId = ctrl.getPlayerId();

        _ctrl.addEventListener(AVRGamePlayerEvent.ENTERED_ROOM, enteredRoom);
        _ctrl.addEventListener(AVRGamePlayerEvent.LEFT_ROOM, leftRoom);

        _level = int(_ctrl.props.get(Codes.PROP_MY_LEVEL));
        if (_level == 0) {
            // this person has never played Ghosthunters before
            log.info("Initializing new player [playerId=" + playerId + "]");
            setLevel(1);
            _maxHealth = calculateMaxHealth();
            setHealth(_maxHealth);

        } else {
            _maxHealth = calculateMaxHealth();

            var healthValue :Object = _ctrl.props.get(Codes.PROP_MY_HEALTH);
            if (healthValue != null) {
                log.info("Logging in existing player [playerId=" + playerId + "]");
                _health = int(healthValue);

            } else {
                // health should always be set if level is set, but let's play it safe
                log.debug("Repairing broken player [playerId=" + playerId + "]");
                setHealth(_maxHealth);
            }
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

    public function damage (damage :int) :void
    {
        log.debug("Doing " + damage + " damage to a player with health " + _health);

        // let the clients in the room know of the attack
        _room.ctrl.sendMessage(Codes.SMSG_PLAYER_ATTACKED, _playerId);
        // play the reel animation for ourselves!
        _ctrl.playAvatarAction("Reel");

        setHealth(health - damage); // note: setHealth clamps this to [0, maxHealth]
    }

    public function heal (amount :int) :void
    {
        if (!isDead()) {
            setHealth(_health + amount); // note: setHealth clamps this to [0, maxHealth]
        }
    }

    public function roomStateChanged () :void
    {
        updateAvatarState();
    }

    // called from Server
    public function handleMessage (name :String, value :Object) :void
    {
        // handle messages that make (at least some) sense even if we're between rooms
        switch(name) {
        case Codes.CMSG_PLAYER_REVIVE:
            setHealth(_maxHealth);
            return;
        case Codes.CMSG_DEBUG_REQUEST:
            if (Server.isAdmin(_playerId)) {
                handleDebugRequest(String(value));
            }
            return;
        }

        // if we're nowhere, drop out
        if (_room == null) {
            return;
        }

        if (name == Codes.CMSG_GHOST_ZAP) {
            if (_room.checkState(Codes.STATE_SEEKING)) {
                _room.ghostZap(this);
            }

        } else if (name == Codes.CMSG_MINIGAME_RESULT) {
            if (_room.checkState(Codes.STATE_FIGHTING)) {
                _room.minigameCompletion(this, Boolean(value[0]), int(value[1]), int(value[2]));
            }

        } else if (name == Codes.CMSG_LANTERN_POS) {
            _room.updateLanternPos(_playerId, value as Array);
        }
    }

    protected function enteredRoom (evt :AVRGamePlayerEvent) :void
    {
        var thisPlayer :Player = this;
        _room = Server.getRoom(int(evt.value));
        Server.control.doBatch(function () :void {
            _room.playerEntered(thisPlayer);
            updateAvatarState();
        });
    }

    protected function leftRoom (evt :AVRGamePlayerEvent) :void
    {
        var thisPlayer :Player = this;
        Server.control.doBatch(function () :void {
            _room.playerLeft(thisPlayer);
        });
        _room = null;
    }

    protected function handleDebugRequest (request :String) :void
    {
        switch(request) {
        case Codes.DBG_GIMME_PANEL:
            break;
        case Codes.DBG_LEVEL_UP:
            setLevel(_level + 1);
            break;
        case Codes.DBG_LEVEL_DOWN:
            setLevel(_level - 1);
            break;
        case Codes.DBG_RESET_ROOM:
            if (_room != null) {
                _room.reset();
            }
            break;
        case Codes.DBG_END_STATE:
            if (_room != null) {
                switch(_room.state) {
                case Codes.STATE_SEEKING:
                case Codes.STATE_APPEARING:
                    _room.setState(Codes.STATE_FIGHTING);
                    break;
                case Codes.STATE_FIGHTING:
                case Codes.STATE_GHOST_TRIUMPH:
                case Codes.STATE_GHOST_DEFEAT:
                    _room.setState(Codes.STATE_SEEKING);
                    break;
                }
            }
            break;
        default:
            log.warning("Unknown debug requests: " + request);
            return;
        }

        // just send back the original request to indicate it was handled successfully
        ctrl.sendMessage(Codes.SMSG_DEBUG_RESPONSE, request);
    }

    protected function updateAvatarState () :void
    {
        if (isDead()) {
            _ctrl.setAvatarState(ST_PLAYER_DEFEAT);

        } else if (_room.state == Codes.STATE_SEEKING || _room.state == Codes.STATE_APPEARING) {
            _ctrl.setAvatarState(ST_PLAYER_DEFAULT);

        } else {
            _ctrl.setAvatarState(ST_PLAYER_FIGHT);
        }
    }

    protected function setLevel (level :int) :void
    {
        // clamp level to [1, 9] for now
        level = Math.max(1, Math.min(9, level));
        if (level == _level) {
            return;
        }

        _level = level;
        _ctrl.props.set(Codes.PROP_MY_LEVEL, _level, true);

        // we'll probably need to add this to the room properties at some point, but not yet
    }

    protected function setHealth (health :int) :void
    {
        // update our runtime state
        health = Math.max(0, Math.min(health, _maxHealth));
        if (health == _health) {
            return;
        }

        _health = health;

        // persist it, too
        _ctrl.props.set(Codes.PROP_MY_HEALTH, _health, true);

        // if we just died, update our state
        if (_health == 0) {
            _ctrl.setAvatarState(ST_PLAYER_DEFEAT);
        }

        // and if we're in a room, update the room properties
        if (_room != null) {
            _room.playerHealthUpdated(this);
        }
    }

    protected function calculateMaxHealth () :int
    {
        // a level 1 player has 100 health
        return 100 * Formulae.quadRamp(_level);
    }

    protected var _ctrl :PlayerServerSubControl;
    protected var _room :Room;

    protected var _playerId :int;
    protected var _level :int;
    protected var _health :int;
    protected var _maxHealth :int;
}
}
