//
// $Id$

package ghostbusters {

import com.threerings.util.Controller;
import com.whirled.AVRGameControl;
import com.whirled.AVRGameControlEvent;
import com.whirled.MobControl;

import ghostbusters.fight.FightController;
import ghostbusters.seek.SeekController;

import flash.display.DisplayObject;

public class GameController extends Controller
{
    public static const END_FIGHT :String = "EndFight";
    public static const SPAWN_GHOST :String = "SpawnGhost";
    public static const TOGGLE_LANTERN :String = "ToggleLantern";
    public static const TOGGLE_LOOT :String = "ToggleLoot";
    public static const END_GAME :String = "EndGame";
    public static const HELP :String = "Help";
    public static const PLAY :String = "Play";

    public function GameController (control :AVRGameControl)
    {
        _control = control;

        _seekController = new SeekController(control);
        _fightController = new FightController(control);

        _model = new GameModel(control);
        var panel :GamePanel = new GamePanel(
            _model, _seekController.getSeekPanel(), _fightController.getFightPanel());
        _model.init(panel);
        setControlledPanel(panel);

        _control.state.addEventListener(AVRGameControlEvent.MESSAGE_RECEIVED, messageReceived);
    }

    public function shutdown () :void
    {
        getGamePanel().shutdown();
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

    public function exportMobSprite (id :String, ctrl :MobControl) :DisplayObject
    {
        if (id == "ghost") {
            return _fightController.getFightPanel().getGhostSprite(ctrl);
        }
        Game.log.warning("Unknown MOB requested [id=" + id + "]");
        return null;
    }

    public function handleHelp () :void
    {
        // TODO
    }

    public function handleToggleLoot () :void
    {
        handleSpawnGhost();
    }

    public function handlePlay () :void
    {
        enterState(GameModel.STATE_IDLE);
    }

    public function handleToggleLantern () :void
    {
        if (_model.getState() == GameModel.STATE_IDLE) {
            enterState(GameModel.STATE_SEEKING);

        } else if (_model.getState() == GameModel.STATE_SEEKING) {
            enterState(GameModel.STATE_IDLE);
        }
        // else no effect
    }

    public function handleSpawnGhost () :void
    {
        enterState(GameModel.STATE_FIGHTING);
        _control.state.sendMessage("gs", null);
        _fightController.doSpawnGhost();
    }

    public function handleEndFight () :void
    {
        enterState(GameModel.STATE_IDLE);
    }

    public function enterState (state :String) :void
    {
        var current :String = _model.getState();

        if (state == GameModel.STATE_NONE) {
            // we should never transition to NONE
            checkTransition(state);

        } else if (state == GameModel.STATE_INTRO) {
            // we should only go to intro once, from none
            checkTransition(state, GameModel.STATE_NONE);

        } else if (state == GameModel.STATE_IDLE) {
            // forward from the intro or return from seeking or fighting
            checkTransition(state, GameModel.STATE_INTRO, GameModel.STATE_SEEKING,
                            GameModel.STATE_FIGHTING);

        } else if (state == GameModel.STATE_SEEKING) {
            // forward from idle
            checkTransition(state, GameModel.STATE_IDLE);

        } else if (state == GameModel.STATE_FIGHTING) {
            // forward from idle or seeking
            checkTransition(state, GameModel.STATE_IDLE, GameModel.STATE_SEEKING);

        } else {
            Game.log.warning("Unknown state requested; ignored [request=" + state + "]");
            return;
        }

        _model.enterState(state);
        getGamePanel().enterState(state);
    }

    protected function checkTransition(requested :String, ... allowed) :Boolean
    {
        var current :String = _model.getState();
        for (var ii :int = 0; ii < allowed.length; ii ++) {
            if (allowed[ii] == current) {
                return true;
            }
        }
        Game.log.debug("Dubious state transition, but letting it pass [current=" + current +
                       ", requested=" + requested);
        return false;
    }

    protected function messageReceived (event: AVRGameControlEvent) :void
    {
        if (event.name == "gs" && _model.getState() != GameModel.STATE_FIGHTING) {
            enterState(GameModel.STATE_FIGHTING);
        }
    }

    protected var _control :AVRGameControl;
    protected var _model :GameModel;

    protected var _seekController :SeekController;
    protected var _fightController :FightController;
}
}
