package popcraft.sp.endless {

import com.threerings.flash.Vector2;

import popcraft.*;

public class SpEndlessInterstitialMode extends EndlessLevelSelectModeBase
{
    public function SpEndlessInterstitialMode (multiplierStartLoc :Vector2)
    {
        var scores :Array;
        if (GameContext.isSinglePlayerGame) {
            scores = [
                PlayerScore.create(GameContext.localPlayerIndex,
                    EndlessGameContext.resourceScoreThisRound,
                    EndlessGameContext.damageScoreThisRound)
                ];

        } else {
            scores = EndlessGameContext.playerMonitor.getScoresForRound(EndlessGameContext.roundId);
        }

        super(INTERSTITIAL_MODE, scores, multiplierStartLoc);

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
