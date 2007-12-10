//
// $Id$

package ghostbusters {

import com.whirled.AVRGameControl;

public class GameModel
{
    public static const STATE_INTRO :String = "intro";
    public static const STATE_IDLE :String = "idle";
    public static const STATE_SEEKING :String = "seeking";
    public static const STATE_FIGHTING :String = "fighting";

    public function GameModel (control :AVRGameControl)
    {
        _control = control;

        _state = STATE_INTRO;
    }

    public function init (panel :GamePanel) :void
    {
        _panel = panel;
    }

    public function shutdown () :void
    {
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

    protected var _control :AVRGameControl;
    protected var _panel :GamePanel;
    protected var _state :String;
}
}
