//
// $Id$

package ghostbusters {

import com.threerings.util.Controller;
import com.whirled.AVRGameControl;

import ghostbusters.seek.SeekController;

public class GameController extends Controller
{
    public static const TOGGLE_LANTERN :String = "toggleLantern";
    public static const TOGGLE_LOOT :String = "toggleLoot";
    public static const END_GAME :String = "endGame";
    public static const HELP :String = "help";
    public static const PLAY :String = "play";

    public function GameController (control :AVRGameControl)
    {
        _control = control;

        _model = new GameModel(control);
        _panel = new GamePanel(_model);
        _model.init(_panel);

        setControlledPanel(_panel);

        _seekController = new SeekController(_control);
    }

    public function shutdown () :void
    {
        _panel.shutdown();
        _model.shutdown();
    }

    public function getGameModel () :GameModel
    {
        return _model;
    }

    public function getGamePanel () :GamePanel
    {
        return GamePanel(_controlledPanel);
    }

    public function handleHelp () :void
    {
        // TODO
    }

    public function handleToggleLoot () :void
    {
        // TODO
    }

    public function handleToggleLantern () :void
    {
        if (_model.getState() == GameModel.STATE_IDLE) {
            enterState(GameModel.STATE_SEEKING);

        } else if (_model.getState() == GameModel.STATE_SEEKING) {
            enterState(GameModel.STATE_SEEKING);
        }
        // else no effect
    }

    protected function enterState (state :String) :void
    {
        _model.enterState(state);
        getGamePanel().enterState(state);
    }

    protected var _control :AVRGameControl;
    protected var _model :GameModel;
    protected var _panel :GamePanel;

    protected var _seekController :SeekController;
}
}
