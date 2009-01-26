package popcraft.game.mpbattle {

import com.whirled.contrib.simplegame.net.OnlineTickedMessageManager;
import com.whirled.contrib.simplegame.net.TickedMessageManager;
import com.whirled.contrib.simplegame.util.Rand;
import com.whirled.game.StateChangedEvent;

import popcraft.*;
import popcraft.battle.*;
import popcraft.data.*;
import popcraft.game.*;

public class MultiplayerGameMode extends GameMode
{
    override public function get mapSettings () :MapSettingsData
    {
        return _mpSettings.mapSettings;
    }

    override protected function setup () :void
    {
        super.setup();

        // start the game when the GAME_STARTED event is received
        registerListener(ClientCtx.gameCtrl.game, StateChangedEvent.GAME_STARTED,
            function (...ignored) :void {
                startGame();
            });

        // we're ready!
        ClientCtx.gameCtrl.game.playerReady();
    }

    override protected function rngSeeded () :void
    {
        // Determine what the game's team arrangement is, and randomly choose an appropriate
        // MultiplayerSettingsData that fits that arrangement.

        var multiplayerArrangement :int = ClientCtx.lobbyConfig.computeTeamArrangement();
        var potentialSettings :Array = ClientCtx.multiplayerSettings;
        potentialSettings = potentialSettings.filter(
            function (mpSettings :MultiplayerSettingsData, index :int, array :Array) :Boolean {
                return (mpSettings.arrangeType == multiplayerArrangement);
            });

        _mpSettings = Rand.nextElement(potentialSettings, Rand.STREAM_GAME);
    }

    override protected function createPlayers () :void
    {
        var teams :Array = ClientCtx.lobbyConfig.playerTeams;
        var handicaps :Array = ClientCtx.lobbyConfig.handicaps;

        // In multiplayer games, base locations are arranged in order of team,
        // with larger teams coming before smaller ones. Populate a set of TeamInfo
        // structures with base locations so that we can put everyone in the correct place.
        var baseLocs :Array = GameCtx.gameMode.mapSettings.baseLocs.slice();
        var teamSizes :Array = ClientCtx.lobbyConfig.computeTeamSizes();
        var teamInfos :Array = [];
        var teamInfo :TeamInfo;
        var teamId :int;
        for (teamId = 0; teamId < teamSizes.length; ++teamId) {
            teamInfo = new TeamInfo();
            teamInfo.teamId = teamId;
            teamInfo.teamSize = teamSizes[teamId];
            teamInfos.push(teamInfo);
        }

        teamInfos.sort(TeamInfo.teamSizeCompare);
        var baseLocIndex :int = 0;
        for (var teamInfoId :int = 0; teamInfoId < teamInfos.length; ++teamInfoId) {
            teamInfo = teamInfos[teamInfoId];
            for (var i :int = 0; i < teamInfo.teamSize; ++i) {
                teamInfo.baseLocs.push(MapSettingsData.getNextBaseLocForTeam(baseLocs, teamInfoId));
            }
        }

        var largestTeamSize :int = TeamInfo(teamInfos[0]).teamSize;

        teamInfos.sort(TeamInfo.teamIdCompare);

        // get some information about the players in the game
        var numPlayers :int = ClientCtx.seatingMgr.numExpectedPlayers;
        GameCtx.localPlayerIndex = ClientCtx.seatingMgr.localPlayerSeat;

        var workshopData :UnitData = GameCtx.gameData.units[Constants.UNIT_TYPE_WORKSHOP];
        var workshopHealth :Number = workshopData.maxHealth;

        var playerDisplayDatas :Array = GameCtx.gameData.playerDisplayDatas.values().filter(
            function (pdd :PlayerDisplayData, index :int, arr :Array) :Boolean {
                return !pdd.excludeFromMpBattle;
            });

        // create PlayerInfo structures
        GameCtx.playerInfos = [];
        for (var playerIndex :int = 0; playerIndex < numPlayers; ++playerIndex) {
            teamId = teams[playerIndex];
            teamInfo = teamInfos[teamId];
            var baseLoc :BaseLocationData = teamInfo.baseLocs.shift();

            // calculate the player's handicap
            var handicap :Number = 1;
            if (teamInfo.teamSize < largestTeamSize) {
                handicap = _mpSettings.smallerTeamHandicap;
            }
            if (handicaps[playerIndex]) {
                handicap *= Constants.HANDICAPPED_MULTIPLIER;
            }

            // choose a random color for this player
            var index :int = Rand.nextIntRange(0, playerDisplayDatas.length, Rand.STREAM_GAME);
            var playerDisplayData :PlayerDisplayData = playerDisplayDatas[index];
            playerDisplayDatas.splice(index, 1); // we're operating on a copy of the data
            var playerColor :uint = playerDisplayData.color;

            GameCtx.playerInfos.push(GameCtx.localPlayerIndex == playerIndex ?
                new LocalPlayerInfo(
                    playerIndex,
                    teamId,
                    baseLoc,
                    workshopHealth,
                    workshopHealth,
                    false,
                    handicap,
                    playerColor,
                    "player_" + index) :

                new PlayerInfo(
                    playerIndex,
                    teamId,
                    baseLoc,
                    workshopHealth,
                    workshopHealth,
                    false,
                    handicap,
                    playerColor,
                    "player_" + index));
        }

        // init players
        for each (var playerInfo :PlayerInfo in GameCtx.playerInfos) {
            playerInfo.init();
        }
    }

    override protected function createRandSeed () :uint
    {
        return ClientCtx.lobbyConfig.randSeed;
    }

    override protected function createMessageManager () :TickedMessageManager
    {
        return new OnlineTickedMessageManager(ClientCtx.gameCtrl,
             ClientCtx.seatingMgr.isLocalPlayerInControl, TICK_INTERVAL_MS);
    }

    override protected function get gameType () :int
    {
        return GameCtx.GAME_TYPE_BATTLE_MP;
    }

    override protected function get gameData () :GameData
    {
        return ClientCtx.defaultGameData;
    }

    override protected function handleGameOver () :void
    {
        fadeOutToMode(new MultiplayerGameOverMode(), FADE_OUT_TIME);

        GameCtx.musicControls.fadeOut(FADE_OUT_TIME - 0.25);
        GameCtx.sfxControls.fadeOut(FADE_OUT_TIME - 0.25);
    }

    protected var _mpSettings :MultiplayerSettingsData;
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
