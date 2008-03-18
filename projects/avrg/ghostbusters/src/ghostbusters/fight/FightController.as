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
            var dmg :int = (event.value as Array)[1];
            if (dmg > 0 && Game.model.damageGhost(dmg)) {
                Game.control.state.sendMessage(Codes.MSG_GHOST_DEATH, null);
            }

        } else if (event.name == Codes.MSG_PLAYERS_HEALED) {
            var heal :int = (event.value as Array)[1];
            doHealPlayers(heal);

        } else if (event.name == Codes.MSG_PLAYER_ATTACKED) {
            doAttackPlayer(event.value as int);

        }
    }

    protected function doHealPlayers (totHeal :int) :void
    {
        var team :Array = Game.getTeam(true);

        // figure out how hurt each party member is, and the total hurt
        var playerDmg :Array = new Array(team.length);
        var totDmg :int = 0;
        for (var ii :int = 0; ii < team.length; ii ++) {
            playerDmg[ii] = (Game.model.getPlayerMaxHealth(team[ii]) -
                             Game.model.getPlayerHealth(team[ii]));
            totDmg += playerDmg[ii];
        }
        Game.log.debug("HEAL :: Total heal = " + totheal + "; Total team damage = " + totDmg);
        // hand totHeal out proportionally to each player's relative hurtness
        for (ii = 0; ii < team.length; ii ++) {
            var heal :int = (totHeal * playerDmg[ii]) / totDmg;
            var newHealth :int = heal + Game.model.getPlayerHealth(team[ii]);
            Game.log.debug("HEAL :: Awarding " + heal + " pts to player #" + team[ii]);
            Game.model.setPlayerHealth(team[ii], newHealth);
        }
    }

    protected function doAttackPlayer (playerId :int) :void
    {
        if (Game.model.damagePlayer(playerId, 10)) {
            Game.control.state.sendMessage(Codes.MSG_PLAYER_DEATH, playerId);
 
            var team :Array = Game.getTeam(true);
            ArrayUtil.removeFirst(team, Game.ourPlayerId);

            for (var ii :int = 0; ii < team.length; ii ++) {
                if (team[ii] == Game.ourPlayerId) {
                    continue;
                }
                if (Game.model.isPlayerDead(team[ii])) {
                    return;
                }
            }
            // everybody is dead!
            Game.control.state.sendMessage(Codes.MSG_GHOST_TRIUMPH, playerId);
        }
    }

}
}
