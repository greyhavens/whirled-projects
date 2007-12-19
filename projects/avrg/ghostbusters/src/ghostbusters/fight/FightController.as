//
// $Id$

package ghostbusters.fight {

import flash.display.Sprite;
import flash.events.MouseEvent;

import com.threerings.util.CommandEvent;
import com.threerings.util.Controller;
import com.whirled.AVRGameControl;

import ghostbusters.Codes;
import ghostbusters.GameController;

public class FightController extends Controller
{
    public static const GHOST_MELEE :String = "GhostMelee";

    public var panel :FightPanel;
    public var model :FightModel;

    public function FightController (control :AVRGameControl)
    {
        _control = control;

        model = new FightModel(control);
        panel = new FightPanel(model);
        model.init(panel);

        setControlledPanel(panel);
    }

    public function shutdown () :void
    {
    }

    public function doSpawnGhost () :void
    {
        model.newGhost(100);
        _control.spawnMob(Codes.MOB_ID_GHOST, "Duchess Von Bobbleton");
    }

    public function doDespawnGhost () :void
    {
        _control.despawnMob(Codes.MOB_ID_GHOST);
    }

    public function handleGhostMelee (score :Number) :void
    {
        if (model.damageGhost((int) (score * 10))) {
            // TODO: something a little more impressive than just a despawn
            _control.despawnMob(Codes.MOB_ID_GHOST);

            // TODO: the panel should probably respond to the state change instead
            panel.endFight();

            CommandEvent.dispatch(panel, GameController.END_FIGHT);
        }
    }

    protected var _control :AVRGameControl;
}
}
