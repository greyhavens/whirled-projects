package popcraft {

import popcraft.battle.*;
import popcraft.battle.view.*;
import popcraft.data.*;
import popcraft.puzzle.*;

public class GameContext
{
    public static const GAME_TYPE_MULTIPLAYER :int = 0;
    public static const GAME_TYPE_SINGLEPLAYER :int = 1;

    public static var gameType :int;
    public static var gameData :GameData;
    public static var spLevel :LevelData;
    public static function get isSinglePlayer () :Boolean { return gameType == GAME_TYPE_SINGLEPLAYER; }
    public static function get isMultiplayer () :Boolean { return gameType == GAME_TYPE_MULTIPLAYER; }

    public static var gameMode :GameMode;
    public static var netObjects :NetObjectDB;
    public static var battleBoardView :BattleBoardView;
    public static var diurnalCycle :DiurnalCycle;

    public static var playerInfo :Array;
    public static var playerUnitSpellSets :Array;
    public static var localPlayerId :int;
    public static function get localPlayerInfo () :LocalPlayerInfo { return playerInfo[localPlayerId]; }
    public static function get isFirstPlayer () :Boolean { return (localPlayerId == 0); }
    public static function get numPlayers () :int { return playerInfo.length; }
    public static function get localUserIsPlaying () :Boolean { return localPlayerId >= 0; }

    public static function findEnemyForPlayer (playerId :uint) :PlayerInfo
    {
        var thisPlayer :PlayerInfo = playerInfo[playerId];

        // find the first player after this one that is on an opposing team
        for (var i :int = 0; i < playerInfo.length - 1; ++i) {
            var otherPlayerId :uint = (playerId + i + 1) % playerInfo.length;
            var otherPlayer :PlayerInfo = playerInfo[otherPlayerId];
            if (otherPlayer.teamId != thisPlayer.teamId && otherPlayer.isAlive) {
                return otherPlayer;
            }
        }

        return null;
    }
}

}
