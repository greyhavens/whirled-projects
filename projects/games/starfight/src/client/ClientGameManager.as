package client {

import com.threerings.util.HashMap;
import com.whirled.game.GameControl;
import com.whirled.game.StateChangedEvent;
import com.whirled.net.PropertyChangedEvent;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.media.Sound;
import flash.media.SoundTransform;
import flash.utils.ByteArray;
import flash.utils.Timer;

public class ClientGameManager extends GameManager
{
    public function ClientGameManager (gameCtrl :GameControl)
    {
        super(gameCtrl);

        ClientContext.game = this;

        _gameCtrl.local.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
        _gameCtrl.local.addEventListener(KeyboardEvent.KEY_UP, keyReleased);
    }

    override public function shutdown () :void
    {
        super.shutdown();

        _gameCtrl.local.removeEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
        _gameCtrl.local.removeEventListener(KeyboardEvent.KEY_UP, keyReleased);
    }

    override public function beginGame () :void
    {
        ClientContext.gameView.beginGame();

        super.beginGame();

        if (_gameCtrl.net.get(Constants.PROP_GAMESTATE) == null) {
            _gameState = Constants.STATE_PRE_ROUND;
        } else {
            _gameState = int(_gameCtrl.net.get(Constants.PROP_GAMESTATE));
            _stateTimeMs = int(_gameCtrl.net.get(Constants.PROP_STATETIME));
        }

        ClientContext.board = ClientBoardController(AppContext.board);
        updateStatusDisplay();
    }

    /**
     * Choose the type of ship for ownship.
     */
    public function playerChoseShip (typeIdx :int) :void
    {
        var myName :String = _gameCtrl.game.getOccupantName(ClientContext.myId);

        // Create our local ship and center the board on it.
        _ownShip = new Ship(false, ClientContext.myId, myName, true);
        _ownShip.setShipType(typeIdx);

        addShip(ClientContext.myId, _ownShip);

        // Add ourselves to the ship array.
        setImmediate(shipKey(ClientContext.myId), _ownShip.writeTo(new ByteArray()));

        _ownShip.restart();

        ClientContext.board.setAsCenter(_ownShip.boardX, _ownShip.boardY);
    }

    /**
     * Changes the ship type.
     */
    public function changeShip (typeIdx :int) :void
    {
        _ownShip.setShipType(typeIdx);
        _ownShip.restart();
        _lastTickTime = flash.utils.getTimer();
    }

    /**
     * Play a sound appropriately for the position it's at (which might be not
     *  at all...)
     */
    public function playSoundAt (sound :Sound, x :Number, y :Number) :void
    {
        if (sound != null) {
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
    }

    override protected function propertyChanged (event :PropertyChangedEvent) :void
    {
        super.propertyChanged(event);

        if (event.name == Constants.PROP_GAMESTATE) {
            updateStatusDisplay();
        } else if (event.name == Constants.PROP_STATETIME) {
            _stateTimeMs = int(_gameCtrl.net.get(Constants.PROP_STATETIME));
        }
    }

    override public function hitShip (ship :Ship, x :Number, y :Number, shooterId :int,
        damage :Number) :void
    {
        super.hitShip(ship, x, y, shooterId, damage);

        // TODO - make the server authoritative about ship hits
        if (ship == _ownShip) {
            ship.hit(shooterId, damage);
            AppContext.scores.addToScore(shooterId, Math.round(damage * 10));
        }

        var sound :Sound = (ship.hasPowerup(Powerup.SHIELDS) ?
            Resources.getSound("shields_hit.wav") : Resources.getSound("ship_hit.wav"));
        playSoundAt(sound, x, y);

        if (ship == _ownShip) {
            ClientContext.gameView.status.setPower(ship.power);
        }
    }

    override public function hitObs (obj :BoardObject, x :Number, y :Number, shooterId :int,
        damage :Number) :void
    {
        // TODO - make the server authoritative about obstacle hits
        super.hitObs(obj, x, y, shooterId, damage);
        _boardCtrl.hitObs(obj, x, y, (_ownShip != null && shooterId == _ownShip.shipId), damage);
    }

    override protected function update (time :int) :void
    {
        var ownOldX :Number = _boardCtrl.width/2;
        var ownOldY :Number = _boardCtrl.height/2;
        var ownX :Number = ownOldX;
        var ownY :Number = ownOldY;

        super.update(time);

        if (_ownShip != null) {
            ownX = _ownShip.boardX;
            ownY = _ownShip.boardY;
        }

        // collide ownShip with crap on the board
        if (_ownShip != null && _ownShip.isAlive) {
            _boardCtrl.shipInteraction(_ownShip, ownOldX, ownOldY);
        }

        // update ship drawstates
        for each (var shipView :ShipView in _shipViews.values()) {
            shipView.updateDisplayState(ownX, ownY);
        }

        // Recenter the board on our ship.
        ClientContext.board.setAsCenter(ownX, ownY);

        // update shot views
        for each (var shotView :ShotView in _shotViews) {
            shotView.setPosRelTo(ownX, ownY);
        }

        // if our ship is dead, show the ship chooser after a delay
        if (_ownShip != null && !_ownShip.isAlive && _newShipTimer == null &&
            !ShipChooser.isShowing) {
            _newShipTimer = new Timer(Ship.RESPAWN_DELAY, 1);
            _newShipTimer.addEventListener(TimerEvent.TIMER, function (...ignored) :void {
                ShipChooser.show(false);
                _newShipTimer = null;
            });
            _newShipTimer.start();
        }

        // Every few frames, broadcast our status to everyone else.
        _updateCount += time;
        if (_ownShip != null && _updateCount > Constants.TIME_PER_UPDATE) {
            _updateCount = 0;
            setImmediate(shipKey(ClientContext.myId), _ownShip.writeTo(new ByteArray()));
        }

        // update our round display
        updateStatusDisplay();
    }

     public function updateStatusDisplay () :void
     {
        if (_gameState == Constants.STATE_PRE_ROUND) {
            ClientContext.gameView.status.updateRoundText("Waiting for players...");
        } else if (_gameState == Constants.STATE_POST_ROUND) {
            ClientContext.gameView.status.updateRoundText("Round over...");
        } else {
            var time :int = Math.max(0, _stateTimeMs) / 1000;
            var seconds :int = time % 60;
            var minutes :int = time / 60;
            ClientContext.gameView.status.updateRoundText(
                "" + minutes + (seconds < 10 ? ":0" : ":") + seconds);

            if (_ownShip != null) {
                ClientContext.gameView.status.setPower(_ownShip.power);
                ClientContext.gameView.status.setPowerups(_ownShip);
            }
        }
     }

    override public function createLaserShot (x :Number, y :Number, angle :Number, length :Number,
        shipId :int, damage :Number, ttl :Number, shipType :int, tShipId :int) :LaserShot
    {
        var shot :LaserShot = super.createLaserShot(x, y, angle, length, shipId, damage, ttl,
            shipType, tShipId);

        addShotView(new LaserShotView(shot));

        return shot;
    }

    override public function createMissileShot (x :Number, y :Number, vel :Number, angle :Number,
        shipId :int, damage :Number, ttl :Number, shipType :int, shotClip :Class = null,
        explodeClip :Class = null) :MissileShot
    {
        var shot :MissileShot = super.createMissileShot(x, y, vel, angle, shipId, damage, ttl,
            shipType);

        addShotView(new MissileShotView(shot, shotClip, explodeClip));

        return shot;
    }

    override public function createTorpedoShot (x :Number, y :Number, vel :Number, angle :Number,
        shipId :int, damage :Number, ttl :Number, shipType :int) :TorpedoShot
    {
        var shot :TorpedoShot = super.createTorpedoShot(x, y, vel, angle, shipId, damage, ttl,
            shipType);

        addShotView(new TorpedoShotView(shot));

        return shot;
    }

    protected function addShotView (shotView :ShotView) :void
    {
        _shotViews.push(shotView);
        if (_ownShip != null) {
            shotView.setPosRelTo(_ownShip.boardX, _ownShip.boardY);
        } else {
            shotView.setPosRelTo(_boardCtrl.width/2, _boardCtrl.height/2);
        }
        if (shotView is LaserShotView) {
            ClientContext.gameView.subShotLayer.addChild(shotView);
        } else {
            ClientContext.gameView.shotLayer.addChild(shotView);
        }
    }

    override protected function removeShot (index :int) :void
    {
        super.removeShot(index);

        var shotView :ShotView = _shotViews[index];
        _shotViews.splice(index, 1);
        shotView.parent.removeChild(shotView);
    }

    override protected function shipExploded (args :Array) :void
    {
        super.shipExploded(args);

        var shooterId :int = args[3];
        var shipId :int = args[4];

        if (_ownShip != null && shooterId == _ownShip.shipId) {
            AppContext.scores.addToScore(shooterId, KILL_PTS);
            _ownShip.registerKill(shipId);
        }

        playSoundAt(Resources.getSound("ship_explodes.wav"), args[0], args[1]);
    }

    override protected function shipChanged (shipId :int, bytes :ByteArray) :void
    {
        if (shipId != ClientContext.myId) {
            super.shipChanged(shipId, bytes);
        }
    }

    override public function addShip (id :int, ship :Ship) :void
    {
        var shipView :ShipView = new ShipView(ship);
        _shipViews.put(id, shipView);
        ClientContext.gameView.shipLayer.addChild(shipView);

        if (ship == _ownShip) {
            _ownShipView = shipView;
        }

        ClientContext.gameView.status.addShip(id);

        if (_gameState == Constants.STATE_IN_ROUND) {
            AppContext.local.feedback(ship.playerName + " entered the game.");
        }

        super.addShip(id, ship);
    }

    override public function removeShip (id :int) :Ship
    {
        var ship :Ship = super.removeShip(id);
        if (ship != null) {
            ClientContext.gameView.status.removeShip(id);

            var view :ShipView = _shipViews.remove(id);
            if (view != null) {
                ClientContext.gameView.shipLayer.removeChild(view);
            }
        }

        return ship;
    }

    override public function boardLoaded () :void
    {
        _shotViews = [];
        super.boardLoaded();

        ClientContext.gameView.boardLoaded();
    }

    override protected function roundEnded () :void
    {
        super.roundEnded();

        var shipArr :Array = _ships.values();
        shipArr.sort(function (shipA :Ship, shipB :Ship) :int {
            return shipB.score - shipA.score;
        });
        ClientContext.gameView.showRoundResults(shipArr);
    }

    protected function keyPressed (event :KeyboardEvent) :void
    {
        if (_ownShipView != null) {
            _ownShipView.keyPressed(event);
        }
    }

    protected function keyReleased (event :KeyboardEvent) :void
    {
        if (_ownShipView != null) {
            _ownShipView.keyReleased(event);
        }
    }

    protected var _shotViews :Array = [];
    protected var _ownShip :Ship;
    protected var _ownShipView :ShipView;
    protected var _shipViews :HashMap = new HashMap();
    protected var _newShipTimer :Timer;
}

}
