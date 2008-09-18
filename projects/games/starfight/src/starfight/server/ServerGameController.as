package starfight.server {

import com.whirled.contrib.ManagedTimer;
import com.whirled.game.GameControl;
import com.whirled.game.GameSubControl;
import com.whirled.game.OccupantChangedEvent;
import com.whirled.net.MessageReceivedEvent;

import starfight.*;
import starfight.net.AwardHealthMessage;
import starfight.net.EnableShieldMessage;
import starfight.net.ShipExplodedMessage;

public class ServerGameController extends GameController
{
    public function ServerGameController (gameCtrl :GameControl)
    {
        super(gameCtrl);
        ServerContext.game = this;
    }

    override public function run () :void
    {
        // re-init game state
        setNewGameState(Constants.STATE_INIT);

        // clear any existing ships out
        var occupants :Array = _gameCtrl.game.getOccupantIds();
        for each (var occupantId :int in occupants) {
            setImmediate(shipKey(occupantId), null);
            setImmediate(shipDataKey(occupantId), null);
        }

        // init the board
        ServerContext.board = AppContext.board as ServerBoardController;
        ServerContext.board.createBoard();

        setNewGameState(Constants.STATE_PRE_ROUND);

        beginGame();
    }

    override protected function messageReceived (event :MessageReceivedEvent) :void
    {
        super.messageReceived(event);

        var ship :ServerShip;
        if (event.value is EnableShieldMessage) {
            var shieldMessage :EnableShieldMessage = EnableShieldMessage(event.value);
            ship = ServerShip(getShip(shieldMessage.shipId));
            if (ship != null) {
                ship.enableShield(shieldMessage.shieldHealth, shieldMessage.timeoutMs);
            }

        } else if (event.value is AwardHealthMessage) {
            var healthMessage :AwardHealthMessage = AwardHealthMessage(event.value);
            ship = ServerShip(getShip(healthMessage.shipId));
            if (ship != null) {
                ship.awardHealth(healthMessage.healthIncrement);
            }
        }
    }

    override public function createShip (shipId :int, playerName :String) :Ship
    {
        return new ServerShip(shipId, playerName);
    }

    override public function hitShip (ship :Ship, x :Number, y :Number, shooterId :int,
        damage :Number) :void
    {
        super.hitShip(ship, x, y, shooterId, damage);

        if (ServerShip(ship).hit(shooterId, damage)) {
            AppContext.scores.addToScore(shooterId, Math.round(damage * 10));
        }
    }

    override protected function roundStarted () :void
    {
        super.roundStarted();
        _lastStateTimeUpdate = _stateTimeMs;

        setImmediate(Constants.PROP_STATETIME, _stateTimeMs);

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
                stopScreenTimer();
                stopPowerupTimer();
                setNewGameState(Constants.STATE_POST_ROUND);
            }
        }

        if (_gameState != Constants.STATE_POST_ROUND) {
            // save the ships' current locations
            var ships :Array = _ships.values();
            var oldShipLocs :Array = new Array(ships.length * 2);
            var ii :int;
            for each (var ship :Ship in ships) {
                oldShipLocs[ii++] = ship.boardX;
                oldShipLocs[ii++] = ship.boardY;
            }

            super.update(time);

            // collide the ships with stuff on the board
            ii = 0;
            for each (ship in ships) {
                var oldX :Number = oldShipLocs[ii++];
                var oldY :Number = oldShipLocs[ii++];
                if (ship.isAlive) {
                    ServerContext.board.handleMineCollisions(ship, oldX, oldY);
                }
            }

            // broadcast ship server data to everyone else
            // TODO - throttle these updates
            for each (ship in ships) {
                var shipData :ServerShipData = ship.serverData;
                if (shipData.isDirty) {
                    setImmediate(shipDataKey(ship.shipId), shipData.toBytes());
                    shipData.clean();
                }
            }

            // synchronize the stateTime property every few seconds
            if (_lastStateTimeUpdate - _stateTimeMs >= 10 * 1000) {
                setImmediate(Constants.PROP_STATETIME, _stateTimeMs);
                _lastStateTimeUpdate = _stateTimeMs;
            }
        }
    }

    override public function addShip (id :int, ship :Ship) :void
    {
        super.addShip(id, ship);

        // the server is in charge of starting the round when enough players join
        if (_population >= Constants.MIN_PLAYERS_TO_START &&
            _gameState == Constants.STATE_PRE_ROUND) {
            setNewGameState(Constants.STATE_IN_ROUND);
        }
    }

    protected function startPowerupTimer () :void
    {
        if (_powerupTimer == null) {
            _powerupTimer = _timers.createTimer(
                Constants.RANDOM_POWERUP_TIME_MS, 0, ServerContext.board.addRandomPowerup);
            _powerupTimer.start();
        }
    }

    protected function stopPowerupTimer () :void
    {
        if (_powerupTimer != null) {
            _powerupTimer.cancel();
            _powerupTimer = null;
        }
    }

    public function shipExploded (ship :Ship, shooterId :int) :void
    {
        var shooter :Ship = getShip(shooterId);
        if (shooter != null) {
            AppContext.local.feedback(shooter.playerName + " killed " + ship.playerName + "!");
        }

        // batch all game state-change messages together
        _gameCtrl.doBatch(function () :void {
            AppContext.msgs.sendMessage(ShipExplodedMessage.create(ship, shooterId));
            ServerContext.board.removeMines(ship.shipId);
            ServerContext.board.addHealthPowerup(ship.boardX, ship.boardY);
            AppContext.scores.addToScore(shooterId, KILL_PTS);
        });
    }

    override protected function occupantLeft (event :OccupantChangedEvent) :void
    {
        super.occupantLeft(event);
        setImmediate(shipKey(event.occupantId), null);
    }

    protected function setNewGameState (newGameState :int) :void
    {
        if (newGameState != _gameState) {
            setImmediate(Constants.PROP_GAMESTATE, newGameState);
            gameStateChanged(newGameState);
        }
    }

    override public function removeShip (id :int) :Ship
    {
        var ship :Ship = super.removeShip(id);
        if (ship != null) {
            _gameCtrl.doBatch(function () :void {
                ServerContext.board.removeMines(ship.shipId);
            });
        }

        return ship;
    }

    protected var _powerupTimer :ManagedTimer;
    protected var _lastStateTimeUpdate :int;

    /** Points for various things in the game. */
    protected static const HIT_PTS :int = 1;
    protected static const KILL_PTS :int = 25;
}

}
