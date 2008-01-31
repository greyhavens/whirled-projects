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
    }

    public function shutdown () :void
    {
    }

    public function newGhost (health :int) :void
    {
        Game.control.state.setProperty(Codes.PROP_GHOST_HEALTH, [ health, health ], false);
    }

    public function damageGhost (damage :int) :Boolean
    {
        var health :int = getGhostHealth();
        if (damage > health) {
            return true;
        }
        Game.control.state.setProperty(
            Codes.PROP_GHOST_HEALTH, [ health-damage, getGhostMaxHealth() ], false);
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
            return getGhostHealth() / max;
        }
        return 0;
    }

    protected function propertyChanged (evt :AVRGameControlEvent) :void
    {
        if (evt.name == Codes.PROP_GHOST_HEALTH) {
            // this is u-g-l-y
            Game.gameController.panel.hud.ghostHealthUpdated();
        }
    }

    protected var _panel :FightPanel;
}
}
