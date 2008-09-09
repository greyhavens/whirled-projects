package server {

import com.whirled.game.GameControl;
import com.whirled.game.GameSubControl;
import com.whirled.game.OccupantChangedEvent;
import com.whirled.game.StateChangedEvent;
import com.whirled.net.PropertyChangedEvent;

import flash.events.TimerEvent;
import flash.utils.Timer;

public class ServerGameManager extends GameManager
{
    public function ServerGameManager (gameCtrl :GameControl)
    {
        super(gameCtrl);
        ServerContext.game = this;
    }

    override public function beginGame () :void
    {
        super.beginGame();
        setImmediate(Constants.PROP_GAMESTATE, Constants.STATE_PRE_ROUND);
        ServerContext.board = AppContext.board as ServerBoardController;
    }

    override protected function startRound () :void
    {
        super.startRound();
        _lastStateTimeUpdate = _stateTimeMs;

        setImmediate(Constants.PROP_STATETIME, _stateTimeMs);

        // TODO - figure out if this is necessary
        /*if (_ownShip != null) {
            _ownShip.restart();
            _boardCtrl.shipKilled(myId);
        }*/

        // The server is in charge of adding powerups.
        ServerContext.board.addRandomPowerup();
        startPowerupTimer();
    }

    override protected function roundEnded () :void
    {
        super.roundEnded();

        var playerIds :Array = [];
        var scores :Array = [];
        AppContext.scores.getPlayerIdsAndScores(playerIds, scores);
        _gameCtrl.game.endGameWithScores(playerIds, scores, GameSubControl.TO_EACH_THEIR_OWN);
    }

    override protected function update (time :int) :void
    {
        // is it time to end the round?
        if (_gameState == Constants.STATE_IN_ROUND) {
            if (_stateTimeMs <= 0) {
                _gameState = Constants.STATE_POST_ROUND;
                setImmediate(Constants.PROP_GAMESTATE, _gameState);
                _screenTimer.reset();
                _powerupTimer.stop();
            }
        }

        super.update(time);

        // synchronize the stateTime property every few seconds
        if (_lastStateTimeUpdate - _stateTimeMs >= 10 * 1000) {
            setImmediate(Constants.PROP_STATETIME, _stateTimeMs);
            _lastStateTimeUpdate = _stateTimeMs;
        }
    }

    override protected function propertyChanged (event:PropertyChangedEvent) :void
    {
        super.propertyChanged(event);
    }

    override public function addShip (id :int, ship :Ship) :void
    {
        super.addShip(id, ship);

        // the server is in charge of starting the round when enough players join
        if (_population >= Constants.MIN_PLAYERS_TO_START &&
            _gameState == Constants.STATE_PRE_ROUND) {
            log.info("Starting round...");
            setImmediate(Constants.PROP_GAMESTATE, Constants.STATE_IN_ROUND);
        }
    }

    protected function startPowerupTimer () :void
    {
        if (_powerupTimer != null) {
            _powerupTimer.removeEventListener(TimerEvent.TIMER, ServerContext.board.addRandomPowerup);
        }
        _powerupTimer = new Timer(Constants.RANDOM_POWERUP_TIME_MS, 0);
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

    override protected function occupantLeft (event :OccupantChangedEvent) :void
    {
        super.occupantLeft(event);
        setImmediate(shipKey(event.occupantId), null);
    }

    protected var _powerupTimer :Timer;
    protected var _lastStateTimeUpdate :int;
}

}
