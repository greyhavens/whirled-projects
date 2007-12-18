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
        _model.newGhost(100);
        _control.spawnMob("ghost", "Duchess Von Bobbleton");
    }

    public function handleGhostMelee (score :Number) :void
    {
        if (_model.damageGhost((int) (score * 10))) {
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
