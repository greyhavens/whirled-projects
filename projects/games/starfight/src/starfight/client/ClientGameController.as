package starfight.client {

import com.threerings.util.HashMap;
import com.whirled.game.CoinsAwardedEvent;
import com.whirled.game.GameControl;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.PropertyChangedEvent;

import flash.events.KeyboardEvent;
import flash.media.Sound;
import flash.media.SoundTransform;
import flash.utils.ByteArray;

import starfight.*;
import starfight.net.ShipExplodedMessage;

public class ClientGameController extends GameController
{
    public function ClientGameController (gameCtrl :GameControl)
    {
        super(gameCtrl);

        ClientContext.game = this;

        _gameCtrl.local.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
        _gameCtrl.local.addEventListener(KeyboardEvent.KEY_UP, keyReleased);
        _gameCtrl.player.addEventListener(CoinsAwardedEvent.COINS_AWARDED, handleCoinsAwarded);
    }

    override public function shutdown () :void
    {
        super.shutdown();

        if (_gameCtrl.isConnected()) {
            _gameCtrl.local.removeEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
            _gameCtrl.local.removeEventListener(KeyboardEvent.KEY_UP, keyReleased);
            _gameCtrl.player.removeEventListener(CoinsAwardedEvent.COINS_AWARDED, handleCoinsAwarded);
        }
    }

    override public function run () :void
    {
        if (_gameCtrl.net.get(Constants.PROP_GAMESTATE) == null) {
            _gameState = Constants.STATE_INIT;
        } else {
            _gameState = int(_gameCtrl.net.get(Constants.PROP_GAMESTATE));
            _stateTimeMs = int(_gameCtrl.net.get(Constants.PROP_STATETIME));
        }

        ClientContext.board = ClientBoardController(AppContext.board);
        ClientContext.gameView.init();
        ClientContext.board.loadBoard(beginGame);
    }

    override protected function messageReceived (event :MessageReceivedEvent) :void
    {
        super.messageReceived(event);
        if (event.value is ShipExplodedMessage) {
            shipExploded(ShipExplodedMessage(event.value));
        }
    }

    override public function createShip (shipId :int, playerName :String) :Ship
    {
        return new ClientShip(shipId, playerName);
    }

    /**
     * Choose the type of ship for ownship.
     */
    public function playerChoseShip (typeIdx :int) :void
    {
        var myName :String = _gameCtrl.game.getOccupantName(ClientContext.myId);

        // Create our local ship and center the board on it.
        _ownShip = new ClientShip(ClientContext.myId, myName, true);
        _ownShip.setShipType(typeIdx);
        _ownShip.restart();

        addShip(ClientContext.myId, _ownShip);

        // Add ourselves to the ship array.
        setImmediate(shipKey(ClientContext.myId), _ownShip.toBytes());

        // Also init our server data
        setImmediate(shipDataKey(ClientContext.myId), _ownShip.serverData.toBytes());

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
                ClientContext.sounds.playSound(sound, 0, 0, new SoundTransform(vol));
            }
        }
    }

    override protected function propertyChanged (event :PropertyChangedEvent) :void
    {
        super.propertyChanged(event);

        if (event.name == Constants.PROP_GAMESTATE) {
            gameStateChanged(int(_gameCtrl.net.get(Constants.PROP_GAMESTATE)));
        } else if (event.name == Constants.PROP_STATETIME) {
            _stateTimeMs = int(_gameCtrl.net.get(Constants.PROP_STATETIME));
        } else if (isShipDataKey(event.name)) {
            var shipId :int = shipDataKeyId(event.name);
            var ship :ClientShip = ClientShip(getShip(shipId));
            if (ship != null) {
                ship.serverData = ServerShipData.fromBytes(ByteArray(event.newValue));
            }
        }
    }

    override public function hitShip (ship :Ship, x :Number, y :Number, shooterId :int,
        damage :Number) :void
    {
        super.hitShip(ship, x, y, shooterId, damage);

        ClientContext.board.playExplosion(x, y, 0, true, 0);

        var sound :Sound = (ship.hasPowerup(Powerup.SHIELDS) ?
            Resources.getSound("shields_hit.wav") : Resources.getSound("ship_hit.wav"));
        playSoundAt(sound, x, y);
    }

    override public function hitObs (obj :BoardObject, x :Number, y :Number, shooterId :int,
        damage :Number) :void
    {
        super.hitObs(obj, x, y, shooterId, damage);
        AppContext.board.hitObs(obj, x, y, (_ownShip != null && shooterId == _ownShip.shipId),
            damage);
    }

    override protected function update (time :int) :void
    {
        var ownOldX :Number = AppContext.board.width/2;
        var ownOldY :Number = AppContext.board.height/2;
        var ownX :Number = ownOldX;
        var ownY :Number = ownOldY;

        super.update(time);

        if (_ownShip != null) {
            ownX = _ownShip.boardX;
            ownY = _ownShip.boardY;

            if (_ownShip.isAlive) {
                ClientContext.board.handlePowerupCollisions(_ownShip, ownOldX, ownOldY);
            }
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
        if (_gameState == Constants.STATE_IN_ROUND && _ownShip != null && !_ownShip.isAlive &&
            !_newShipTimerRunning && !ShipChooser.isShowing) {
            _newShipTimerRunning = true;
            _timers.runOnce(Ship.RESPAWN_DELAY, function (...ignored) :void {
                ShipChooser.show(false);
                _newShipTimerRunning = false;
            });
        }

        // Every few frames, broadcast our status to everyone else.
        _shipUpdateTime += time;
        if (_ownShip != null && _shipUpdateTime >= Constants.SHIP_UPDATE_INTERVAL_MS) {
            _shipUpdateTime = 0;
            setImmediate(shipKey(ClientContext.myId), _ownShip.toBytes());
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
                ClientContext.gameView.status.updateShipDisplay(_ownShip);
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
            shotView.setPosRelTo(AppContext.board.width/2, AppContext.board.height/2);
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

    protected function shipExploded (msg :ShipExplodedMessage) :void
    {
        var ship :Ship = getShip(msg.shipId);
        if (ship != null) {
            ship.killed();
            var shooter :Ship = getShip(msg.shooterId);
            if (shooter != null) {
                AppContext.local.feedback(shooter.playerName + " killed " + ship.playerName + "!");
            }

            ClientContext.board.playExplosion(msg.x, msg.y, msg.rotation, false, ship.shipTypeId);
            playSoundAt(Resources.getSound("ship_explodes.wav"), msg.x, msg.y);
        }

        if (_ownShip != null && msg.shooterId == _ownShip.shipId) {
            _ownShip.registerKill(msg.shipId);
        }
    }

    override protected function shipChanged (shipId :int, bytes :ByteArray) :void
    {
        if (shipId != ClientContext.myId) {
            super.shipChanged(shipId, bytes);
        }
    }

    override public function addShip (id :int, ship :Ship) :void
    {
        var shipView :ShipView = new ShipView(ClientShip(ship));
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

    override protected function beginGame () :void
    {
        _shotViews = [];

        ClientContext.board.setupBoard();

        // Set up ships for all ships already in the world.
        var occupants :Array = _gameCtrl.game.getOccupantIds();
        for (var ii :int = 0; ii < occupants.length; ii++) {
            if (getShip(occupants[ii]) == null) {
                var shipBytes :ByteArray = ByteArray(_gameCtrl.net.get(shipKey(occupants[ii])));
                if (shipBytes != null) {
                    var ship :ClientShip = ClientShip(createShip(occupants[ii],
                        _gameCtrl.game.getOccupantName(occupants[ii])));
                    shipBytes.position = 0;
                    ship.fromBytes(shipBytes);

                    var shipServerBytes :ByteArray =
                        ByteArray(_gameCtrl.net.get(shipDataKey(occupants[ii])));
                    if (shipServerBytes != null) {
                        ship.serverData = ServerShipData.fromBytes(shipServerBytes);
                    }
                    addShip(occupants[ii], ship);
                }
            }
        }

        super.beginGame();

        ClientContext.gameView.beginGame();
    }

    override protected function roundEnded () :void
    {
        super.roundEnded();

        ShipChooser.hide();

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

    protected function handleCoinsAwarded (event :CoinsAwardedEvent) :void
    {
        var amount :int = event.amount;
        if (amount > 0) {
            AppContext.local.feedback("You earned " + amount + " flow this round.");
        }
    }

    protected var _shotViews :Array = [];
    protected var _ownShip :ClientShip;
    protected var _ownShipView :ShipView;
    protected var _shipViews :HashMap = new HashMap();
    protected var _newShipTimerRunning :Boolean;
}

}
