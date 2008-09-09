package {

import com.whirled.contrib.Scoreboard;
import com.whirled.game.GameControl;
import com.whirled.game.StateChangedEvent;

import flash.display.DisplayObject;

public class AppController
{
    public function AppController (mainObject :DisplayObject)
    {
        AppContext.gameCtrl = new GameControl(mainObject);
        AppContext.scores = new Scoreboard(AppContext.gameCtrl);
        AppContext.local = new LocalUtility(AppContext.gameCtrl);
    }

    /**
     * Should be called by a subclass when resources have been loaded and the game
     * can be kicked off.
     */
    protected function run () :void
    {
        AppContext.gameCtrl.game.addEventListener(StateChangedEvent.GAME_STARTED,
            handleGameStarted);
        AppContext.gameCtrl.game.addEventListener(StateChangedEvent.GAME_ENDED, handleGameEnded);

        // TODO - handle starting a game in between rounds
        handleGameStarted();
    }

    protected function handleGameStarted (...ignored) :void
    {
        AppContext.game = createGameManager();
        AppContext.board = createBoardController();

        AppContext.game.run();
    }

    protected function handleGameEnded (...ignored) :void
    {
        AppContext.game.shutdown();
        AppContext.board.shutdown();

        AppContext.game = null;
        AppContext.board = null;
    }

    protected function createGameManager () :GameController
    {
        throw new Error("subclasses must implement createGameManager");
    }

    protected function createBoardController () :BoardController
    {
        throw new Error("subclasses must implement createBoardController");
    }
}

}