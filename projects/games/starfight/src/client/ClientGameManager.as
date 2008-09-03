package client {

import com.threerings.util.HashMap;
import com.whirled.game.StateChangedEvent;
import com.whirled.net.PropertyChangedEvent;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.media.Sound;
import flash.media.SoundTransform;

public class ClientGameManager extends GameManager
{
    public function ClientGameManager (mainSprite :Sprite)
    {
        super(mainSprite);
        _mainSprite = mainSprite;
        AppContext.mainSprite = mainSprite;
        ClientContext.game = this;

        _gameView = new GameView();
        AppContext.gameView = _gameView;
        _mainSprite.addChild(_gameView);

        if (_gameCtrl.isConnected()) {
            mainSprite.root.loaderInfo.addEventListener(Event.UNLOAD,
                function (...ignored) :void {
                    shutdown();
                }
            );
        }

        Resources.init(assetLoaded);

        // start the game when the player clicks the mouse
        mainSprite.addEventListener(MouseEvent.CLICK, onMouseDown);

        if (_gameCtrl.isConnected()) {
            _gameCtrl.local.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
            _gameCtrl.local.addEventListener(KeyboardEvent.KEY_UP, keyReleased);
        }
    }

    override public function playerChoseShip (typeIdx :int) :void
    {
        super.playerChoseShip(typeIdx);
        if (_ownShip != null) {
            ClientContext.board.setAsCenter(_ownShip.boardX, _ownShip.boardY);
        }
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

    override protected function handleGameStarted (event :StateChangedEvent) :void
    {
        _ownShipView = null;
        _shipViews = new HashMap();
        super.handleGameStarted(event);
    }

    override protected function propertyChanged (event :PropertyChangedEvent) :void
    {
        super.propertyChanged(event);

        if (event.name == "gameState") {
            updateStatusDisplay();
        }
    }

    override public function hitShip (ship :Ship, x :Number, y :Number, shooterId :int,
        damage :Number) :void
    {
        super.hitShip(ship, x, y, shooterId, damage);

        var sound :Sound = (ship.hasPowerup(Powerup.SHIELDS) ?
            Resources.getSound("shields_hit.wav") : Resources.getSound("ship_hit.wav"));
        playSoundAt(sound, x, y);
    }

    override public function tick (event :TimerEvent) :void
    {
        var ownOldX :Number = _boardCtrl.width/2;
        var ownOldY :Number = _boardCtrl.height/2;
        var ownX :Number = ownOldX;
        var ownY :Number = ownOldY;

        super.tick(event);

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

        // Recenter the board on our ship.
        ClientContext.board.setAsCenter(ownX, ownY);

        // update shot views
        for each (var shotView :ShotView in _shotViews) {
            if (shotView != null) {
                shotView.setPosRelTo(ownX, ownY);
            }
        }

        // update our round display
        updateStatusDisplay();
    }

     public function updateStatusDisplay () :void
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
            AppContext.gameView.subShotLayer.addChild(shotView);
        } else {
            AppContext.gameView.shotLayer.addChild(shotView);
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

        playSoundAt(Resources.getSound("ship_explodes.wav"), args[0], args[1]);
    }

    override public function addShip (id :int, ship :Ship) :void
    {
        var shipView :ShipView = new ShipView(ship);
        _shipViews.put(id, shipView);
        AppContext.gameView.shipLayer.addChild(shipView);

        if (ship == _ownShip) {
            _ownShipView = shipView;
        }

        super.addShip(id, ship);
    }

    override public function removeShip (id :int) :Ship
    {
        var ship :Ship = super.removeShip(id);
        if (ship != null) {
            AppContext.gameView.status.removeShip(id);

            var view :ShipView = _shipViews.remove(id);
            if (view != null) {
                AppContext.gameView.shipLayer.removeChild(view);
            }
        }

        return ship;
    }

    protected function assetLoaded (success :Boolean) :void {
        if (success) {
            _assets++;
            if (_assets <= Codes.SHIP_TYPE_CLASSES.length) {
                ClientConstants.getShipResources(_assets - 1).loadAssets(assetLoaded);
                return;
            }
        }
    }

    override public function setGameObject () :void
    {
        super.setGameObject();
        ClientContext.board = ClientBoardController(AppContext.board);

        updateStatusDisplay();
    }

    override protected function createBoardController () :BoardController
    {
        return new ClientBoardController(_gameCtrl);
    }

    override public function boardLoaded () :void
    {
        _shotViews = [];
        super.boardLoaded();
    }

    protected function onMouseDown (...ignored) :void
    {
        if (firstStart()) {
            _mainSprite.removeEventListener(MouseEvent.CLICK, onMouseDown);
        }
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

    protected var _mainSprite :Sprite;
    protected var _gameView :GameView;
    protected var _shotViews :Array = [];
    protected var _ownShipView :ShipView;
    protected var _shipViews :HashMap = new HashMap();
}

}
