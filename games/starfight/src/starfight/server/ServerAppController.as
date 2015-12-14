package starfight.server {

import flash.display.DisplayObject;

import starfight.*;

public class ServerAppController extends AppController
{
    public function ServerAppController (mainObject:DisplayObject)
    {
        super(mainObject);
        run();
    }

    override protected function createGameManager () :GameController
    {
        return new ServerGameController(AppContext.gameCtrl);
    }

    override protected function createBoardController () :BoardController
    {
        return new ServerBoardController(AppContext.gameCtrl);
    }

    override protected function handleGameStarted (...ignored) :void
    {
        super.handleGameStarted(ignored);

        AppContext.gameCtrl.services.stopTicker(Constants.TICKER_NEXTROUND);
    }

    override protected function handleGameEnded (...ignored) :void
    {
        super.handleGameEnded(ignored);

        AppContext.gameCtrl.doBatch(function () :void {
            AppContext.gameCtrl.game.restartGameIn(Constants.END_ROUND_TIME_S);
            AppContext.gameCtrl.services.startTicker(Constants.TICKER_NEXTROUND, 1000);
        });
    }

}

}
