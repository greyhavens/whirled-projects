package {

import com.threerings.util.HashMap;
import com.whirled.game.CoinsAwardedEvent;
import com.whirled.game.GameControl;
import com.whirled.game.GameSubControl;
import com.whirled.game.OccupantChangedEvent;
import com.whirled.game.StateChangedEvent;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.PropertyChangedEvent;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.events.KeyboardEvent;
import flash.events.TimerEvent;
import flash.media.Sound;
import flash.media.SoundTransform;
import flash.utils.ByteArray;
import flash.utils.Timer;
import flash.utils.getTimer;

import view.ShipView;

public class GameManager
{
    /** Our seated index. */
    public var myId :int = -1;

    public var gameState :int;

    /**
     * Constructs our main view area for the game.
     */
    public function GameManager (mainObject :DisplayObject)
    {
        _gameCtrl = new GameControl(mainObject);
        AppContext.gameCtrl = _gameCtrl;
        AppContext.game = this;

        if (_gameCtrl.isConnected()) {
            _gameCtrl.local.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
            _gameCtrl.local.addEventListener(KeyboardEvent.KEY_UP, keyReleased);
        }
        Resources.init(assetLoaded);
    }


    public function firstStart () :Boolean
    {
        if (_assets < Codes.SHIP_TYPE_CLASSES.length) {
            return false;
        }

        if (_gameCtrl.isConnected()) {
            _gameCtrl.net.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, propertyChanged);
            _gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
            _gameCtrl.game.addEventListener(OccupantChangedEvent.OCCUPANT_LEFT, occupantLeft);
        }

        setupBoard();

        setGameObject();

        return true;
    }

    protected function shutdown () :void
    {
        if (_screenTimer != null) {
            _screenTimer.reset();
        }
        if (_powerupTimer != null) {
            _powerupTimer.reset();
        }
        for each (var ship :ShipSprite in _ships.values()) {
            ship.roundEnded();
        }
    }

    public function setupBoard () :void
    {
        AppContext.gameView.setup();

        _lastTickTime = getTimer();
    }

    public function assetLoaded (success :Boolean) :void {
        if (success) {
            _assets++;
            if (_assets <= Codes.SHIP_TYPE_CLASSES.length) {
                Codes.getShipType(_assets - 1).loadAssets(assetLoaded);
                return;
            }
        }
    }

    /**
     * For debug logging.
     */
    public function log (msg :String) :void
    {
        Logger.log(msg);
    }

    // from Game
    public function setGameObject () :void
    {
        log("Got game object");

        if (!_gameCtrl.isConnected()) {
            myId = 1;
            gameState = Codes.PRE_ROUND;
        } else {
            myId = _gameCtrl.game.getMyId();
            if (_gameCtrl.net.get("gameState") == null) {
                gameState = Codes.PRE_ROUND;
            } else {
                gameState = int(_gameCtrl.net.get("gameState"));
                _stateTime = int(_gameCtrl.net.get("stateTime"));
            }
            updateRoundStatus();
            _gameCtrl.game.addEventListener(StateChangedEvent.GAME_STARTED, handleGameStarted);
            _gameCtrl.game.addEventListener(StateChangedEvent.GAME_ENDED, handleGameEnded);
            _gameCtrl.game.addEventListener(StateChangedEvent.CONTROL_CHANGED, handleHostChanged);
            _gameCtrl.player.addEventListener(CoinsAwardedEvent.COINS_AWARDED, handleFlowAwarded);
        }

        AppContext.board = _boardCtrl = new BoardController(_gameCtrl);
        _boardCtrl.init(boardLoaded);
    }

    public function boardLoaded () :void
    {
        _shots = [];
        _boardCtrl.createSprite(AppContext.gameView.boardLayer, _ships, AppContext.gameView.status);

        // Set up ships for all ships already in the world.
        if (_gameCtrl.isConnected()) {
            var occupants :Array = _gameCtrl.game.getOccupantIds();
            for (var ii :int = 0; ii < occupants.length; ii++) {
                // Skip ownship.
                if (occupants[ii] == myId) {
                    continue;
                }

                var bytes :ByteArray = ByteArray(_gameCtrl.net.get(shipKey(occupants[ii])));
                if (bytes != null) {
                    var ship :ShipSprite = new ShipSprite(true, occupants[ii],
                        _gameCtrl.game.getOccupantName(occupants[ii]), false);
                    bytes.position = 0;
                    ship.readFrom(bytes);
                    addShip(occupants[ii], ship);
                }
            }
        }

        startScreen();

        AppContext.gameView.boardLoaded();
    }

    /**
     * Choose the type of ship for ownship.
     */
    public function chooseShip (typeIdx :int) :void
    {
        var myName :String = "Guest";

        if (_gameCtrl.isConnected()) {
            myName = _gameCtrl.game.getOccupantName(myId);
        }

        // Create our local ship and center the board on it.
        _ownShip = new ShipSprite(false, myId, myName, true);
        _ownShip.setShipType(typeIdx);

        addShip(myId, _ownShip);

        _boardCtrl.setAsCenter(_ownShip.boardX, _ownShip.boardY);

        // Add ourselves to the ship array.
        if (_gameCtrl.isConnected()) {
            setImmediate(shipKey(myId), _ownShip.writeTo(new ByteArray()));
        }

        _ownShip.restart();
    }

    /**
     * Changes the ship type.
     */
    public function changeShip (typeIdx :int) :void
    {
        _ownShip.setShipType(typeIdx);
        _ownShip.restart();
        _lastTickTime = getTimer();
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

    /**
     * Tells everyone about a new powerup.
     */
    public function addPowerup (event :TimerEvent) :void
    {
        _boardCtrl.addRandomPowerup();
    }

    public function addMine (shipId :int, x :int, y :int, shipType :int, damage :Number) :void
    {
        _boardCtrl.addMine(new Mine(
                shipId, x, y, _ownShip == null || shipId != _ownShip.shipId, damage));
    }

    public function propertyChanged (event :PropertyChangedEvent) :void
    {
        if (myId == -1 || _assets < Codes.SHIP_TYPE_CLASSES.length) {
            return;
        }
        var name :String = event.name;
        if (isShipKey(name)) {
            var id :int = shipId(name);
            if (id != myId) {
                // Someone else's ship - update our sprite for em.
                var occName :String = _gameCtrl.game.getOccupantName(id);
                var bytes :ByteArray = ByteArray(event.newValue);
                if (bytes == null) {
                    removeShip(id);

                } else {
                    var ship :ShipSprite = getShip(id);
                    bytes.position = 0;
                    if (ship == null) {
                        ship = new ShipSprite(true, id, occName, false);
                        _gameCtrl.local.feedback(ship.playerName + " entered the game.");
                        ship.readFrom(bytes);
                        addShip(id, ship);
                    } else {
                        var sentShip :ShipSprite = new ShipSprite(true, id, occName, false);
                        sentShip.readFrom(bytes);
                        ship.updateForReport(sentShip);
                    }
                    var scores :Object = {};
                    scores[id] = ship.score;
                    _gameCtrl.local.setMappedScores(scores);
                }
            }

        } else if (name == "gameState") {
            gameState = int(_gameCtrl.net.get("gameState"));

            if (gameState == Codes.IN_ROUND) {
                startRound();
            } else if (gameState == Codes.POST_ROUND) {
                endRound();
            }
            updateRoundStatus();

        } else if (name == "stateTime") {
            _stateTime = int(_gameCtrl.net.get("stateTime"));
        }
    }

    public function addShip (id :int, ship :ShipSprite) :void
    {
        _ships.put(id, ship);
        AppContext.gameView.status.addShip(id);
        _population++;
        maybeStartRound();
        var testShip :ShipSprite = getShip(id);

        var shipView :ShipView = new ShipView(ship);
        _shipViews.put(id, shipView);
        AppContext.gameView.shipLayer.addChild(shipView);
    }

    public function removeShip (id :int) :void
    {
        var remShip :ShipSprite = _ships.remove(id);
        if (remShip != null) {
            _gameCtrl.local.feedback(remShip.playerName + " left the game.");
            AppContext.gameView.status.removeShip(id);
            _population--;
        }

        var view :ShipView = _shipViews.remove(id);
        if (view != null) {
            AppContext.gameView.shipLayer.removeChild(view);
        }

        _boardCtrl.shipKilled(id);
    }

    public function getShip (id :int) :ShipSprite
    {
        return _ships.get(id);
    }

    public function numShips () :int
    {
        return _ships.size();
    }

    public function maybeStartRound () :void
    {
        if (_population >= 2 && gameState == Codes.PRE_ROUND && _gameCtrl.game.amInControl()) {
            _gameCtrl.net.set("gameState", Codes.IN_ROUND);
        }
    }

    /**
     * Performs the round starting events.
     */
    public function startRound () :void
    {
        _gameCtrl.local.feedback("Round starting...");
        _stateTime = 10 * 60;

        //_stateTime = 30;
        if (_gameCtrl.isConnected()) {
            var occupants :Array = _gameCtrl.game.getOccupantIds();
            var scores :Array = [];
            for (var ii :int = 0; ii < occupants.length; ii++) {
                scores[occupants[ii]] = 0;
            }
            _gameCtrl.local.setMappedScores(scores);
            if (_gameCtrl.game.amInControl()) {

                // The first player is in charge of adding powerups.
                _gameCtrl.services.startTicker("stateTicker", 1000);
                setImmediate("stateTime", _stateTime);
                if (_ownShip != null) {
                    _ownShip.restart();
                    _boardCtrl.shipKilled(myId);
                }
                addPowerup(null);
                startPowerupTimer();
            }
        }
    }

    public function startScreen () :void
    {
        if (_screenTimer != null) {
            _screenTimer.removeEventListener(TimerEvent.TIMER, tick);
        }
        // Set up our ticker that will control movement.
        _screenTimer = new Timer(1, 0); // As fast as possible.
        _screenTimer.addEventListener(TimerEvent.TIMER, tick);
        _screenTimer.start();
        _lastTickTime = getTimer();
    }

    public function endRound () :void
    {
        _screenTimer.reset();
        for each (var ship :ShipSprite in _ships.values()) {
            ship.roundEnded();
        }
        _boardCtrl.endRound();
        if (_gameCtrl.isConnected() && _gameCtrl.game.amInControl()) {
            var scoreIds :Array = [];
            var scores :Array = [];
            var props :Array = _gameCtrl.net.getPropertyNames("score:");
            for each (var prop :String in props) {
                var id :String = prop.substring(6);
                scoreIds.push(parseInt(id));
                scores.push(int(_gameCtrl.net.get("score:" + id)));
            }
            _gameCtrl.game.endGameWithScores(
                    scoreIds, scores, GameSubControl.TO_EACH_THEIR_OWN);
        }

        var shipArr :Array = _ships.values();
        shipArr.sort(function (shipA :ShipSprite, shipB :ShipSprite) :int {
            return shipB.score - shipA.score;
        });
        AppContext.gameView.endRound(shipArr);
    }

    /**
     * Starts the timer that adds powerups to the board.
     */
    public function startPowerupTimer () :void
    {
        if (_powerupTimer != null) {
            _powerupTimer.removeEventListener(TimerEvent.TIMER, addPowerup);
        }
        _powerupTimer = new Timer(20000, 0);
        _powerupTimer.addEventListener(TimerEvent.TIMER, addPowerup);
        _powerupTimer.start();
    }

    public function messageReceived (event :MessageReceivedEvent) :void
    {
        if (event.name == "shot") {
            var val :Array = (event.value as Array);
             Codes.getShipType(val[1]).primaryShot(val);

        } else if (event.name == "secondary") {
            val = (event.value as Array);
            Codes.getShipType(val[1]).secondaryShot(val);

        } else if (event.name == "explode") {
            var arr :Array = (event.value as Array);

            var ship :ShipSprite = getShip(arr[4]);
            if (ship != null) {
                _boardCtrl.explode(arr[0], arr[1], arr[2], false, ship.shipType);
                playSoundAt(Resources.getSound("ship_explodes.wav"), arr[0], arr[1]);
                ship.kill();
                var sship :ShipSprite = getShip(arr[3]);
                if (sship != null) {
                    _gameCtrl.local.feedback(sship.playerName + " killed " + ship.playerName + "!");
                }
            }
            _boardCtrl.shipKilled(arr[4]);

            if (_ownShip != null && arr[3] == _ownShip.shipId) {
                addScore(arr[3], KILL_PTS);
                _ownShip.registerKill(arr[4]);
            }

        } else if (event.name.substring(0, 9) == "addScore-") {
            if (String(myId) == event.name.substring(9)) {
                addScore(myId, int(event.value));
            }

        } else if (event.name == "stateTicker") {
            if (_stateTime > 0) {
                _stateTime -= 1;
                if (_stateTime % 10 == 0 && _gameCtrl.game.amInControl()) {
                    setImmediate("stateTime", _stateTime);
                }
            }
        }
    }

    /**
     * Adds a shot to the game and gets its sprite going.
     */
    public function addShot (shot :ShotSprite) :void
    {
        _shots.push(shot);
        if (_ownShip != null) {
            shot.setPosRelTo(_ownShip.boardX, _ownShip.boardY);
        } else {
            shot.setPosRelTo(_boardCtrl.width/2, _boardCtrl.height/2);
        }
        if (shot is LaserShotSprite) {
            AppContext.gameView.subShotLayer.addChild(shot);
        } else {
            AppContext.gameView.shotLayer.addChild(shot);
        }
    }

    /**
     * Adds to our score.
     */
    public function addScore (shipId :int, score :int) :void
    {
        if (shipId == myId) {
        //AppContext.gameView.status.addScore(score);
            _ownShip.addScore(score);
            var scores :Object = {};
            scores[_ownShip.shipId] = _ownShip.score;
            _gameCtrl.local.setMappedScores(scores);
        } else {
            if (_otherScores[shipId] === undefined) {
                _otherScores[shipId] = score;
            } else {
                _otherScores[shipId] = int(_otherScores[shipId]) + score;
            }
        }
    }

    public function awardTrophy (name :String) :void
    {
        _gameCtrl.player.awardTrophy(name);
    }

    /**
     * Register that a ship was hit at the location.
     */
    public function hitShip (ship :ShipSprite, x :Number, y :Number,
        shooterId :int, damage :Number) :void
    {
        _boardCtrl.explode(x, y, 0, true, 0);

        var sound :Sound = (ship.hasPowerup(Powerup.SHIELDS) ?
            Resources.getSound("shields_hit.wav") : Resources.getSound("ship_hit.wav"));
        playSoundAt(sound, x, y);

        if (ship == _ownShip) {
            ship.hit(shooterId, damage);
            AppContext.gameView.status.setPower(ship.power);
            addScore(shooterId, Math.round(damage * 10));
        }
    }

    /**
     * Custom explosion.
     */
    public function explodeCustom (x :Number, y :Number, movie :MovieClip) :void
    {
        _boardCtrl.explodeCustom(x, y, movie);
    }

    /**
     * Tell our overlay about our state.
     */
    public function forceStatusUpdate () :void
    {
        if (_ownShip != null) {
            AppContext.gameView.status.setPower(_ownShip.power);
            AppContext.gameView.status.setPowerups(_ownShip);
        }
    }

    /**
     * Register that an obstacle was hit.
     */
    public function hitObs (
            obj :BoardObject, x :Number, y :Number, shooterId :int, damage :Number) :void
    {
        playSoundAt(_boardCtrl.hitObs(
            obj, x, y, _ownShip != null && shooterId == _ownShip.shipId, damage), x, y);
    }

    /**
     * Play a sound appropriately for the position it's at (which might be not
     *  at all...)
     */
    public function playSoundAt (sound :Sound, x :Number, y :Number) :void
    {
        var vol :Number = 1.0;

        // If we don't yet have an ownship, must be in the process of creating
        //  it and thus ARE ownship.
        if (_ownShip != null) {
            var dx :Number = _ownShip.boardX - x;
            var dy :Number = _ownShip.boardY - y;
            var dist :Number = Math.sqrt(dx*dx + dy*dy);

            vol = 1.0 - (dist/25.0);
        }

        if (vol > 0.0) {
            sound.play(0, 0, new SoundTransform(vol));
        }
    }

    /**
     * Updates the round status display.
     */
     public function updateRoundStatus () :void
     {
        if (gameState == Codes.PRE_ROUND) {
            AppContext.gameView.status.updateRoundText("Waiting for players...");
        } else if (gameState == Codes.POST_ROUND) {
            AppContext.gameView.status.updateRoundText("Round over...");
        } else {
            var time :int = Math.max(0, _stateTime);
            var seconds :int = time % 60;
            var minutes :int = time / 60;
            AppContext.gameView.status.updateRoundText("" + minutes + (seconds < 10 ? ":0" : ":") + seconds);
        }
     }

    /**
     * The game has started - do our initial startup.
     */
    protected function handleGameStarted (event :StateChangedEvent) :void
    {
        if (_gameCtrl.game.amInControl()) {
            _gameCtrl.services.stopTicker("nextRoundTicker");
            setImmediate("gameState", Codes.PRE_ROUND);
        }
        _ships = new HashMap();
        _ownShip = null;
        setupBoard();
        _boardCtrl.init(boardLoaded);
        log("Game started");
    }

    /**
     * The game has ended - do our initial startup.
     */
    protected function handleGameEnded (event :StateChangedEvent) :void
    {
        _gameCtrl.doBatch(function () :void {
            setImmediate(shipKey(myId), null);
            setImmediate("score:myId", 0);
            if (_gameCtrl.game.amInControl()) {
                _gameCtrl.game.restartGameIn(30);
                _gameCtrl.services.startTicker("nextRoundTicker", 1000);
            }
        });
    }

    /**
     * Once the host was found, start the game!
     */
    protected function handleHostChanged (event : StateChangedEvent) : void
    {
        // Try initializing the game state if there isn't a board yet.
        if (_gameCtrl.game.amInControl()) {
            if (gameState == Codes.IN_ROUND) {
                startPowerupTimer();
            }
            _boardCtrl.hostChanged(event, gameState);
        }
    }

    public function occupantLeft (event :OccupantChangedEvent) :void
    {
        removeShip(event.occupantId);

        if (_gameCtrl.game.amInControl()) {
            setImmediate(shipKey(event.occupantId), null);
        }
    }

    /**
     * Send a message to the server about our shot.
     */
    public function fireShot (args :Array) :void
    {
        _gameCtrl.net.sendMessage("shot", args);
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
        for each (var ship :ShipSprite in _ships.values()) {
            if (ship != null) {
                if ((ship.boardX-x)*(ship.boardX-x) + (ship.boardY-y)*(ship.boardY-y) < dist2) {
                    nearShips[nearShips.length] = ship;
                }
            }
        }
        return nearShips;
    }

    /**
     * Register a big ole' explosion at the location.
     */
    public function explode (x :Number, y :Number, rot :int,
        shooterId :int, shipId :int) :void
    {
        var args :Array = new Array(5);
        args[0] = x;
        args[1] = y;
        args[2] = rot;
        args[3] = shooterId;
        args[4] = shipId;
        _gameCtrl.net.sendMessage("explode", args);
    }

    /**
     * When our screen updater timer ticks...
     */
    public function tick (event :TimerEvent) :void
    {
        var now :int = getTimer();
        var time :int = now - _lastTickTime;

        if (gameState == Codes.IN_ROUND) {
            if (_gameCtrl.isConnected() && _gameCtrl.game.amInControl() && _stateTime <= 0) {
                gameState = Codes.POST_ROUND;
                _gameCtrl.services.stopTicker("stateTicker");
                setImmediate("gameState", gameState);
                _screenTimer.reset();
                _powerupTimer.stop();
            }
        }

        var ownOldX :Number = _boardCtrl.width/2;
        var ownOldY :Number = _boardCtrl.height/2;
        var ownX :Number = ownOldX;
        var ownY :Number = ownOldY;

        if (_ownShip != null) {
            ownOldX = _ownShip.boardX;
            ownOldY = _ownShip.boardY;
        }

        // Update all ships.
        for each (var ship :ShipSprite in _ships.values()) {
            if (ship != null) {
                ship.tick(time);
            }
        }

        if (_ownShip != null) {
            ownX = _ownShip.boardX;
            ownY = _ownShip.boardY;
        }

        // update ship drawstates
        for each (var shipView :ShipView in _shipViews.values()) {
            if (shipView != null) {
                shipView.updateDisplayState(ownX, ownY);
            }
        }

        // collide ownShip with crap on the board
        if (_ownShip != null) {
            _boardCtrl.shipInteraction(_ownShip, ownOldX, ownOldY);
        }

        // Recenter the board on our ship.
        _boardCtrl.setAsCenter(ownX, ownY);
        _boardCtrl.tick(time);
        forceStatusUpdate();

        // Update all live shots.
        var completed :Array = []; // Array<ShotSprite>
        for each (var shot :ShotSprite in _shots) {
            if (shot != null) {
                shot.tick(_boardCtrl, time);
                if (shot.complete) {
                    completed.push(shot);
                }
                shot.setPosRelTo(ownX, ownY);
            }
        }

        // Remove any that were done.
        for each (shot in completed) {
            _shots.splice(_shots.indexOf(shot), 1);
            shot.parent.removeChild(shot);
        }

        // update our round display
        updateRoundStatus();

        // Every few frames, broadcast our status to everyone else.
        _updateCount += time;
        if (_ownShip != null && _updateCount > Codes.TIME_PER_UPDATE && _gameCtrl.isConnected()) {
            _updateCount = 0;
            _gameCtrl.doBatch(function () :void {
                setImmediate(shipKey(myId), _ownShip.writeTo(new ByteArray()));
                if (gameState == Codes.IN_ROUND) {
                    setImmediate("score:" + myId, _ownShip.score);
                    for (var id :String in _otherScores) {
                        _gameCtrl.net.sendMessage("addScore-" + id, int(_otherScores[id]));
                    }
                }
            });
            _otherScores = [];
        }
        _lastTickTime = now;
    }

    protected function keyPressed (event :KeyboardEvent) :void
    {
        if (_ownShip != null) {
            _ownShip.keyPressed(event);
        }
    }

    protected function keyReleased (event :KeyboardEvent) :void
    {
        if (_ownShip != null) {
            _ownShip.keyReleased(event);
        }
    }

    protected function handleFlowAwarded (event :CoinsAwardedEvent) :void
    {
        var amount :int = event.amount;
        if (amount > 0) {
            _gameCtrl.local.feedback("You earned " + amount + " flow this round.");
        }
    }

    protected function setImmediate (propName :String, value :Object) :void
    {
        _gameCtrl.net.set(propName, value, true);
    }

    /** Our game control object. */
    protected var _gameCtrl :GameControl;

    /** Our local ship. */
    protected var _ownShip :ShipSprite;

    /** All the ships. */
    protected var _ships :HashMap = new HashMap(); // HashMap<int, ShipSprite>
    protected var _shipViews :HashMap = new HashMap();

    /** Live shots. */
    protected var _shots :Array = new Array(); // Array<ShotSprite>

    /** The board with all its obstacles. */
    protected var _boardCtrl :BoardController;

    /** How many frames its been since we broadcasted. */
    protected var _updateCount :int = 0;

    protected var _lastTickTime :int;

    /** Our game timers. */
    protected var _powerupTimer :Timer;
    protected var _screenTimer :Timer;

    /** The current game state. */
    protected var _stateTime :int;
    protected var _population :int = 0;

    protected var _assets :int = 0;

    protected var _otherScores :Object = new Object();

    /** This could be more dynamic. */
    protected static const MIN_TILES_PER_POWERUP :int = 250;

    /** Points for various things in the game. */
    protected static const HIT_PTS :int = 1;
    protected static const KILL_PTS :int = 25;

    /** Amount of time to wait between sending time updates. */
    protected static const TIME_WAIT :int = 10000;
}

}
