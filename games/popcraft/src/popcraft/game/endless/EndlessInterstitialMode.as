//
// $Id$

package popcraft.game.endless {

import com.threerings.geom.Vector2;

import popcraft.*;
import popcraft.game.*;
import popcraft.net.PlayerScoreMsg;

public class EndlessInterstitialMode extends EndlessLevelSelectModeBase
{
    public function EndlessInterstitialMode (multiplierStartLoc :Vector2)
    {
        super(INTERSTITIAL_MODE, multiplierStartLoc);
    }

    override protected function setup () :void
    {
        super.setup();

        EndlessGameCtx.endGameAndSendScores();
        onLevelLoaded(EndlessGameCtx.level);
    }

    override protected function getLocalSavedGames () :SavedEndlessGameList
    {
        // create some dummy saved games for this level and the next, which we'll switch to
        var saves :SavedEndlessGameList = new SavedEndlessGameList();

        var savedPlayerData :SavedLocalPlayerInfo =
            EndlessGameCtx.savedHumanPlayers[GameCtx.localPlayerIndex];

        saves.addSave(SavedEndlessGame.create(EndlessGameCtx.mapIndex,
                EndlessGameCtx.resourceScore,
                EndlessGameCtx.damageScore,
                EndlessGameCtx.scoreMultiplier,
                savedPlayerData.health,
                savedPlayerData.spells));

        saves.addSave(SavedEndlessGame.create(EndlessGameCtx.mapIndex + 1,
                EndlessGameCtx.resourceScore,
                EndlessGameCtx.damageScore,
                EndlessGameCtx.scoreMultiplier,
                savedPlayerData.health,
                savedPlayerData.spells));

        return saves;
    }

    override protected function get scores () :Array
    {
        return (GameCtx.isSinglePlayerGame ?
            [ PlayerScoreMsg.create(GameCtx.localPlayerIndex,
                EndlessGameCtx.resourceScore,
                EndlessGameCtx.damageScore,
                EndlessGameCtx.resourceScoreThisRound,
                EndlessGameCtx.damageScoreThisRound)
            ] :
            EndlessGameCtx.playerMonitor.getScores(EndlessGameCtx.roundId));
    }

    override protected function get enableNextPrevPlayButtons () :Boolean
    {
        return false;
    }

    override protected function get enableQuitButton () :Boolean
    {
        return false;
    }

    override protected function get enableHelpButton () :Boolean
    {
        return false;
    }

}

}
