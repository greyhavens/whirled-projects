//
// $Id$

package ghostbusters {

import com.threerings.util.Controller;
import com.whirled.AVRGameAvatar;
import com.whirled.AVRGameControlEvent;
import com.whirled.MobControl;

import flash.display.DisplayObject;

import ghostbusters.fight.FightPanel;
import ghostbusters.fight.MicrogameResult;

public class GameController extends Controller
{
    /* Finishing a minigame pays 1/20th of the most we could ever want to pay for anything. */
    public static const PAYOUT_MINIGAME :Number = 1.0/20;

    public static const HELP :String = "Help";
    public static const PLAY :String = "Play";
    public static const TOGGLE_LANTERN :String = "ToggleLantern";
    public static const TOGGLE_LOOT :String = "ToggleLoot";
    public static const END_GAME :String = "EndGame";
    public static const GHOST_ATTACKED :String = "GhostAttacked";
    public static const PLAYER_ATTACKED :String = "PlayerAttacked";
    public static const ZAP_GHOST :String = "ZapGhost";

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
        Game.setAvatarState(Codes.ST_PLAYER_DEFAULT);
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
            if (Game.model.isPlayerDead(Game.ourPlayerId)) {
                // you can't start a game when you're dead
                return;
            }
            var subPanel :FightPanel = Game.panel.subPanel as FightPanel;
            if (subPanel != null) {
                subPanel.startGame();
            }

        } else if (state == GameModel.STATE_GHOST_TRIUMPH ||
                   state == GameModel.STATE_GHOST_DEFEAT) {
            // no effect: you have to watch this bit

        } else {
            Game.log.debug("Unexpected state in toggleLantern: " + state);
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

    public function handleZapGhost () :void
    {
        Game.control.state.sendMessage(Codes.MSG_GHOST_ZAP, Game.ourPlayerId);
    }
}
}
