package server {

import com.whirled.ServerObject;
import com.whirled.game.StateChangedEvent;
import com.whirled.net.PropertyChangedEvent;

import flash.events.TimerEvent;
import flash.utils.Timer;

public class ServerGameManager extends GameManager
{
    public function ServerGameManager (mainObject :ServerObject)
    {
        super(mainObject);
        ServerContext.game = this;
        setup();
    }

    override protected function setup () :void
    {
        super.setup();
        setImmediate(Constants.PROP_GAMESTATE, Constants.STATE_PRE_ROUND);
        ServerContext.board = AppContext.board as ServerBoardController;
    }

    override protected function update (time :int) :void
    {
        // is it time to end the round?
        if (_gameState == Constants.STATE_IN_ROUND) {
            if (_stateTime <= 0) {
                _gameState = Constants.STATE_POST_ROUND;
                _gameCtrl.services.stopTicker(Constants.MSG_STATETICKER);
                setImmediate(Constants.PROP_GAMESTATE, _gameState);
                _screenTimer.reset();
                _powerupTimer.stop();
            }
        }

        super.update(time);
    }

    override protected function propertyChanged (event:PropertyChangedEvent) :void
    {
        super.propertyChanged(event);
    }

    override protected function createBoardController () :BoardController
    {
        return new ServerBoardController(AppContext.gameCtrl);
    }

    override public function addShip (id :int, ship :Ship) :void
    {
        super.addShip(id, ship);

        // the server is in charge of starting the round when enough players join
        if (_population >= 2 && _gameState == Constants.STATE_PRE_ROUND) {
            log.info("Starting round...");
            setImmediate(Constants.PROP_GAMESTATE, Constants.STATE_IN_ROUND);
        }
    }

    override protected function handleGameStarted (event :StateChangedEvent) :void
    {
        super.handleGameStarted(event);

        _gameCtrl.services.stopTicker(Constants.TICKER_NEXTROUND);
    }

    override protected function handleGameEnded (event :StateChangedEvent) :void
    {
        super.handleGameEnded(event);

        _gameCtrl.doBatch(function () :void {
            _gameCtrl.game.restartGameIn(30);
            _gameCtrl.services.startTicker(Constants.TICKER_NEXTROUND, 1000);
        });
    }

    override public function startRound () :void
    {
        super.startRound();

        // The server is in charge of adding powerups.
        _gameCtrl.services.startTicker(Constants.MSG_STATETICKER, 1000);
        setImmediate(Constants.PROP_STATETIME, _stateTime);
        // TODO - figure out if this is necessary
        /*if (_ownShip != null) {
            _ownShip.restart();
            _boardCtrl.shipKilled(myId);
        }*/
        ServerContext.board.addRandomPowerup();
        startPowerupTimer();
    }

    protected function startPowerupTimer () :void
    {
        if (_powerupTimer != null) {
            _powerupTimer.removeEventListener(TimerEvent.TIMER, ServerContext.board.addRandomPowerup);
        }
        _powerupTimer = new Timer(Constants.RANDOM_POWERUP_TIME, 0);
        _powerupTimer.addEventListener(TimerEvent.TIMER, ServerContext.board.addRandomPowerup);
        _powerupTimer.start();
    }

    override protected function shipExploded (args :Array) :void
    {
        super.shipExploded(args);

        var x :Number = args[0];
        var y :Number = args[1];
        ServerContext.board.addHealthPowerup(x, y);
    }

    protected var _powerupTimer :Timer;
}

}
