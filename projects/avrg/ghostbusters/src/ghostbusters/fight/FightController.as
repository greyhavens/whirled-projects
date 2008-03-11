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
import ghostbusters.fight.MicrogameResult;

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

    public function handleGhostAttacked (result :MicrogameResult) :void
    {
        if (result.damageDone > 0) {
            Game.control.state.sendMessage(
                Codes.MSG_GHOST_ATTACKED, [ Game.ourPlayerId, result.damageDone ]);
        }
        if (result.healingDone > 0) {
            Game.control.state.sendMessage(
                Codes.MSG_PLAYERS_HEALED, [ Game.ourPlayerId, result.healingDone ]);
        }
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
            var dmg :int = event.value() as int;
            if (dmg > 0 && Game.model.damageGhost(dmg)) {
                Game.control.state.sendMessage(Codes.MSG_GHOST_DEATH, null);
            }

        } else if (event.name == Codes.MSG_PLAYERS_HEALED) {
            var totHeal :int = event.value() as int;
            var players :Array = Game.control.getPlayerIds();

            // 
            var playerDmg :Array = new Array(players.length);
            var totDmg :int = 0;
            for (var ii :int = 0; ii < players.length; ii ++) {
                playerDmg[ii] = (Game.model.getPlayerMaxHealth(players[ii]) -
                                 Game.model.getPlayerHealth(players[ii]));
                totDmg += playerDmg[ii];
            }
            For (var ii :int = 0; ii < players.length; ii ++) {
                // give each player an amount of healing relative to how damaged they are
                var heal :int = (totHeal * playerDmg[ii]) / totDmg;
                var newHealth :int = heal + Game.model.getPlayerHealth(players[ii]);
                Game.model.setPlayerHealth(players[ii], newHealth);
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
