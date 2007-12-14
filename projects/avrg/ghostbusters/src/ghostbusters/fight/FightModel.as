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

    public function getGhostHealth () :Number
    {
        return _control.state.getProperty("gh") as Number;
    }

    public function setGhostHealth (n :Number) :void
    {
        _control.state.setProperty("gh", n, false);
    }

    protected function propertyChanged (evt :AVRGameControlEvent) :void
    {
        if (evt.name == "gh") {
            _panel.ghostHealthUpdated(evt.value as Number);
        }
    }

    protected var _control :AVRGameControl;
    protected var _panel :FightPanel;
}
}
