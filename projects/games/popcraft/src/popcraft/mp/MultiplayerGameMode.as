package popcraft.mp {

import com.whirled.contrib.simplegame.net.TickedMessageManager;

import popcraft.GameMode;

public class MultiplayerGameMode extends GameMode
{
    public function MultiplayerGameMode ()
    {
    }

    override protected function setup () :void
    {
        initMultiplayerSettings();

        super.setup();
    }

    protected function initMultiplayerSettings () :void
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
                var localPlayerInfo :LocalPlayerInfo = new LocalPlayerInfo(playerIndex, teamId, baseLoc, handicap);
                playerInfo = localPlayerInfo;
            } else {
                playerInfo = new PlayerInfo(playerIndex, teamId, baseLoc, handicap);
            }

            GameContext.playerInfos.push(playerInfo);
        }

        // setup target enemies
        for each (playerInfo in GameContext.playerInfos) {
            playerInfo.targetedEnemyId = GameContext.findEnemyForPlayer(playerInfo.playerIndex).playerIndex;
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

}

}
