//
// $Id$

package ghostbusters.fight {

import flash.display.Sprite;
import flash.events.MouseEvent;

import com.threerings.util.CommandEvent;
import com.threerings.util.Controller;
import com.whirled.AVRGameControl;

import ghostbusters.GameController;

public class FightController extends Controller
{
    public static const GHOST_MELEE :String = "GhostMelee";

    public function FightController (control :AVRGameControl)
    {
        _control = control;

        _model = new FightModel(control);
        var panel :FightPanel = new FightPanel(_model);
        _model.init(panel);

        setControlledPanel(panel);
    }

    public function shutdown () :void
    {
    }

    public function getFightPanel () :FightPanel
    {
        return FightPanel(_controlledPanel);
    }

    public function doSpawnGhost () :void
    {
        _control.state.sendMessage("gs", null);
        _model.setGhostHealth(1.0);
        _control.spawnMob("ghost", "Duchess Von Bobbleton");
    }

    public function handleGhostMelee (score :Number) :void
    {
        var currentHealth :Number = _model.getGhostHealth();
        if (currentHealth > 0.03) {
            // we can't do this properly without control (or server side bits)
            _model.setGhostHealth(currentHealth - 0.03);

        } else {
            // TODO: something a little more impressive than just a despawn
            _control.despawnMob("ghost");
            // TODO: the panel should probably respond to the state change instead
            getFightPanel().endFight();
            CommandEvent.dispatch(getFightPanel(), GameController.END_FIGHT);
        }
    }

    protected var _control :AVRGameControl;
    protected var _model :FightModel;
}
}
