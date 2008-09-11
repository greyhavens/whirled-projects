package client {

import com.threerings.util.HashMap;
import com.whirled.game.GameControl;
import com.whirled.net.PropertyChangedEvent;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.media.Sound;
import flash.utils.ByteArray;

public class ClientBoardController extends BoardController
{
    public function ClientBoardController (gameCtrl :GameControl)
    {
        super(gameCtrl);
        gameCtrl.net.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, propertyChanged);
    }

    override public function shutdown () :void
    {
        super.shutdown();
        _gameCtrl.net.removeEventListener(PropertyChangedEvent.PROPERTY_CHANGED, propertyChanged);
    }

    protected function propertyChanged (event :PropertyChangedEvent) :void
    {
        if (!_boardLoaded && event.name == Constants.PROP_GAMESTATE) {
            tryLoadBoard();
        }
    }

    override public function loadBoard (boardLoadedCallback :Function) :void
    {
        _boardLoadedCallback = boardLoadedCallback;

        tryLoadBoard();
    }

    protected function tryLoadBoard () :void
    {
        // don't load the board until the server has finished init'ing it
        var gameStateObj :Object = _gameCtrl.net.get(Constants.PROP_GAMESTATE);
        if (gameStateObj != null && int(gameStateObj) != Constants.STATE_INIT) {
            var boardBytes :ByteArray = ByteArray(_gameCtrl.net.get(Constants.PROP_BOARD));
            if (boardBytes != null) {
                boardBytes.position = 0;
                readBoard(boardBytes);
            }
        }
    }

    override public function roundEnded () :void
    {
        super.roundEnded();
        _boardLoaded = false;
    }

    protected function readBoard (boardBytes :ByteArray) :void
    {
        if (_boardLoaded) {
            return;
        }

        readFrom(boardBytes);
        var obs :Array = (_gameCtrl.net.get(Constants.PROP_OBSTACLES) as Array);
        _obstacles = new Array(obs.length);
        for (var ii :int; ii < _obstacles.length; ii++) {
            if (obs[ii] == null) {
                _obstacles[ii] = null;
                continue;
            }
            obs[ii].position = 0;
            _obstacles[ii] = Obstacle.readObstacle(ByteArray(obs[ii]));
            _obstacles[ii].index = ii;
        }

        var pups :Array = (_gameCtrl.net.get(Constants.PROP_POWERUPS) as Array);
        _powerups = new Array(pups.length);
        for (ii = 0; ii < pups.length; ii++) {
            if (pups[ii] == null) {
                _powerups[ii] = null;
                continue;
            }
            pups[ii].position = 0;
            _powerups[ii] = Powerup.readPowerup(ByteArray(pups[ii]));
        }

        var mines :Array = (_gameCtrl.net.get(Constants.PROP_MINES) as Array);
        _mines = new Array(mines.length);
        for (ii = 0; ii < mines.length; ii++) {
            if (mines[ii] == null) {
                _mines[ii] = null;
                continue;
            }
            mines[ii].position = 0;
            _mines[ii] = Mine.readMine(ByteArray(mines[ii]));
            _mines[ii].index = ii;
        }

        _boardLoaded = true;
        _boardLoadedCallback();
    }

    override public function setupBoard (ships :HashMap) :void
    {
        // setup our sprites before calling super.setupBoard (which will call
        // powerupAdded, obstacleAdded, etc)
        _bg = new BgSprite(width, height);
        ClientContext.gameView.boardLayer.addChild(_bg);

        _boardSprite = new Sprite();
        ClientContext.gameView.boardLayer.addChild(_boardSprite);

        _obstacleLayer = new Sprite();
        _powerupLayer = new Sprite();
        _explosionLayer = new Sprite();
        _boardSprite.addChild(_obstacleLayer);
        _boardSprite.addChild(_powerupLayer);
        _boardSprite.addChild(_explosionLayer);

        _obstacleViews = new Array(_obstacles.length);
        _explosions = [];

        super.setupBoard(ships);
    }

    override public function update (time :int) :void
    {
        super.update(time);

        for each (var obstacleView :ObstacleView in _obstacleViews) {
            if (obstacleView != null) {
                obstacleView.tick(time);
            }
        }
    }

    public function setAsCenter (boardX :Number, boardY :Number) :void
    {
        _boardSprite.x = Constants.GAME_WIDTH/2 - boardX*Constants.PIXELS_PER_TILE;
        _boardSprite.y = Constants.GAME_HEIGHT/2 - boardY*Constants.PIXELS_PER_TILE;
        _bg.setAsCenter(boardX, boardY);
        ClientContext.gameView.status.updateRadar(_ships, _powerups, boardX, boardY);
    }

    override protected function powerupAdded (powerup :Powerup, index :int) :void
    {
        super.powerupAdded(powerup, index);
        _powerupLayer.addChild(new PowerupView(powerup));
        ClientContext.gameView.status.addPowerup(index);
    }

    override protected function powerupRemoved (index :int) :void
    {
        super.powerupRemoved(index);
        ClientContext.gameView.status.removePowerup(index);
    }

    override protected function mineAdded (mine :Mine) :void
    {
        super.mineAdded(mine);
        _powerupLayer.addChild(new MineView(mine));
    }

    override protected function obstacleAdded (obstacle :Obstacle, index :int) :void
    {
        super.obstacleAdded(obstacle, index);
        var view :ObstacleView = new ObstacleView(obstacle);
        _obstacleViews[index] = view;
        _obstacleLayer.addChild(view);
    }

    override protected function obstacleRemoved (index :int) :void
    {
        super.obstacleRemoved(index);
        if (_obstacleViews != null && _obstacleViews[index] != null) {
            var obstacleView :ObstacleView = _obstacleViews[index];
            obstacleView.explode();
            _obstacleViews[index] = null;
        }
    }

    public function playExplosion (x :Number, y :Number, rot :int, isSmall :Boolean, shipType :int) :void
    {
        var rX :Number = x * Constants.PIXELS_PER_TILE;
        var rY :Number = y * Constants.PIXELS_PER_TILE;
        // don't add small explosions that are off the screen
        if (isSmall && (rX < -_boardSprite.x - EXP_OFF || rX > -_boardSprite.x + Constants.GAME_WIDTH + EXP_OFF ||
                        rY < -_boardSprite.y - EXP_OFF || rY > -_boardSprite.y + Constants.GAME_HEIGHT + EXP_OFF)) {
            return;
        }
        var exp :ExplosionView = ExplosionView.createExplosion(rX, rY, rot, isSmall, shipType);
        _explosionLayer.addChild(exp);
        if (isSmall) {
            if (_explosions.length == MAX_EXPLOSIONS) {
                ExplosionView(_explosions.shift()).endExplode(null);
            }
            _explosions.push(exp);
        }
    }

    public function playCustomExplosion (x :Number, y :Number, movie :MovieClip) :void
    {
        var exp :ExplosionView = new ExplosionView(
            x * Constants.PIXELS_PER_TILE, y * Constants.PIXELS_PER_TILE, movie);
        _explosionLayer.addChild(exp);
    }

    override public function hitObs (obj :BoardObject, x :Number, y :Number, owner :Boolean,
        damage :Number) :void
    {
        super.hitObs(obj, x, y, owner, damage);

        playExplosion(x, y, 0, true, 0);

        if (obj.hitSoundName != null) {
            var hitSound :Sound = Resources.getSound(obj.hitSoundName);
            if (hitSound != null) {
                ClientContext.game.playSoundAt(hitSound, x, y);
            }
        }
    }

    public function handlePowerupCollisions (ship :Ship, oldX :Number, oldY :Number) :void
    {
        // Check for collisions with powerups
        var powIdx :int = getObjectIdx(oldX, oldY, ship.boardX, ship.boardY,
            Constants.getShipType(ship.shipTypeId).size, _powerups);
        if (powIdx != -1) {
            ClientShip(ship).awardPowerup(_powerups[powIdx]);
            removePowerup(powIdx);
        }
    }

    protected var _boardLoadedCallback :Function;
    protected var _boardLoaded :Boolean;

    protected var _boardSprite :Sprite;
    protected var _obstacleLayer :Sprite;
    protected var _powerupLayer :Sprite;
    protected var _explosionLayer :Sprite;

    protected var _bg :BgSprite;

    /** All the explosions on the board. */
    protected var _explosions :Array;

    protected var _obstacleViews :Array;

    /** The maximum number of explosions on the screen at once. */
    protected static const MAX_EXPLOSIONS :int = 10;

    protected static const EXP_OFF :int = 2 * Constants.PIXELS_PER_TILE;
}

}
