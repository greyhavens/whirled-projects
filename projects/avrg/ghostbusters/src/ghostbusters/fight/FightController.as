//
// $Id$

package ghostbusters.fight {

import flash.display.Sprite;
import flash.events.MouseEvent;

import com.threerings.util.CommandEvent;
import com.threerings.util.Controller;
import com.whirled.AVRGameControlEvent;

import ghostbusters.Codes;
import ghostbusters.Game;
import ghostbusters.GameController;

public class FightController extends Controller
{
    public static const GHOST_ATTACKED :String = "GhostAttacked";
    public static const PLAYER_ATTACKED :String = "PlayerAttacked";

    public var panel :FightPanel;

    public function FightController ()
    {
        panel = new FightPanel();

        setControlledPanel(panel);

        Game.control.state.addEventListener(
            AVRGameControlEvent.MESSAGE_RECEIVED, messageReceived);
    }

    public function shutdown () :void
    {
    }

    public function lanternClicked () :void
    {
        panel.startGame();
    }

    public function handleGhostAttacked () :void
    {
        Game.control.state.sendMessage(Codes.MSG_GHOST_ATTACKED, Game.ourPlayerId);
        Game.control.playAvatarAction("Retaliate");
    }

    public function handlePlayerAttacked () :void
    {
        Game.control.state.sendMessage(Codes.MSG_PLAYER_ATTACKED, Game.ourPlayerId);
        Game.control.playAvatarAction("Reel");
    }

    protected function messageReceived (event: AVRGameControlEvent) :void
    {
        if (!Game.control.hasControl()) {
            return;
        }
        if (event.name == Codes.MSG_GHOST_ATTACKED) {
            if (Game.model.damageGhost(20)) {
                Game.control.state.sendMessage(Codes.MSG_GHOST_DEATH, null);
            }

        } else if (event.name == Codes.MSG_PLAYER_ATTACKED) {
            if (event.value is Number) {
                var playerId :int = event.value as int;
                if (Game.model.damagePlayer(playerId, 10)) {
                    Game.control.state.sendMessage(Codes.MSG_PLAYER_DEATH, playerId);
                }
            } else {
                Game.log.debug("Eek, non-number argument to MSG_PLAYER_ATTACKED: " + event.value);
            }
        }
    }
}
}
