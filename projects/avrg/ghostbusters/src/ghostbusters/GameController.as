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
        setAvatarState(Codes.ST_PLAYER_DEFAULT);
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
        var state :String = Game.model.state;

        if (state == GameModel.STATE_SEEKING) {
            panel.seeking = !panel.seeking;

        } else if (state == GameModel.STATE_APPEARING) {
            // no effect: you have to watch this bit

        } else if (state == GameModel.STATE_FIGHTING) {
            Game.fightController.lanternClicked();

        } else if (state == GameModel.STATE_FINALE) {
            // no effect: you have to watch this bit

        } else {
            Game.log.debug("Unexpected state in toggleLantern: " + state);
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
