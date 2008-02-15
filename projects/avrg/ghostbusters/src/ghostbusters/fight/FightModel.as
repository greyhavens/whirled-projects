//
// $Id$

package ghostbusters.fight {

import com.whirled.AVRGameControl;
import com.whirled.AVRGameControlEvent;

import ghostbusters.Codes;
import ghostbusters.Game;

public class FightModel
{
    public function FightModel ()
    {
        Game.control.state.addEventListener(AVRGameControlEvent.PROPERTY_CHANGED, propertyChanged);
    }

    public function init (panel :FightPanel) :void
    {
        _panel = panel;

        var health :int = 100;
        Game.control.state.setProperty(Codes.PROP_GHOST_HEALTH, [ health, health ], false);
        Game.control.state.setProperty(Codes.PROP_PLAYER_HEALTH, [ health, health ], false);
    }

    public function shutdown () :void
    {
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
    public function damagePlayer (damage :int) :Boolean
    {
        var health :int = getPlayerHealth();
        Game.log.debug("Doing " + damage + " damage to a player with health " + health);
        if (damage > health) {
            return true;
        }
        Game.control.state.setProperty(
            Codes.PROP_PLAYER_HEALTH, [ health-damage, getPlayerMaxHealth() ], false);
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

    public function getPlayerHealth () :int
    {
        var gh :Object = Game.control.state.getProperty(Codes.PROP_PLAYER_HEALTH);
        return gh != null ? gh[0] : 1;
    }

    public function getPlayerMaxHealth () :Number
    {
        var gh :Object = Game.control.state.getProperty(Codes.PROP_PLAYER_HEALTH);
        return gh != null ? gh[1] : 1;
    }

    public function getRelativePlayerHealth () :Number
    {
        var max :Number = getPlayerMaxHealth();
        if (max > 0) {
            return Math.max(0, Math.min(1, getPlayerHealth() / max));
        }
        return 0;
    }

    protected function propertyChanged (evt :AVRGameControlEvent) :void
    {
        if (evt.name == Codes.PROP_GHOST_HEALTH) {
            // this is u-g-l-y
            Game.gameController.panel.hud.ghostHealthUpdated();

        } else if (evt.name == Codes.PROP_PLAYER_HEALTH) {
            // this is u-g-l-y
            Game.gameController.panel.hud.playerHealthUpdated();
        }
    }

    protected var _panel :FightPanel;
}
}
