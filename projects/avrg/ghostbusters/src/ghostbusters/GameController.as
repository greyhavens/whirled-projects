//
// $Id$

package ghostbusters {

import com.threerings.util.Controller;
import com.whirled.AVRGameAvatar;
import com.whirled.AVRGameControlEvent;
import com.whirled.MobControl;

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

    public var panel :GamePanel;

    public function GameController ()
    {
        panel = new GamePanel()
        setControlledPanel(panel);
    }

    public function shutdown () :void
    {
        panel.shutdown();
    }

    public function handleEndGame () :void
    {
        Game.control.deactivateGame();
    }

    public function handleHelp () :void
    {
        // TODO
    }

    public function handleToggleLoot () :void
    {
//        handleSpawnGhost();
    }

    public function handlePlay () :void
    {
        panel.seeking = false;
    }

    public function handleToggleLantern () :void
    {
        if (Game.model.state == GameModel.STATE_SEEKING) {
            panel.seeking = !panel.seeking;

        } else if (Game.model.state == GameModel.STATE_FIGHTING) {
            Game.fightController.lanternClicked();

        }
        // else no effect
    }

    public function handleSpawnGhost () :void
    {
        if (Game.control.hasControl()) {
            Game.model.state = GameModel.STATE_FIGHTING;
        }
    }

    public function handleEndFight () :void
    {
        Game.log.debug("handleEndFight(" + Game.control.hasControl() + ")");
        // TODO: we probably want a delay before another ghost is available
        if (Game.control.hasControl()) {
            Game.model.ghostId = null;
            Game.model.state = GameModel.STATE_SEEKING;
        }
    }

    public function setAvatarState (state :String) :void
    {
        var info :AVRGameAvatar = Game.control.getAvatarInfo(Game.ourPlayerId);
        if (info != null && info.state != state) {
            Game.control.setAvatarState(state);
        }
    }
}
}
