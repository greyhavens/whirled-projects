package popcraft.mp {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.net.OnlineTickedMessageManager;
import com.whirled.contrib.simplegame.net.TickedMessageManager;
import com.whirled.contrib.simplegame.util.Rand;

import popcraft.*;
import popcraft.battle.*;
import popcraft.data.*;

public class MultiplayerGameMode extends GameMode
{
    public function MultiplayerGameMode ()
    {
    }

    override protected function rngSeeded () :void
    {
        // Determine what the game's team arrangement is, and randomly choose an appropriate
        // MultiplayerSettingsData that fits that arrangement.

        var multiplayerArrangement :int = MultiplayerConfig.computeTeamArrangement();
        var potentialSettings :Array = AppContext.multiplayerSettings;
        potentialSettings = potentialSettings.filter(
            function (mpSettings :MultiplayerSettingsData, index :int, array :Array) :Boolean {
                return (mpSettings.arrangeType == multiplayerArrangement);
            });

        GameContext.mpSettings = Rand.nextElement(potentialSettings, Rand.STREAM_GAME);
    }

    override protected function createPlayers () :void
    {
        var teams :Array = MultiplayerConfig.teams;
        var handicaps :Array = MultiplayerConfig.handicaps;

        // In multiplayer games, base locations are arranged in order of team,
        // with larger teams coming before smaller ones. Populate a set of TeamInfo
        // structures with base locations so that we can put everyone in the correct place.
        var baseLocs :Array = GameContext.mapSettings.baseLocs;
        var teamSizes :Array = MultiplayerConfig.computeTeamSizes();
        var teamInfos :Array = [];
        var teamInfo :TeamInfo;
        for (var teamId :int = 0; teamId < teamSizes.length; ++teamId) {
            teamInfo = new TeamInfo();
            teamInfo.teamId = teamId;
            teamInfo.teamSize = teamSizes[teamId];
            teamInfos.push(teamInfo);
        }

        teamInfos.sort(TeamInfo.teamSizeCompare);
        var baseLocIndex :int = 0;
        for each (teamInfo in teamInfos) {
            for (var i :int = 0; i < teamInfo.teamSize; ++i) {
                teamInfo.baseLocs.push(baseLocs[baseLocIndex++]);
            }
        }

        var largestTeamSize :int = TeamInfo(teamInfos[0]).teamSize;

        teamInfos.sort(TeamInfo.teamIdCompare);

        // get some information about the players in the game
        var numPlayers :int = AppContext.gameCtrl.game.seating.getPlayerIds().length;
        GameContext.localPlayerIndex = AppContext.gameCtrl.game.seating.getMyPosition();

        // create PlayerInfo structures
        GameContext.playerInfos = [];
        for (var playerIndex :int = 0; playerIndex < numPlayers; ++playerIndex) {

            var playerInfo :PlayerInfo;
            teamId = teams[playerIndex];
            teamInfo = teamInfos[teamId];
            var baseLoc :Vector2 = teamInfo.baseLocs.shift();

            // calculate the player's handicap
            var handicap :Number = 1;
            if (teamInfo.teamSize < largestTeamSize) {
                handicap = GameContext.mpSettings.smallerTeamHandicap;
            }
            if (handicaps[playerIndex]) {
                handicap *= Constants.HANDICAPPED_MULTIPLIER;
            }

            if (GameContext.localPlayerIndex == playerIndex) {
                var localPlayerInfo :LocalPlayerInfo =
                    new LocalPlayerInfo(playerIndex, teamId, baseLoc, handicap);
                playerInfo = localPlayerInfo;
            } else {
                playerInfo = new PlayerInfo(playerIndex, teamId, baseLoc, handicap);
            }

            GameContext.playerInfos.push(playerInfo);
        }
    }

    override protected function createRandSeed () :uint
    {
        return MultiplayerConfig.randSeed;
    }

    override protected function createMessageManager () :TickedMessageManager
    {
        return new OnlineTickedMessageManager(AppContext.gameCtrl,
             SeatingManager.isLocalPlayerInControl, TICK_INTERVAL_MS);
    }

    override protected function createInitialWorkshops () :void
    {
        var numPlayers :int = GameContext.numPlayers;
        for (var playerIndex :int = 0; playerIndex < numPlayers; ++playerIndex) {

            var playerInfo :PlayerInfo = GameContext.playerInfos[playerIndex];
            var baseLoc :Vector2 = playerInfo.baseLoc;

            var base :WorkshopUnit = GameContext.unitFactory.createBaseUnit(playerIndex);
            base.x = baseLoc.x;
            base.y = baseLoc.y;

            playerInfo.base = base;
        }
    }

    override protected function handleGameOver () :void
    {
        fadeOutToMode(new MultiplayerGameOverMode(), FADE_OUT_TIME);

        GameContext.musicControls.fadeOut(FADE_OUT_TIME - 0.25);
        GameContext.sfxControls.fadeOut(FADE_OUT_TIME - 0.25);
    }
}

}

/** Used by createPlayers() */
class TeamInfo
{
    public var teamId :int;
    public var teamSize :int;
    public var baseLocs :Array = [];

    // Used to sort TeamInfos from largest to smallest team size
    public static function teamSizeCompare (a :TeamInfo, b :TeamInfo) :int
    {
        if (a.teamSize > b.teamSize) {
            return -1;
        } else if (a.teamSize < b.teamSize) {
            return 1;
        } else {
            return 0;
        }
    }

    // Used to sort TeamInfos from smallest to largest teamId
    public static function teamIdCompare (a :TeamInfo, b :TeamInfo) :int
    {
        if (a.teamId < b.teamId) {
            return -1;
        } else if (a.teamId > b.teamId) {
            return 1;
        } else {
            return 0;
        }
    }
}

