//
// $Id$

package ghostbusters.fight {

import flash.display.Sprite;
import flash.events.MouseEvent;

import com.threerings.util.CommandEvent;
import com.threerings.util.Controller;

import ghostbusters.Codes;
import ghostbusters.Game;
import ghostbusters.GameController;

public class FightController extends Controller
{
    public static const GHOST_MELEE :String = "GhostMelee";

    public var panel :FightPanel;
    public var model :FightModel;

    public function FightController ()
    {
        model = new FightModel();
        panel = new FightPanel(model);
        model.init(panel);

        setControlledPanel(panel);
    }

    public function shutdown () :void
    {
    }

    public function doSpawnGhost () :void
    {
        Game.control.setAvatarState(Codes.ST_PLAYER_FIGHT);

        model.newGhost(100);

        // TODO: this should obviously only be done by one instance
        Game.control.spawnMob(Codes.MOB_ID_GHOST, "Duchess Von Bobbleton");
    }

    public function doDespawnGhost () :void
    {
        Game.control.despawnMob(Codes.MOB_ID_GHOST);
    }

    public function lanternClicked () :void
    {
        panel.startGame();
    }

    public function handleGhostMelee (score :Number) :void
    {
        if (model.damageGhost((int) (score * 10))) {
            // TODO: something a little more impressive than just a despawn
            Game.control.despawnMob(Codes.MOB_ID_GHOST);

            // TODO: the panel should probably respond to the state change instead
            panel.endFight();

            CommandEvent.dispatch(panel, GameController.END_FIGHT);
        }
    }
}
}
