package {

import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.whirled.game.GameControl;
import com.whirled.game.OccupantChangedEvent;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.PropertyChangedEvent;

import flash.events.TimerEvent;
import flash.utils.ByteArray;
import flash.utils.Timer;
import flash.utils.getTimer;

import net.ShipExplodedMessage;
import net.ShipMessage;

public class GameController
{
    public function GameController (gameCtrl :GameControl)
    {
        _gameCtrl = gameCtrl;

        _gameCtrl.net.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, propertyChanged);
        _gameCtrl.game.addEventListener(OccupantChangedEvent.OCCUPANT_LEFT, occupantLeft);

        AppContext.msgs.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
    }

    public function shutdown () :void
    {
        _gameCtrl.net.removeEventListener(PropertyChangedEvent.PROPERTY_CHANGED, propertyChanged);
        _gameCtrl.game.removeEventListener(OccupantChangedEvent.OCCUPANT_LEFT, occupantLeft);

        AppContext.msgs.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);

        if (_screenTimer != null) {
            _screenTimer.removeEventListener(TimerEvent.TIMER, tick);
            _screenTimer.reset();
            _screenTimer = null;
        }
    }

    public function get gameState () :int
    {
        return _gameState;
    }

    public function run () :void
    {
        _lastTickTime = getTimer();
        AppContext.board.loadBoard(beginGame);

        log.info("Game started");
    }

    protected function beginGame () :void
    {
        _shots = [];
        AppContext.board.setupBoard(_ships);

        // Set up ships for all ships already in the world.
        var occupants :Array = _gameCtrl.game.getOccupantIds();
        for (var ii :int = 0; ii < occupants.length; ii++) {
            // this is a bit of a hack. the ship might already exist if this is a client,
            // because clients add their own ships to the world before the board is loaded,
            // i think. TODO - change this.
            if (getShip(occupants[ii]) == null) {
                var bytes :ByteArray = ByteArray(_gameCtrl.net.get(shipKey(occupants[ii])));
                if (bytes != null) {
                    var ship :Ship = new Ship(true, occupants[ii],
                        _gameCtrl.game.getOccupantName(occupants[ii]), false);
                    bytes.position = 0;
                    ship.readFrom(bytes);
                    addShip(occupants[ii], ship);
                }
            }
        }

        // Set up our ticker that will control movement.
        _screenTimer = new Timer(1000/30, 0); // As fast as possible.
        _screenTimer.addEventListener(TimerEvent.TIMER, tick);
        _screenTimer.start();
        _lastTickTime = getTimer();
        _running = true;
    }

    /**
     * Return the key used to store the ship for a given player ID.
     */
    protected function shipKey (id :int) :String
    {
        return "ship:" + id;
    }

    /**
     * Return whether the key is that for a ship.
     */
    protected function isShipKey (key :String) :Boolean
    {
        return (key.substr(0, 5) == "ship:");
    }

    /**
     * Extracts and returns the ID from a ship's key.
     */
    protected function shipId (key :String) :int
    {
        return int(key.substr(5));
    }

    protected function propertyChanged (event :PropertyChangedEvent) :void
    {
        if (_running) {
            var name :String = event.name;
            if (isShipKey(name)) {
                shipChanged(shipId(name), ByteArray(event.newValue));
            }
        }
    }

    protected function gameStateChanged (newGameState :int) :void
    {
        if (newGameState != _gameState) {
            _gameState = newGameState;
            if (_gameState == Constants.STATE_IN_ROUND) {
                roundStarted();
            } else if (_gameState == Constants.STATE_POST_ROUND) {
                roundEnded();
            }
        }
    }

    protected function shipChanged (shipId :int, bytes :ByteArray) :void
    {
        var occName :String = _gameCtrl.game.getOccupantName(shipId);
        if (bytes == null) {
            removeShip(shipId);

        } else {
            var ship :Ship = getShip(shipId);
            bytes.position = 0;
            if (ship == null) {
                ship = new Ship(true, shipId, occName, false);
                ship.readFrom(bytes);
                addShip(shipId, ship);

            } else {
                var sentShip :Ship = new Ship(true, shipId, occName, false);
                sentShip.readFrom(bytes);
                ship.updateForReport(sentShip);
            }
        }
    }

    public function addShip (id :int, ship :Ship) :void
    {
        var oldValue :* = _ships.put(id, ship);
        if (oldValue !== undefined) {
            throw new Error("Tried to add a ship that already existed [id=" + id + "]");
        }
        _population++;
    }

    public function removeShip (id :int) :Ship
    {
        var remShip :Ship = _ships.remove(id);
        if (remShip != null) {
            AppContext.local.feedback(remShip.playerName + " left the game.");
            _population--;
        }

        AppContext.board.shipKilled(id);

        return remShip;
    }

    public function getShip (id :int) :Ship
    {
        return _ships.get(id);
    }

    public function numShips () :int
    {
        return _ships.size();
    }

    /**
     * Performs the round starting events.
     */
    protected function roundStarted () :void
    {
        AppContext.local.feedback("Round starting...");
        _stateTimeMs = Constants.ROUND_TIME_MS;
        AppContext.scores.clearAll();
    }

    protected function roundEnded () :void
    {
        _screenTimer.reset();
        for each (var ship :Ship in _ships.values()) {
            ship.roundEnded();
        }
        AppContext.board.roundEnded();
    }

    protected function messageReceived (event :MessageReceivedEvent) :void
    {
        if (_running) {
            if (event.value is ShipMessage) {
                var msg :ShipMessage = ShipMessage(event.value);
                Constants.getShipType(msg.shipTypeId).doShot(msg);
            } else if (event.value is ShipExplodedMessage) {
                shipExploded(ShipExplodedMessage(event.value));
            }
        }
    }

    public function createLaserShot (x :Number, y :Number, angle :Number, length :Number,
            shipId :int, damage :Number, ttl :Number, shipType :int, tShipId :int) :LaserShot
    {
        var shot :LaserShot = new LaserShot(x, y, angle, length, shipId, damage, ttl, shipType,
            tShipId);
        addShot(shot);

        return shot;
    }

    public function createMissileShot (x :Number, y :Number, vel :Number, angle :Number,
        shipId :int, damage :Number, ttl :Number, shipType :int,
        shotClip :Class = null, explodeClip :Class = null) :MissileShot
    {
        var shot :MissileShot = new MissileShot(x, y, vel, angle, shipId, damage, ttl, shipType);
        addShot(shot);

        return shot;
    }

    public function createTorpedoShot (x :Number, y :Number, vel :Number, angle :Number,
        shipId :int, damage :Number, ttl :Number, shipType :int) :TorpedoShot
    {
        var shot :TorpedoShot =
            new TorpedoShot(x, y, vel, angle, shipId, damage, ttl, shipType);

        addShot(shot);

        return shot;
    }

    protected function addShot (shot :Shot) :void
    {
        _shots.push(shot);
    }

    protected function removeShot (index :int) :void
    {
        _shots.splice(index, 1);
    }

    public function awardTrophy (name :String) :void
    {
        _gameCtrl.player.awardTrophy(name);
    }

    /**
     * Register that a ship was hit at the location.
     */
    public function hitShip (ship :Ship, x :Number, y :Number, shooterId :int, damage :Number) :void
    {
        AppContext.board.explode(x, y, 0, true, 0);
    }

    /**
     * Register that an obstacle was hit.
     */
    public function hitObs (obj :BoardObject, x :Number, y :Number, shooterId :int,
        damage :Number) :void
    {
    }

    protected function occupantLeft (event :OccupantChangedEvent) :void
    {
        removeShip(event.occupantId);
    }

    /**
     * Send a message to the server about our shot.
     */
    public function sendMessage (name :String, args :Array) :void
    {
        _gameCtrl.net.sendMessage(name, args);
    }

    /**
     * Returns all the ships within a certain distance of the supplied coordinates.
     */
    public function findShips (x :Number, y :Number, dist :Number) :Array
    {
        var dist2 :Number = dist * dist;
        var nearShips :Array = new Array();
        for each (var ship :Ship in _ships.values()) {
            if (ship != null) {
                if ((ship.boardX-x)*(ship.boardX-x) + (ship.boardY-y)*(ship.boardY-y) < dist2) {
                    nearShips[nearShips.length] = ship;
                }
            }
        }
        return nearShips;
    }

    protected function shipExploded (msg :ShipExplodedMessage) :void
    {
        var ship :Ship = getShip(msg.shipId);
        if (ship != null) {
            AppContext.board.explode(msg.x, msg.y, msg.rotation, false, ship.shipTypeId);
            ship.kill();
            var shooter :Ship = getShip(msg.shooterId);
            if (shooter != null) {
                AppContext.local.feedback(shooter.playerName + " killed " + ship.playerName + "!");
            }
        }
        AppContext.board.shipKilled(msg.shipId);
    }

    /**
     * When our screen updater timer ticks...
     */
    public function tick (event :TimerEvent) :void
    {
        var now :int = getTimer();
        update(now - _lastTickTime);
        _lastTickTime = now;
    }

    protected function update (time :int) :void
    {
        _stateTimeMs -= time;

        // Update all ships.
        for each (var ship :Ship in _ships.values()) {
            if (ship != null) {
                ship.update(time);
            }
        }

        AppContext.board.update(time);

        // Update all live shots.
        var completed :Array = []; // Array<Shot>
        for each (var shot :Shot in _shots) {
            if (shot != null) {
                shot.update(AppContext.board, time);
                if (shot.complete) {
                    completed.push(shot);
                }
            }
        }

        // Remove any that were done.
        for each (shot in completed) {
            removeShot(_shots.indexOf(shot));
        }
    }

    protected function setImmediate (propName :String, value :Object) :void
    {
        _gameCtrl.net.set(propName, value, true);
    }

    protected var _gameCtrl :GameControl;

    protected var _running :Boolean;

    protected var _gameState :int;

    protected var _ships :HashMap = new HashMap(); // HashMap<int, Ship>

    protected var _shots :Array = []; // Array<Shot>

    /** How many frames its been since we broadcasted. */
    protected var _shipUpdateTime :int = 0;

    protected var _lastTickTime :int;

    protected var _screenTimer :Timer;

    /** The current game state. */
    protected var _stateTimeMs :int;
    protected var _population :int = 0;

    protected static const log :Log = Log.getLog(GameController);

    /** This could be more dynamic. */
    protected static const MIN_TILES_PER_POWERUP :int = 250;

    /** Points for various things in the game. */
    protected static const HIT_PTS :int = 1;
    protected static const KILL_PTS :int = 25;

    /** Amount of time to wait between sending time updates. */
    protected static const TIME_WAIT :int = 10000;
}

}
