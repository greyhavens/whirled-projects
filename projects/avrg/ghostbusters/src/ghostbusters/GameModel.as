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
//        Game.control.state.addEventListener(
//            AVRGameControlEvent.ROOM_PROPERTY_CHANGED, roomPropertyChanged);

        _ghostRandom = new Random(Game.ourRoomId);
    }

    public function newRoom () :void
    {
        if (Game.control.hasControl() && this.ghostZest == 0) {
            // initialize the room with a ghost

            ghostZest = ghostMaxZest = 150 + 100 * _ghostRandom.nextNumber();

            var health :int = 100;
//            ghostHealth = [ health, health ];

        }
    }

    public function init () :void
    {
        // TODO: nuke
//        playerHealth = [ health, health ];
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

    public function getCurrentHealth (playerId :int) :Number
    {
        return Number(Game.control.state.getProperty("curHealth:" + playerId));
    }

    public function getMaxHealth (playerId :int) :Number
    {
        return Number(Game.control.state.getProperty("maxHealth:" + playerId));
    }

    public function getRelativeHealth (playerId :int) :Number
    {
        var max :Number = getMaxHealth(playerId);
        if (max > 0) {
            return getCurrentHealth(playerId) / max;
        }
        return 0;
    }

    public function damageGhost (damage :int) :Boolean
    {
        var health :int = getGhostHealth();
        Game.log.debug("Doing " + damage + " damage to a ghost with health " + health);
        if (damage > health) {
            return true;
        }
        Game.control.state.setProperty(
            Codes.PROP_GHOST_HEALTH, [ health-damage, getGhostMaxHealth() ], false);
        return false;
    }

    // TODO: this should obviously not be single-player :)
    public function damagePlayer (playerId :int, damage :int) :Boolean
    {
        var health :int = getCurrentHealth(playerId);
        Game.log.debug("Doing " + damage + " damage to a player with health " + health);
        if (damage > health) {
            return true;
        }
        Game.control.state.setProperty(
            Codes.PROP_PLAYER_HEALTH, [ health-damage, getMaxHealth(playerId) ], false);
        return false;
    }

    public function getGhostHealth () :int
    {
        var gh :Object = Game.control.state.getProperty(Codes.PROP_GHOST_HEALTH);
        return gh != null ? gh[0] : 1;
    }

    public function getGhostMaxHealth () :Number
    {
        var gh :Object = Game.control.state.getProperty(Codes.PROP_GHOST_HEALTH);
        return gh != null ? gh[1] : 1;
    }

    public function getRelativeGhostHealth () :Number
    {
        var max :Number = getGhostMaxHealth();
        if (max > 0) {
            return Math.max(0, Math.min(1, getGhostHealth() / max));
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

    protected var _ghostRandom :Random;
}
}
