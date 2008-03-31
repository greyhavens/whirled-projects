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

        _ppp.setProperty(Game.ourPlayerId, Codes.PROP_PLAYER_MAX_HEALTH, 100);

        if (getPlayerHealth(Game.ourPlayerId) == 0 && !isPlayerDead(Game.ourPlayerId)) {
            // the player is new, not dead, start at full health
            _ppp.setProperty(Game.ourPlayerId, Codes.PROP_PLAYER_CUR_HEALTH, 100);
        }
    }

    public function get state () :String
    {
        var state :Object = Game.control.state.getRoomProperty(Codes.PROP_STATE);
        return (state is String) ? state as String : STATE_SEEKING;
    }

    public function isEverybodyDead () :Boolean
    {
        return checkTeam(true);
    }

    public function isEverybodyAlive () :Boolean
    {
        return checkTeam(false);
    }

    public function isPlayerDead (playerId :int) :Boolean
    {
        return _ppp.getProperty(playerId, Codes.PROP_PLAYER_CUR_HEALTH) == -1;
    }

    public function getPlayerHealth (playerId :int) :int
    {
        return Math.max(0, int(_ppp.getProperty(playerId, Codes.PROP_PLAYER_CUR_HEALTH)));
    }

    public function getPlayerMaxHealth (playerId :int) :int
    {
        return int(_ppp.getProperty(playerId, Codes.PROP_PLAYER_MAX_HEALTH));
    }

    public function setOurHealth (health :int) :void
    {
        _ppp.setProperty(Game.ourPlayerId, Codes.PROP_PLAYER_CUR_HEALTH,
                         Math.max(0, Math.min(health, getPlayerMaxHealth(Game.ourPlayerId))));
    }

    public function getPlayerRelativeHealth (playerId :int) :Number
    {
        var max :Number = getPlayerMaxHealth(playerId);
        if (max > 0) {
            return getPlayerHealth(playerId) / max;
        }
        return 1;
    }

    public function get ghostId () :String
    {
        return Game.control.state.getRoomProperty(Codes.PROP_GHOST_ID) as String;
    }

    public function isGhostDead () :Boolean
    {
        return Game.control.state.getRoomProperty(Codes.PROP_GHOST_CUR_HEALTH) === 0;
    }

    public function get ghostHealth () :int
    {
        return int(Game.control.state.getRoomProperty(Codes.PROP_GHOST_CUR_HEALTH));
    }

    public function get ghostMaxHealth () :int
    {
        return int(Game.control.state.getRoomProperty(Codes.PROP_GHOST_MAX_HEALTH));
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

    public function get ghostMaxZest () :Number
    {
        return Number(Game.control.state.getRoomProperty(Codes.PROP_GHOST_MAX_ZEST));
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

    protected function checkTeam (dead :Boolean) :Boolean
    {
        var team :Array = Game.getTeam(false);

        for (var ii :int = 0; ii < team.length; ii ++) {
            if (dead != isPlayerDead(team[ii])) {
                return false;
            }
        }
        return true;
    }

    protected var _ppp :PerPlayerProperties;
}
}
