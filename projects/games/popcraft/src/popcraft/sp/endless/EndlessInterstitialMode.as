package popcraft.sp.endless {

import com.threerings.flash.Vector2;
import com.whirled.game.GameSubControl;

import popcraft.*;

public class EndlessInterstitialMode extends EndlessLevelSelectModeBase
{
    public function EndlessInterstitialMode (multiplierStartLoc :Vector2)
    {
        super(INTERSTITIAL_MODE, multiplierStartLoc);
    }

    override protected function setup () :void
    {
        super.setup();

        EndlessGameContext.endGameAndSendScores();
        onLevelLoaded(EndlessGameContext.level);
    }

    override protected function getLocalSavedGames () :SavedEndlessGameList
    {
        // create some dummy saved games for this level and the next, which we'll switch to
        var saves :SavedEndlessGameList = new SavedEndlessGameList();

        var savedPlayerData :SavedLocalPlayerInfo =
            EndlessGameContext.savedHumanPlayers[GameContext.localPlayerIndex];

        saves.addSave(SavedEndlessGame.create(EndlessGameContext.mapIndex,
                EndlessGameContext.resourceScore,
                EndlessGameContext.damageScore,
                EndlessGameContext.scoreMultiplier,
                savedPlayerData.health,
                savedPlayerData.spells));

        saves.addSave(SavedEndlessGame.create(EndlessGameContext.mapIndex + 1,
                EndlessGameContext.resourceScore,
                EndlessGameContext.damageScore,
                EndlessGameContext.scoreMultiplier,
                savedPlayerData.health,
                savedPlayerData.spells));

        return saves;
    }

    override protected function get scores () :Array
    {
        return (GameContext.isSinglePlayerGame ?
            [ PlayerScore.create(GameContext.localPlayerIndex,
                EndlessGameContext.resourceScore,
                EndlessGameContext.damageScore,
                EndlessGameContext.resourceScoreThisRound,
                EndlessGameContext.damageScoreThisRound)
            ] :
            EndlessGameContext.playerMonitor.getScoresForRound(EndlessGameContext.roundId));
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
