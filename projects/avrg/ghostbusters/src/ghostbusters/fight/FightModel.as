//
// $Id$

package ghostbusters.fight {

import com.whirled.AVRGameControl;
import com.whirled.AVRGameControlEvent;

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
        _control.state.setProperty("gh", [ health, health ], false);
    }

    public function damageGhost (damage :int) :Boolean
    {
        var health :int = getGhostHealth();
        if (damage > health) {
            return true;
        }
        _control.state.setProperty("gh", [ health-damage, getGhostMaxHealth() ], false);
        return false;
    }

    public function getGhostHealth () :int
    {
        var gh :Object = _control.state.getProperty("gh");
        return gh != null ? gh[0] : 1;
    }

    public function getGhostMaxHealth () :Number
    {
        var gh :Object = _control.state.getProperty("gh");
        return gh != null ? gh[1] : 1;
    }

    protected function propertyChanged (evt :AVRGameControlEvent) :void
    {
        if (evt.name == "gh") {
            _panel.ghostHealthUpdated();
        }
    }

    protected var _control :AVRGameControl;
    protected var _panel :FightPanel;
}
}
