package {

import com.whirled.contrib.Scoreboard;
import com.whirled.game.GameControl;
import com.whirled.game.StateChangedEvent;

import flash.display.DisplayObject;

import net.*;

public class AppController
{
    public function AppController (mainObject :DisplayObject)
    {
        AppContext.gameCtrl = new GameControl(mainObject);
        AppContext.scores = new Scoreboard(AppContext.gameCtrl);
        AppContext.local = new LocalUtility(AppContext.gameCtrl);
        AppContext.msgs = new MessageManager(AppContext.gameCtrl);

        AppContext.msgs.addMessageType(AwardHealthMessage);
        AppContext.msgs.addMessageType(CreateMineMessage);
        AppContext.msgs.addMessageType(DefaultShotMessage);
        AppContext.msgs.addMessageType(EnableShieldMessage);
        AppContext.msgs.addMessageType(LaserShotMessage);
        AppContext.msgs.addMessageType(ShipExplodedMessage);
        AppContext.msgs.addMessageType(TorpedoShotMessage);
        AppContext.msgs.addMessageType(WarpMessage);
    }

    /**
     * Should be called by a subclass when resources have been loaded and the game
     * can be kicked off.
     */
    protected function run () :void
    {
        if (_running) {
            return;
        }

        AppContext.gameCtrl.game.addEventListener(StateChangedEvent.GAME_STARTED,
            handleGameStarted);
        AppContext.gameCtrl.game.addEventListener(StateChangedEvent.GAME_ENDED, handleGameEnded);

        _running = true;
    }

    public function shutdown () :void
    {
        if (AppContext.game != null) {
            AppContext.game.shutdown();
            AppContext.game = null;
        }

        if (AppContext.board != null) {
            AppContext.board.shutdown();
            AppContext.board = null;
        }

        if (AppContext.gameCtrl.isConnected()) {
            AppContext.gameCtrl.game.removeEventListener(StateChangedEvent.GAME_STARTED,
                handleGameStarted);
            AppContext.gameCtrl.game.removeEventListener(StateChangedEvent.GAME_ENDED,
                handleGameEnded);
        }

        _running = false;
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

    protected var _running :Boolean;
}

}
