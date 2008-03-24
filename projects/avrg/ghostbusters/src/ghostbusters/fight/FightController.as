//
// $Id$

package ghostbusters.fight {

import flash.display.Sprite;
import flash.events.MouseEvent;

import com.threerings.util.ArrayUtil;
import com.threerings.util.CommandEvent;
import com.threerings.util.Controller;

import com.whirled.AVRGameControlEvent;

import ghostbusters.Codes;
import ghostbusters.Game;
import ghostbusters.GameController;
import ghostbusters.GameModel;

public class FightController extends Controller
{
    /* Finishing a minigame pays 1/20th of the most we could ever want to pay for anything. */
    public static const PAYOUT_MINIGAME :Number = 1.0/20;

    public static const GHOST_ATTACKED :String = "GhostAttacked";
    public static const PLAYER_ATTACKED :String = "PlayerAttacked";

    public var panel :FightPanel;

    public function FightController ()
    {
        panel = new FightPanel();

        setControlledPanel(panel);
    }

    public function shutdown () :void
    {
    }

    public function lanternClicked () :void
    {
        if (!Game.model.isPlayerDead(Game.ourPlayerId)) {
            panel.startGame();
        }
    }

    public function handleGhostAttacked (result :MicrogameResult) :void
    {
        if (result.damageOutput > 0) {
            Game.control.state.sendMessage(
                Codes.MSG_GHOST_ATTACKED, [ Game.ourPlayerId, result.damageOutput ]);
        }
        if (result.healthOutput > 0) {
            Game.control.state.sendMessage(
                Codes.MSG_PLAYERS_HEALED, [ Game.ourPlayerId, result.healthOutput ]);
        }
        Game.control.quests.completeQuest("minigame", null, PAYOUT_MINIGAME);
        Game.control.playAvatarAction("Retaliate");
    }
}
}
