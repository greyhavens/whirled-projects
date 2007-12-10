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

    public static function newController (control :AVRGameControl) :GameController
    {
        var model :GameModel = new GameModel(control);
        var panel :GamePanel = new GamePanel(model);
        return new GameController(control, panel, model);
    }

    public function GameController (control :AVRGameControl, panel :GamePanel, model :GameModel)
    {
        _control = control;
        _model = model;
        setControlledPanel(panel);

        _seekController = SeekController.newController(_control);
    }

    public function shutdown () :void
    {
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

    protected var _seekController :SeekController;
}
}
