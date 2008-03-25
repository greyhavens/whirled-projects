//
// $Id$

package ghostbusters {

import flash.geom.Point;
import flash.geom.Rectangle;

import com.whirled.AVRGameControlEvent;

import com.threerings.util.Random;

public class GameModel
{
    public static const STATE_SEEKING :String = "seeking";
    public static const STATE_APPEARING :String = "appearing";
    public static const STATE_FIGHTING :String = "fighting";
    public static const STATE_GHOST_TRIUMPH :String = "triumph";
    public static const STATE_GHOST_DEFEAT :String = "defeat";

    public function GameModel ()
    {
        _ppp = new PerPlayerProperties();

        // TODO: fix resurrection
        if (getPlayerHealth(Game.ourPlayerId) == 0) {
            _ppp.setProperty(Game.ourPlayerId, Codes.PROP_PLAYER_MAX_HEALTH, 100);
            _ppp.setProperty(Game.ourPlayerId, Codes.PROP_PLAYER_CUR_HEALTH, 100);
        }
    }

    public function init () :void
    {
    }

    public function shutdown () :void
    {
    }

    public function get state () :String
    {
        var state :Object = Game.control.state.getRoomProperty(Codes.PROP_STATE);
        return (state is String) ? state as String : STATE_SEEKING;
    }

    public function set state (state :String) :void
    {
        Game.control.state.setRoomProperty(Codes.PROP_STATE, state);
    }

    public function isEverybodyDead () :Boolean
    {
        var team :Array = Game.getTeam(true);

        for (var ii :int = 0; ii < team.length; ii ++) {
            if (!isPlayerDead(team[ii])) {
                return false;
            }
        }
        return true;
    }

    public function isPlayerDead (playerId :int) :Boolean
    {
        return _ppp.getProperty(playerId, Codes.PROP_PLAYER_CUR_HEALTH) === 0;
    }

    public function getPlayerHealth (playerId :int) :int
    {
        return int(_ppp.getProperty(playerId, Codes.PROP_PLAYER_CUR_HEALTH));
    }

    public function getPlayerMaxHealth (playerId :int) :int
    {
        return int(_ppp.getProperty(playerId, Codes.PROP_PLAYER_MAX_HEALTH));
    }

    public function setPlayerHealth (playerId :int, health :int) :void
    {
        _ppp.setProperty(playerId, Codes.PROP_PLAYER_CUR_HEALTH,
                        Math.max(0, Math.min(health, getPlayerMaxHealth(playerId))));
    }

    public function getPlayerRelativeHealth (playerId :int) :Number
    {
        var max :Number = getPlayerMaxHealth(playerId);
        if (max > 0) {
            return getPlayerHealth(playerId) / max;
        }
        return 1;
    }

    public function damageGhost (damage :int) :Boolean
    {
        var health :int = ghostHealth;
        Game.log.debug("Doing " + damage + " damage to a ghost with health " + health);
        if (damage > health) {
            ghostHealth = 0;
            return true;
        }
        ghostHealth -= damage;
        return false;
    }

    public function damagePlayer (playerId :int, damage :int) :Boolean
    {
        var health :int = getPlayerHealth(playerId);
        Game.log.debug("Doing " + damage + " damage to a player with health " + health);
        if (damage > health) {
            setPlayerHealth(playerId, 0);
            return true;
        }
        setPlayerHealth(playerId, health - damage);
        return false;
    }

    public function get ghostId () :String
    {
        return Game.control.state.getRoomProperty(Codes.PROP_GHOST_ID) as String;
    }

    public function set ghostId (id :String) :void
    {
        Game.control.state.setRoomProperty(Codes.PROP_GHOST_ID, id);
    }

    public function isGhostDead () :Boolean
    {
        return Game.control.state.getRoomProperty(Codes.PROP_GHOST_CUR_HEALTH) === 0;
    }

    public function get ghostHealth () :int
    {
        return int(Game.control.state.getRoomProperty(Codes.PROP_GHOST_CUR_HEALTH));
    }

    public function set ghostHealth (health :int) :void
    {
        Game.control.state.setRoomProperty(Codes.PROP_GHOST_CUR_HEALTH, Math.max(0, health));
    }

    public function get ghostMaxHealth () :int
    {
        return int(Game.control.state.getRoomProperty(Codes.PROP_GHOST_MAX_HEALTH));
    }

    public function set ghostMaxHealth (health :int) :void
    {
        Game.control.state.setRoomProperty(Codes.PROP_GHOST_MAX_HEALTH, Math.max(0, health));
    }

    public function get ghostRelativeHealth () :Number
    {
        var max :Number = ghostMaxHealth;
        if (max > 0) {
            return Math.max(0, Math.min(1, ghostHealth / max));
        }
        return 0;
    }

    public function get ghostZest () :Number
    {
        return Number(Game.control.state.getRoomProperty(Codes.PROP_GHOST_CUR_ZEST));
    }

    public function set ghostZest (zest :Number) :void
    {
        Game.control.state.setRoomProperty(Codes.PROP_GHOST_CUR_ZEST, Math.max(0, zest));
    }

    public function get ghostMaxZest () :Number
    {
        return Number(Game.control.state.getRoomProperty(Codes.PROP_GHOST_MAX_ZEST));
    }

    public function set ghostMaxZest (zest :Number) :void
    {
        Game.control.state.setRoomProperty(Codes.PROP_GHOST_MAX_ZEST, Math.max(0, zest));
    }

    public function get ghostRelativeZest () :Number
    {
        return Math.max(0, Math.min(1, ghostZest / ghostMaxZest));
    }

    public function getGhostData () :Object
    {
        var id :String = ghostId;
        if (id == null) {
            Game.log.warning("getGhostData() called with ghostId=" + id);
            return null;
        }
        var ghosts :Array = Content.GHOSTS;
        for (var ii :int = 0; ii < ghosts.length; ii ++) {
            if (ghosts[ii].id == id) {
                return ghosts[ii];
            }
        }
        throw new Error("Erk, ghost not found somehow [id=" + id + "]");
    }

    protected var _ppp :PerPlayerProperties;
}
}
