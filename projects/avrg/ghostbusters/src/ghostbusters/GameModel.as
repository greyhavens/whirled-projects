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
    public static const STATE_FIGHTING :String = "fighting";

    public function GameModel ()
    {
        _pp = new PropertyListener();
    }

    public function newRoom () :void
    {
        maybeSpawnGhost();
    }

    // TODO: this should be called on a timer, too
    protected void maybeSpawnGhost () :void
    {
        if (!Game.control.hasControl() || ghostId != null) {
            return;
        }

        // initialize the room with a ghost
        _ghostId = Content.GHOSTS[Game.random.nextInt(Content.GHOSTS.length)].id;
        log.debug("Choosing ghost [id=" + _ghostId = "]");

        ghostZest = ghostMaxZest = 150 + 100 * Game.random.nextNumber();
        ghostHealth = ghostMaxHealth = 100;
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

    public function getPlayerHealth (playerId :int) :int
    {
        return int(_pp.getProperty(playerId, Codes.PROP_PLAYER_CUR_HEALTH));
    }

    public function getPlayerMaxHealth (playerId :int) :int
    {
        return int(_pp.getProperty(playerId, Codes.PROP_PLAYER_MAX_HEALTH));
    }

    public function setPlayerHealth (playerId :int, health :int) :void
    {
        _pp.setProperty(playerId, Codes.PROP_PLAYER_CUR_HEALTH, health);
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
            return true;
        }
        setPlayerHealth(playerId, health - damage);
        return false;
    }

    public function get ghostHealth () :int
    {
        return int(Game.control.state.getProperty(Codes.PROP_GHOST_CUR_HEALTH));
    }

    public function set ghostHealth (health :int) :void
    {
        Game.control.state.setProperty(Codes.PROP_GHOST_CUR_HEALTH, Math.max(0, health));
    }

    public function get ghostMaxHealth () :int
    {
        return int(Game.control.state.getProperty(Codes.PROP_GHOST_MAX_HEALTH));
    }

    public function set ghostMaxHealth (health :int) :void
    {
        Game.control.state.setProperty(Codes.PROP_GHOST_MAX_HEALTH, Math.max(0, health));
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
        return Number(Game.control.state.getRoomProperty(Codes.PROP_GHOST_CUR_ZEST));
    }

    public function set ghostMaxZest (zest :Number) :void
    {
        Game.control.state.setRoomProperty(Codes.PROP_GHOST_MAX_ZEST, Math.max(0, zest));
    }

    public function get ghostRelativeZest () :Number
    {
        return Math.max(0, Math.min(1, ghostZest / ghostMaxZest));
    }

    protected var _pp :PropertyListener;
}
}
