package popcraft {

import popcraft.battle.*;
import popcraft.battle.view.*;
import popcraft.puzzle.*;
import popcraft.sp.LevelData;

public class GameContext
{
    public static const GAME_TYPE_MULTIPLAYER :int = 0;
    public static const GAME_TYPE_SINGLEPLAYER :int = 1;

    public static var gameType :int;
    public static var spLevel :LevelData;

    public static var gameMode :GameMode;
    public static var netObjects :NetObjectDB;
    public static var battleBoard :BattleBoard;
    public static var battleBoardView :BattleBoardView;
    public static var diurnalCycle :DiurnalCycle;

    public static var playerData :Array;
    public static var playerUnitSpellSets :Array;
    public static var localPlayerId :int;
    public static function get localPlayerData () :LocalPlayerData { return playerData[localPlayerId]; }
    public static function get isFirstPlayer () :Boolean { return (localPlayerId == 0); }
    public static function get numPlayers () :int { return playerData.length; }
    public static function get localUserIsPlaying () :Boolean { return localPlayerId >= 0; }
}

}
