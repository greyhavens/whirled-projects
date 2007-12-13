//
// $Id$

package ghostbusters {

import com.whirled.AVRGameControl;
import com.whirled.AVRGameControlEvent;

public class GameModel
{
    public static const STATE_NONE :String = "none";
    public static const STATE_INTRO :String = "intro";
    public static const STATE_IDLE :String = "idle";
    public static const STATE_SEEKING :String = "seeking";
    public static const STATE_FIGHTING :String = "fighting";

    public function GameModel (control :AVRGameControl)
    {
        _control = control;

        _control.state.addEventListener(AVRGameControlEvent.PROPERTY_CHANGED, propertyChanged);
    }

    public function init (panel :GamePanel) :void
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

    public function getState () :String
    {
        return _state;
    }

    public function enterState (state :String) :void
    {
        Game.log.debug("Moving from [" + _state + "] to [" + state + "]");
        _state = state;
    }

    protected function propertyChanged (evt :AVRGameControlEvent) :void
    {
        if (evt.name == "gh") {
            _panel.ghostHealthUpdated(evt.value as Number);
        }
    }

    protected var _control :AVRGameControl;
    protected var _panel :GamePanel;
    protected var _state :String = STATE_NONE;
}
}
