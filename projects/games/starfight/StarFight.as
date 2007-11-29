package {

import flash.display.Sprite;
import flash.display.Shape;
import flash.display.MovieClip;

import flash.media.Sound;
import flash.media.SoundTransform;

import flash.utils.ByteArray;

import flash.external.ExternalInterface;

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;

import flash.utils.Timer;
import flash.utils.getTimer;

import com.threerings.util.HashMap;

import com.threerings.ezgame.MessageReceivedEvent;
import com.threerings.ezgame.MessageReceivedListener;
import com.threerings.ezgame.PropertyChangedEvent;
import com.threerings.ezgame.PropertyChangedListener;
import com.threerings.ezgame.StateChangedEvent;
import com.threerings.ezgame.StateChangedListener;
import com.threerings.ezgame.OccupantChangedEvent;
import com.threerings.ezgame.OccupantChangedListener;
import com.threerings.ezgame.SeatingControl;

import com.whirled.WhirledGameControl;

/**
 * The main game class for the client.
 */
[SWF(width="700", height="500")]
public class StarFight extends Sprite
    implements PropertyChangedListener, MessageReceivedListener, StateChangedListener,
        OccupantChangedListener
{
    public static const WIDTH :int = 700;
    public static const HEIGHT :int = 500;

    /** Our seated index. */
    public var myId :int = -1;

    /**
     * Constructs our main view area for the game.
     */
    public function StarFight ()
    {
        _gameCtrl = new WhirledGameControl(this);
        _gameCtrl.registerListener(this);

        var mask :Shape = new Shape();
        addChild(mask);
        mask.graphics.clear();
        mask.graphics.beginFill(0xFFFFFF);
        mask.graphics.drawRect(0, 0, WIDTH, HEIGHT);
        mask.graphics.endFill();
        this.mask = mask;
        graphics.beginFill(Codes.BLACK);
        graphics.drawRect(0, 0, StarFight.WIDTH, StarFight.HEIGHT);

        var introMovie :MovieClip = MovieClip(new introAsset());
        introMovie.addEventListener(MouseEvent.CLICK, setupBoard);
        addChild(introMovie);

        Resources.init(assetLoaded);
    }


    public function setupBoard (event :MouseEvent) :void
    {
        if (_assets < Codes.SHIP_TYPES.length) {
            return;
        }
        removeChild(event.currentTarget as MovieClip);

        _boardLayer = new Sprite();
        _subShotLayer = new Sprite();
        _shipLayer = new Sprite();
        _shotLayer = new Sprite();
        _statusLayer = new Sprite();
        addChild(_boardLayer);
        addChild(_subShotLayer);
        addChild(_shipLayer);
        addChild(_shotLayer);
        addChild(_statusLayer);

        _statusLayer.addChild(_status = new StatusOverlay());
        log("Created Game Controller");

        _lastTickTime = getTimer();

        setGameObject();
    }

    public function assetLoaded (success :Boolean) :void {
        if (success) {
            if (_assets < Codes.SHIP_TYPES.length) {
                Codes.SHIP_TYPES[_assets++].loadAssets(assetLoaded);
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
            _gameState = Codes.PRE_ROUND;
        } else {
            myId = _gameCtrl.getMyId();
            if (_gameCtrl.get("gameState") == null) {
                _gameState = Codes.PRE_ROUND;
            } else {
                _gameState = int(_gameCtrl.get("gameState"));
                _stateTime = int(_gameCtrl.get("stateTime"));
            }
            updateRoundStatus();
        }
        _boardCtrl = new BoardController(_gameCtrl);
        _boardCtrl.init(boardLoaded);

        // If someone already created the board, let's get it now.  If not, we'll get it on the
        // update.
        /*
        var boardBytes :ByteArray =  ByteArray(_gameCtrl.get("board"));
        if (boardBytes != null) {
            var boardObj :Board = new Board(0, 0, false);
            boardBytes.position = 0;
            boardObj.readFrom(boardBytes);
            gotBoard(boardObj);
        }
        */

    }

    /**
     * Once the host was found, start the game!
     */
    private function hostChanged (event : StateChangedEvent) : void
    {
        // Try initializing the game state if there isn't a board yet.
        if (_gameCtrl.amInControl()) {
            /*
            if (_gameCtrl.get("board") == null) {
                createBoard();
            }
            */
            if (_gameState == Codes.IN_ROUND) {
                startPowerupTimer();
            }
        }
    }

    public function boardLoaded () :void
    {
        var maxPowerups :int = Math.max(1,
            _boardCtrl.width*_boardCtrl.height/MIN_TILES_PER_POWERUP);
        if (_gameCtrl.isConnected()) {
            _powerups = (_gameCtrl.get("powerup") as Array);
            if (_powerups == null && _gameCtrl.amInControl()) {
                _gameCtrl.setImmediate("powerup", new Array(maxPowerups));
            }
        } else {
            _powerups = new Array(maxPowerups);
        }

        _shots = [];
        _powerups = [];
        _boardCtrl.createSprite(_boardLayer, _ships, _powerups);

        // Set up ships for all ships already in the world.
        if (_gameCtrl.isConnected()) {
            var occupants :Array = _gameCtrl.getOccupantIds();
            for (var ii :int = 0; ii < occupants.length; ii++) {
                // Skip ownship.
                if (occupants[ii] == myId) {
                    continue;
                }

                var bytes :ByteArray = ByteArray(_gameCtrl.get(shipKey(occupants[ii])));
                if (bytes != null) {
                    var ship :ShipSprite = new ShipSprite(_boardCtrl, this, true, occupants[ii],
                        _gameCtrl.getOccupantName(occupants[ii]), false);
                    bytes.position = 0;
                    ship.readFrom(bytes);
                    addShip(occupants[ii], ship);
                }
            }

            // Set up our initial powerups.
            var gamePows :Array = (_gameCtrl.get("powerup") as Array);

            // The game already has some powerups, create sprites for em.
            if (gamePows != null) {
                for (var pp :int = 0; pp < gamePows.length; pp++)
                {
                    if (gamePows[pp] == null) {
                        _powerups[pp] = null;
                    } else {
                        gamePows[pp].position = 0;
                        _powerups[pp] = Powerup.readPowerup(gamePows[pp]);
                        _boardCtrl.powerupLayer.addChild(_powerups[pp]);
                        _status.addPowerup(pp);
                    }
                }
            }
        }

        addChild(new ShipChooser(this, true));
    }

    /**
     * Creates the board and accompanying data and sets them on the game object.
    protected function createBoard () :void
    {
        var boardObj :Board;

        // TODO: This should be configurable as a game option once such is available.
        var sizeFactor :int = 4;

        // We don't already have a board and we're the host?  Create it
        //  and our initial ship array too.
        var size :int =
            int(Math.sqrt(sizeFactor) * 50);

        boardObj = new Board(size, size, true);
        if (_gameCtrl.isConnected()) {
            _gameCtrl.setImmediate("board", boardObj.writeTo(new ByteArray()));
        } else {
            gotBoard(boardObj);
        }

    }
     */

    /**
     * Do some initialization based on a received board.
    protected function gotBoard (boardObj :Board) :void
    {
        _shots = [];
        _powerups = [];

        //_board = new BoardSprite(boardObj, _ships, _powerups);
        //_boardLayer.addChild(_board);

    }
    */

    /**
     * Choose the type of ship for ownship.
     */
    public function chooseShip (typeIdx :int) :void
    {
        var myName :String = "Guest";

        if (_gameCtrl.isConnected()) {
            myName = _gameCtrl.getOccupantName(myId);
        }

        // Create our local ship and center the board on it.
        _ownShip = new ShipSprite(_boardCtrl, this, false, myId, myName,
            true);
        _ownShip.setShipType(typeIdx);

        _ownShip.setPosRelTo(_ownShip.boardX, _ownShip.boardY);
        _boardCtrl.setAsCenter(_ownShip.boardX, _ownShip.boardY);
        _shipLayer.addChild(_ownShip);

        // Add ourselves to the ship array.
        if (_gameCtrl.isConnected()) {
            _gameCtrl.setImmediate(shipKey(myId), _ownShip.writeTo(new ByteArray()));

            // TODO: Get these in place standalone.
            // Our ship is interested in keystrokes.
            _gameCtrl.addEventListener(KeyboardEvent.KEY_DOWN, _ownShip.keyPressed);
            _gameCtrl.addEventListener(KeyboardEvent.KEY_UP, _ownShip.keyReleased);
            _population++;
            maybeStartRound();
        }

        _ships.put(myId, _ownShip);

        // Set up our ticker that will control movement.
        _screenTimer = new Timer(1, 0); // As fast as possible.
        _screenTimer.addEventListener(TimerEvent.TIMER, tick);
        _screenTimer.start();

        _ownShip.restart();
        _lastTickTime = getTimer();
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
        for (var ii :int = 0; ii < _powerups.length; ii++) {
            if (_powerups[ii] == null) {
                var x :int = Math.random() * _boardCtrl.width;
                var y :int = Math.random() * _boardCtrl.height;

                var repCt :int = 0;

                while (_boardCtrl.getObstacleAt(x, y) ||
                    (_boardCtrl.getPowerupIdx(x+0.5, y+0.5, x+0.5, y+0.5, 0.1) != -1)) {
                    x = Math.random() * _boardCtrl.width;
                    y = Math.random() * _boardCtrl.height;

                    // Safety valve - if we can't find anything after 100
                    //  tries, bail.
                    if (repCt++ > 100) {
                        return;
                    }
                }

                _powerups[ii] = new Powerup(Math.random()*Powerup.COUNT, x, y);

                _gameCtrl.setImmediate("powerup", _powerups[ii].writeTo(new ByteArray()), ii);
                _boardCtrl.powerupLayer.addChild(_powerups[ii]);
                _status.addPowerup(ii);
                return;
            }
        }

        // If we're all full up, don't do anything.
    }

    public function removePowerup (idx :int) :void
    {
        _gameCtrl.setImmediate("powerup", null, idx);
        _boardCtrl.powerupLayer.removeChild(_powerups[idx]);
        _powerups[idx] = null;
        _status.removePowerup(idx);
    }

    // from PropertyChangedListener
    public function propertyChanged (event :PropertyChangedEvent) :void
    {
        if (myId == -1 || _assets < Codes.SHIP_TYPES.length) {
            return;
        }
        var name :String = event.name;
        /*
        if (name == "board" && (_board == null)) {
            log("Got a board change");
            // Someone else initialized our board.
            var boardBytes :ByteArray =  ByteArray(_gameCtrl.get("board"));
            var boardObj :Board = new Board(0, 0, false);
            boardBytes.position = 0;
            boardObj.readFrom(boardBytes);
            gotBoard(boardObj);
        } else
        */
        if (isShipKey(name)) {
            var id :int = shipId(name);
            if (id != myId) {
                // Someone else's ship - update our sprite for em.
                var occName :String = _gameCtrl.getOccupantName(id);
                var bytes :ByteArray = ByteArray(event.newValue);
                if (bytes == null) {
                    var remShip :ShipSprite = _ships.remove(id);
                    _gameCtrl.localChat(remShip.playerName + " left the game.");
                    if (remShip != null) {
                        _shipLayer.removeChild(remShip);
                        _status.removeShip(id);
                    }
                } else {
                    var ship :ShipSprite = getShip(id);
                    if (ship == null) {
                        ship = new ShipSprite(_boardCtrl, this, true, id,
                            occName, false);
                        _gameCtrl.localChat(ship.playerName + " entered the game.");
                        addShip(id, ship);
                    }

                    bytes.position = 0;
                    var sentShip :ShipSprite = new ShipSprite(_boardCtrl, this, true,
                        id, occName, false);
                    sentShip.readFrom(bytes);
                    ship.updateForReport(sentShip);
                    var scores :Object = {};
                    scores[id] = sentShip.score;
                    _gameCtrl.setMappedScores(scores);
                }
            }
        } else if ((name == "powerup") && (event.index >= 0)) {
            if (_powerups != null) {
                if (event.newValue == null) {
                    if (_powerups[event.index] != null) {
                        _boardCtrl.powerupLayer.removeChild(
                            _powerups[event.index]);
                        _powerups[event.index] = null;
                        _status.removePowerup(event.index);
                    }
                    return;
                }

                var pow :Powerup = _powerups[event.index];
                if (pow == null) {
                    _powerups[event.index] = pow = new Powerup(0, 0, 0, false);
                    _boardCtrl.powerupLayer.addChild(pow);
                    _status.addPowerup(event.index);
                }
                var pBytes :ByteArray = ByteArray(event.newValue);
                pBytes.position = 0;
                pow.readFrom(pBytes);
            }

        } else if (name == "gameState") {
            _gameState = int(_gameCtrl.get("gameState"));

            if (_gameState == Codes.IN_ROUND) {
                startRound();
            }
            updateRoundStatus();

        } else if (name == "stateTime") {
            _stateTime = int(_gameCtrl.get("stateTime"));
        }
    }

    public function addShip (id :int, ship :ShipSprite) :void
    {
        _ships.put(id, ship);
        _shipLayer.addChild(ship);
        _status.addShip(id);
        _population++;
        maybeStartRound();
        var testShip :ShipSprite = getShip(id);
    }

    public function getShip (id :int) :ShipSprite
    {
        return _ships.get(id);
    }

    public function maybeStartRound () :void
    {
        if (_population >= 1 && _gameState == Codes.PRE_ROUND && _gameCtrl.amInControl()) {
            _gameCtrl.set("gameState", Codes.IN_ROUND);
        }
    }

    /**
     * Performs the round starting events.
     */
    public function startRound () :void
    {
        _gameCtrl.localChat("Round starting...");
        _stateTime = 10 * 60 * 1000;
        // The first player is in charge of adding powerups.
        if (_gameCtrl.isConnected() && _gameCtrl.amInControl()) {
            _gameCtrl.setImmediate("stateTime", _stateTime);
            addPowerup(null);
            startPowerupTimer();
        }
    }

    /**
     * Starts the timer that adds powerups to the board.
     */
    public function startPowerupTimer () :void
    {
        _powerupTimer = new Timer(20000, 0);
        _powerupTimer.addEventListener(TimerEvent.TIMER, addPowerup);
        _powerupTimer.start();
    }

    // from MessageReceivedListener
    public function messageReceived (event :MessageReceivedEvent) :void
    {
        if (event.name == "shot") {
            var val :Array = (event.value as Array);
            Codes.SHIP_TYPES[val[1]].primaryShot(this, val);

        } else if (event.name == "secondary") {
            val = (event.value as Array);
            Codes.SHIP_TYPES[val[1]].secondaryShot(this, val);

        } else if (event.name == "explode") {
            var arr :Array = (event.value as Array);

            var ship :ShipSprite = getShip(arr[4]);
            _boardCtrl.explode(arr[0], arr[1], arr[2], false, ship.shipType);
            playSoundAt(Resources.getSound("ship_explodes.wav"), arr[0], arr[1]);
            ship.kill();

            if (arr[3] == _ownShip.shipId) {
                addScore(KILL_PTS);
            }
        }
    }

    /**
     * Adds a shot to the game and gets its sprite going.
     */
    public function addShot (shot :ShotSprite) :void
    {
        _shots.push(shot);
        shot.setPosRelTo(_ownShip.boardX, _ownShip.boardY);
        if (shot is LaserShotSprite) {
            _subShotLayer.addChild(shot);
        } else {
            _shotLayer.addChild(shot);
        }
    }

    /**
     * Adds to our score.
     */
    protected function addScore (score :int) :void
    {
        //_status.addScore(score);
        _ownShip.addScore(score);
        var scores :Object = {};
        scores[_ownShip.shipId] = _ownShip.score;
        _gameCtrl.setMappedScores(scores);
    }


    /**
     * Register that a ship was hit at the location.
     */
    public function hitShip (ship :ShipSprite, x :Number, y :Number,
        shooterId :int, damage :Number) :void
    {
        _boardCtrl.explode(x, y, 0, true, 0);

        var sound :Sound = (ship.powerups & ShipSprite.SHIELDS_MASK) ?
            Resources.getSound("shields_hit.wav") : Resources.getSound("ship_hit.wav");
        playSoundAt(sound, x, y);

        if (ship == _ownShip) {
            ship.hit(shooterId, damage);
            _status.setPower(ship.power);
        } else if (shooterId == _ownShip.shipId) {
            // We hit someone!  Give us some points.
            addScore(HIT_PTS);
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
        _status.setPower(_ownShip.power);
        _status.setPowerups(_ownShip);
    }

    /**
     * Register that an obstacle was hit.
     */
    public function hitObs (obs :Obstacle, x :Number, y :Number) :void
    {
        _boardCtrl.explode(x, y, 0, true, 0);

        var sound :Sound;
        switch (obs.type) {
        case Obstacle.ASTEROID_1:
        case Obstacle.ASTEROID_2:
            sound = Resources.getSound("asteroid_hit.wav");
            break;
        case Obstacle.JUNK:
            sound = Resources.getSound("junk_hit.wav");
            break;
        case Obstacle.WALL:
        default:
            sound = Resources.getSound("metal_hit.wav");
            break;
        }
        playSoundAt(sound, x, y);
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
        if (_gameState == Codes.PRE_ROUND) {
            _status.updateRoundText("Waiting for players...");
        } else if (_gameState == Codes.POST_ROUND) {
            _status.updateRoundText("Round over...");
        } else {
            var time :int = Math.max(0, _stateTime);
            time /= 1000;
            var seconds :int = time % 60;
            var minutes :int = time / 60;
            _status.updateRoundText("" + minutes + (seconds < 10 ? ":0" : ":") + seconds);
        }
     }

    /**
     * The game has started - do our initial startup.
     */
    protected function gameStarted (event :StateChangedEvent) :void
    {
        log("Game started");
    }

    public function stateChanged (event :StateChangedEvent) :void
    {
        if (event.type == StateChangedEvent.GAME_STARTED) {
            gameStarted(event);
        } else if (event.type == StateChangedEvent.CONTROL_CHANGED) {
            hostChanged(event);
            _boardCtrl.hostChanged(event);
        }
    }

    public function occupantLeft (event :OccupantChangedEvent) :void
    {
        var remShip :ShipSprite = _ships.remove(event.occupantId);
        _gameCtrl.localChat(remShip.playerName + " left the game.");
        if (remShip != null) {
            _shipLayer.removeChild(remShip);
            _status.removeShip(event.occupantId);
        }

        if (_gameCtrl.amInControl()) {
            _gameCtrl.setImmediate(shipKey(event.occupantId), null);
        }
    }

    public function occupantEntered (event :OccupantChangedEvent) :void
    {
        // Nothing to do...
    }

    /**
     * Send a message to the server about our shot.
     */
    public function fireShot (args :Array) :void
    {
        _gameCtrl.sendMessage("shot", args);
    }

    /**
     * Send a message to the server about our shot.
     */
    public function sendMessage (name :String, args :Array) :void
    {
        _gameCtrl.sendMessage(name, args);
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
        _gameCtrl.sendMessage("explode", args);
    }

    /**
     * When our screen updater timer ticks...
     */
    public function tick (event :TimerEvent) :void
    {
        var now :int = getTimer();
        var time :int = now - _lastTickTime;

        if (_gameState == Codes.IN_ROUND) {
            _stateTime -= time;
            if (_gameCtrl.isConnected() && _gameCtrl.amInControl() && _stateTime <= 0) {
                _gameState = Codes.POST_ROUND;
                _gameCtrl.setImmediate("gameState", _gameState);
                _screenTimer.stop();
                _powerupTimer.stop();
            }
        }

        var ownOldX :Number = _ownShip.boardX;
        var ownOldY :Number = _ownShip.boardY;

        // Update all ships.
        for each (var ship :ShipSprite in _ships.values()) {
            if (ship != null) {
                ship.tick(time);
            }
        }

        // And then shift em based on ownship's new pos.
        for each (ship in _ships.values()) {
            if (ship != null) {
                ship.setPosRelTo(_ownShip.boardX, _ownShip.boardY);
            }
        }

        var powIdx :int = _boardCtrl.getPowerupIdx(ownOldX, ownOldY,
            _ownShip.boardX, _ownShip.boardY, ShipSprite.COLLISION_RAD);
        while (powIdx != -1) {
            var powType :int = _powerups[powIdx].type;
            _ownShip.awardPowerup(powType);
            //playSoundAt(Resources.getSound(Powerup.SOUNDS[powType]), _powerups[powIdx].boardX,
                //_powerups[powIdx].boardY);
            addScore(POWERUP_PTS);
            removePowerup(powIdx);

            powIdx = _boardCtrl.getPowerupIdx(ownOldX, ownOldY,
                _ownShip.boardX, _ownShip.boardY, ShipSprite.COLLISION_RAD);
        }

        // Recenter the board on our ship.
        _boardCtrl.setAsCenter(_ownShip.boardX, _ownShip.boardY);
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
                shot.setPosRelTo(_ownShip.boardX, _ownShip.boardY);
            }
        }

        // Remove any that were done.
        for each (shot in completed) {
            _shots.splice(_shots.indexOf(shot), 1);
            if (shot is LaserShotSprite) {
                _subShotLayer.removeChild(shot);
            } else {
                _shotLayer.removeChild(shot);
            }
        }

        // Update the radar
        _status.updateRadar(_ships, _powerups, _ownShip.boardX, _ownShip.boardY);

        // update our round display
        updateRoundStatus();

        // Every few frames, broadcast our status to everyone else.
        _updateCount += time;
        if (_updateCount > Codes.TIME_PER_UPDATE && _gameCtrl.isConnected()) {
            _updateCount = 0;
            _gameCtrl.setImmediate(shipKey(myId), _ownShip.writeTo(new ByteArray()));
        }
        if (_gameCtrl.isConnected() && _gameCtrl.amInControl()) {
            _updateTime += time;
            if (_updateTime > TIME_WAIT) {
                _updateTime = 0;
                _gameCtrl.setImmediate("stateTime", _stateTime);
            }
        }

        _lastTickTime = now;
    }

    [Embed(source="rsrc/intro_movie.swf")]
    protected var introAsset :Class;

    /** Our game control object. */
    protected var _gameCtrl :WhirledGameControl;

    /** Our local ship. */
    protected var _ownShip :ShipSprite;

    /** All the ships. */
    protected var _ships :HashMap = new HashMap(); // HashMap<int, ShipSprite>

    /** All the active powerups. */
    protected var _powerups :Array; // Array<Powerup>

    /** Live shots. */
    protected var _shots :Array; // Array<ShotSprite>

    /** The board with all its obstacles. */
    protected var _boardCtrl :BoardController;

    /** Status info. */
    protected var _status :StatusOverlay;

    /** How many frames its been since we broadcasted. */
    protected var _updateCount :int = 0;
    protected var _updateTime :int = 0;

    protected var _lastTickTime :int;

    /** Our game timers. */
    protected var _powerupTimer :Timer;
    protected var _screenTimer :Timer;

    /** The current game state. */
    protected var _gameState :int;
    protected var _stateTime :int;
    protected var _population :int = 0;

    protected var _boardLayer :Sprite;
    protected var _shipLayer :Sprite;
    protected var _shotLayer :Sprite;
    protected var _subShotLayer :Sprite;
    protected var _statusLayer :Sprite;

    protected var _assets :int = 0;

    /** This could be more dynamic. */
    protected static const MIN_TILES_PER_POWERUP :int = 250;

    /** Points for various things in the game. */
    protected static const POWERUP_PTS :int = 25;
    protected static const HIT_PTS :int = 10;
    protected static const KILL_PTS :int = 50;

    /** Amount of time to wait between sending time updates. */
    protected static const TIME_WAIT :int = 10000;
}
}
