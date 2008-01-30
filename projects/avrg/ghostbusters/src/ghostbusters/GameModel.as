//
// $Id$

package ghostbusters {

public class GameModel
{
    public static const STATE_NONE :String = "none";
    public static const STATE_INTRO :String = "intro";
    public static const STATE_IDLE :String = "idle";
    public static const STATE_SEEKING :String = "seeking";
    public static const STATE_FIGHTING :String = "fighting";

    public function GameModel ()
    {
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

    protected var _panel :GamePanel;
    protected var _state :String = STATE_NONE;
}
}
