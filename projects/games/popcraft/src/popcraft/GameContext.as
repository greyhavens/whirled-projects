package popcraft {

import popcraft.battle.*;
import popcraft.battle.view.*;
import popcraft.puzzle.*;

public class GameContext
{
    public static var gameMode :GameMode;
    public static var netObjects :NetObjectDB;
    public static var battleBoard :BattleBoard;
    public static var battleBoardView :BattleBoardView;
    public static var diurnalCycle :DiurnalCycle;

    public static var playerData :Array;
    public static var localPlayerId :int;
    public static function get localPlayerData () :LocalPlayerData { return playerData[localPlayerId]; }
    public static function get isFirstPlayer () :Boolean { return (localPlayerId == 0); }
    public static function get numPlayers () :int { return playerData.length; }
    public static function get localUserIsPlaying () :Boolean { return localPlayerId >= 0; }
}

}
