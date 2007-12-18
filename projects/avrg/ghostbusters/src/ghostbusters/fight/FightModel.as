//
// $Id$

package ghostbusters.fight {

import com.whirled.AVRGameControl;
import com.whirled.AVRGameControlEvent;

import ghostbusters.Codes;

public class FightModel
{
    public function FightModel (control :AVRGameControl)
    {
        _control = control;

        _control.state.addEventListener(AVRGameControlEvent.PROPERTY_CHANGED, propertyChanged);
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
        _control.state.setProperty(Codes.PROP_GHOST_HEALTH, [ health, health ], false);
    }

    public function damageGhost (damage :int) :Boolean
    {
        var health :int = getGhostHealth();
        if (damage > health) {
            return true;
        }
        _control.state.setProperty(
            Codes.PROP_GHOST_HEALTH, [ health-damage, getGhostMaxHealth() ], false);
        return false;
    }

    public function getGhostHealth () :int
    {
        var gh :Object = _control.state.getProperty(Codes.PROP_GHOST_HEALTH);
        return gh != null ? gh[0] : 1;
    }

    public function getGhostMaxHealth () :Number
    {
        var gh :Object = _control.state.getProperty(Codes.PROP_GHOST_HEALTH);
        return gh != null ? gh[1] : 1;
    }

    protected function propertyChanged (evt :AVRGameControlEvent) :void
    {
        if (evt.name == Codes.PROP_GHOST_HEALTH) {
            _panel.ghostHealthUpdated();
        }
    }

    protected var _control :AVRGameControl;
    protected var _panel :FightPanel;
}
}
