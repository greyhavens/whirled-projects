package redrover.game {

import com.threerings.flashbang.util.Rand;

import redrover.*;
import redrover.aitask.AITask;
import redrover.game.robot.*;
import redrover.game.view.*;

public class PlayerFactory
{
    public static const DUMB_ROBOT :int = 0;
    public static const GEM_HOG_ROBOT :int = 1;

    public static function initPlayer (player :Player) :PlayerView
    {
        GameCtx.players.push(player);
        GameCtx.winningPlayers.push(player);
        GameCtx.gameMode.addObject(player);

        var view :PlayerView = new PlayerView(player);
        GameCtx.gameMode.addObject(view); // will add itself to the proper display parent

        GameCtx.gameMode.addObject(new PlayerShadowView(player)); // ditto

        return view;
    }

    public static function createRobot (type :int, initialTeam :int, locallyControlled :Boolean)
        :Robot
    {
        var board :Board = GameCtx.getBoard(initialTeam);
        var startX :int;
        var startY :int;
        for (;;) {
            startX = Rand.nextIntInRange(0, board.cols - 1, Rand.STREAM_GAME);
            startY = Rand.nextIntInRange(0, board.rows - 1, Rand.STREAM_GAME);
            if (!GameCtx.isCellOccupied(initialTeam, startX, startY)) {
                break;
            }
        }

        var player :Player = new Player(
            GameCtx.nextPlayerIndex(),
            (initialTeam == Constants.TEAM_RED ?
                GameCtx.nextMaleRobotName() : GameCtx.nextFemaleRobotName()),
            initialTeam,
            startX, startY,
            GameCtx.nextPlayerColor(),
            locallyControlled);

        initPlayer(player);

        var ai :AITask;
        switch (type) {
        case DUMB_ROBOT:
            ai = new DumbAI(player);
            break;

        case GEM_HOG_ROBOT:
            ai = new GemHogAI(player);
            break;
        }

        var robot :Robot = new Robot(ai);
        GameCtx.gameMode.addObject(robot);

        return robot;
    }

}

}
