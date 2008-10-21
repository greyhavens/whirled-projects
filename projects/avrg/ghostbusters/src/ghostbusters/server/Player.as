//
// $Id$

package ghostbusters.server {

import com.threerings.util.Log;

import com.whirled.net.MessageReceivedEvent;

import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.avrg.PlayerSubControlServer;

import ghostbusters.data.Codes;
import ghostbusters.server.util.Formulae;

public class Player
{
    // avatar states
    public static const ST_PLAYER_DEFAULT :String = "Default";
    public static const ST_PLAYER_FIGHT :String = "Fight";
    public static const ST_PLAYER_DEFEAT :String = "Defeat";

    public static var log :Log = Log.getLog(Player);

    public function Player (ctrl :PlayerSubControlServer)
    {
        _ctrl = ctrl;
        _playerId = ctrl.getPlayerId();

        _ctrl.addEventListener(AVRGamePlayerEvent.ENTERED_ROOM, enteredRoom);
        _ctrl.addEventListener(AVRGamePlayerEvent.LEFT_ROOM, leftRoom);

        _level = int(_ctrl.props.get(Codes.PROP_MY_LEVEL));
        if (_level == 0) {
            // this person has never played Ghosthunters before
            log.info("Initializing new player", "playerId", playerId);
            setLevel(1, true);
            setHealth(_maxHealth, true);
            setPlaying(false, true);

        } else {
            updateMaxHealth();

            var playingValue :Object = _ctrl.props.get(Codes.PROP_IS_PLAYING);
            if (playingValue != null) {
                _playing = Boolean(playingValue);

            } else {
                log.debug("Repairing player isPlaying", "playerId", playerId);
                setPlaying(false, true);
            }

            var healthValue :Object = _ctrl.props.get(Codes.PROP_MY_HEALTH);
            if (healthValue != null) {
                _health = int(healthValue);

            } else {
                // health should always be set if level is set, but let's play it safe
                log.debug("Repairing player health", "playerId", playerId);
                setHealth(_maxHealth, true);
            }

            var pointsValue :Object = _ctrl.props.get(Codes.PROP_MY_POINTS);
            if (pointsValue != null) {
                _points = int(pointsValue);

            } else {
                log.debug("Repairing player ectopoints", "playerId", playerId);
                setPoints(0, true);
            }

            log.info("Logging in", "playerId", _playerId, "health", _health, "maxHealth",
                     _maxHealth, "points", _points);
        }
    }

    public function get ctrl () :PlayerSubControlServer
    {
        return _ctrl;
    }

    public function get playerId () :int
    {
        return _playerId;
    }

    public function get room () :Room
    {
        return _room;
    }

    public function get playing () :Boolean
    {
        return _playing;
    }

    public function get health () :int
    {
        return _health;
    }

    public function get maxHealth () :int
    {
        return _maxHealth;
    }

    public function get points () :int
    {
        return _points;
    }

    public function get level () :int
    {
        return _level;
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
        log.debug("Damaging player", "playerId", _playerId, "damage", damage, "health", _health);

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
        case Codes.CMSG_BEGIN_PLAYING:
            if (_playing) {
                log.warning("Saw BEGIN_PLAYING, but already am", "playerId", _playerId);
                return;
            }
            setPlaying(true);
            return;

        case Codes.CMSG_CHOOSE_AVATAR:
            if (_ctrl.props.get(Codes.PROP_AVATAR_TYPE) != null) {
                log.warning("Saw CHOOSE_AVATAR, but already chosen", "playerId", _playerId);
                return;
            }
            var prize :String;
            if (value == Codes.AVT_MALE) {
                prize = Codes.PRIZE_AVATAR_MALE;
            } else if (value == Codes.AVT_FEMALE) {
                prize = Codes.PRIZE_AVATAR_FEMALE;
            } else {
                log.warning("Saw CHOOSE_AVATAR with unexpected value", "playerId", playerId,
                            "value", value);
                return;
            }
            // remember the choice
            _ctrl.props.set(Codes.PROP_AVATAR_TYPE, value, true);
            // then award the avatar
            _ctrl.awardPrize(prize);
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
                _room.minigameCompletion(
                    this, int(value[0]), Boolean(value[1]), int(value[2]), int(value[3]));
            }

        } else if (name == Codes.CMSG_LANTERN_POS) {
            _room.updateLanternPos(_playerId, value as Array);
        }
    }

    // called from Room
    public function ghostDefeated (ectoPoints :Number, payoutFactor :Number) :void
    {
        setPoints(_points + ectoPoints);
        _ctrl.completeTask(Codes.TASK_GHOST_DEFEATED, payoutFactor);
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
            log.warning("Unknown debug request", "request", request);
            return;
        }

        // just send back the original request to indicate it was handled successfully
        ctrl.sendMessage(Codes.SMSG_DEBUG_RESPONSE, request);
    }

    protected function updateAvatarState () :void
    {
        if (_room == null) {
            return;
        }
        if (isDead()) {
            _ctrl.setAvatarState(ST_PLAYER_DEFEAT);

        } else if (_room.state == Codes.STATE_SEEKING || _room.state == Codes.STATE_APPEARING) {
            _ctrl.setAvatarState(ST_PLAYER_DEFAULT);

        } else {
            _ctrl.setAvatarState(ST_PLAYER_FIGHT);
        }
    }

    protected function setLevel (level :int, force :Boolean = false) :void
    {
        // clamp level to [1, 9] for now
        level = Math.max(1, Math.min(9, level));
        if (!force && level == _level) {
            return;
        }

        _level = level;
        _ctrl.props.set(Codes.PROP_MY_LEVEL, _level, true);

        // update our max health
        updateMaxHealth();

        // heal us, too
        heal(_maxHealth);

        // if we're in a room, update the room properties
        if (_room != null) {
            _room.playerUpdated(this);
        }
    }

    protected function setPlaying (playing :Boolean, force :Boolean = false) :void
    {
        if (!force && playing == _playing) {
            return;
        }
        _playing = playing;

        _ctrl.props.set(Codes.PROP_IS_PLAYING, _playing, true);
    }

    protected function setHealth (health :int, force :Boolean = false) :void
    {
        // update our runtime state
        health = Math.max(0, Math.min(health, _maxHealth));
        if (!force && health == _health) {
            return;
        }

        _health = health;

        // persist it, too
        _ctrl.props.set(Codes.PROP_MY_HEALTH, _health, true);

        // if we just died, let the trophy code know
        if (_health == 0) {
            Trophies.handlePlayerDied(this);
        }

        // always update our avatar state
        updateAvatarState();

        // and if we're in a room, update the room properties
        if (_room != null) {
            _room.playerUpdated(this);
        }
    }

    protected function setPoints (points :int, force :Boolean = false) :void
    {
        if (!force && points == _points) {
            return;
        }

        while (points >= 100) {
            setLevel(_level + 1);
            points -= 100;
        }

        _points = points;
        _ctrl.props.set(Codes.PROP_MY_POINTS, _points, true);
    }

    protected function updateMaxHealth () :void
    {
        // a level 1 player has 50 health
        _maxHealth = 50 * Formulae.quadRamp(_level);
    }

    protected var _ctrl :PlayerSubControlServer;
    protected var _room :Room;

    protected var _playing :Boolean;
    protected var _playerId :int;
    protected var _health :int;
    protected var _maxHealth :int;
    protected var _points :int;
    protected var _level :int;
}
}
