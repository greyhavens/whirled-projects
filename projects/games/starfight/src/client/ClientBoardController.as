package client {

import com.threerings.util.HashMap;
import com.whirled.game.GameControl;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.media.Sound;

public class ClientBoardController extends BoardController
{
    public function ClientBoardController (gameCtrl :GameControl)
    {
        super(gameCtrl);
    }

    override public function setupBoard (ships :HashMap) :void
    {
        // setup our sprites before calling super.setupBoard (which will call
        // powerupAdded, obstacleAdded, etc)
        _bg = new BgSprite(width, height);
        AppContext.gameView.boardLayer.addChild(_bg);

        _boardSprite = new Sprite();
        AppContext.gameView.boardLayer.addChild(_boardSprite);

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

    override public function tick (time :int) :void
    {
        super.tick(time);

        for each (var obstacleView :ObstacleView in _obstacleViews) {
            if (obstacleView != null) {
                obstacleView.tick(time);
            }
        }
    }

    public function setAsCenter (boardX :Number, boardY :Number) :void
    {
        _boardSprite.x = Codes.GAME_WIDTH/2 - boardX*Codes.PIXELS_PER_TILE;
        _boardSprite.y = Codes.GAME_HEIGHT/2 - boardY*Codes.PIXELS_PER_TILE;
        _bg.setAsCenter(boardX, boardY);
        AppContext.gameView.status.updateRadar(_ships, _powerups, boardX, boardY);
    }

    override protected function powerupAdded (powerup :Powerup, index :int) :void
    {
        super.powerupAdded(powerup, index);
        _powerupLayer.addChild(new PowerupView(powerup));
        AppContext.gameView.status.addPowerup(index);
    }

    override protected function powerupRemoved (index :int) :void
    {
        super.powerupRemoved(index);
        AppContext.gameView.status.removePowerup(index);
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
        if (_obstacleViews != null) {
            _obstacleViews[index] = null;
        }
    }

    override public function explode (x :Number, y :Number, rot :int, isSmall :Boolean,
        shipType :int) :void
    {
        super.explode(x, y, rot, isSmall, shipType);

        var rX :Number = x * Codes.PIXELS_PER_TILE;
        var rY :Number = y * Codes.PIXELS_PER_TILE;
        // don't add small explosions that are off the screen
        if (isSmall && (rX < -_boardSprite.x - EXP_OFF || rX > -_boardSprite.x + Codes.GAME_WIDTH + EXP_OFF ||
                        rY < -_boardSprite.y - EXP_OFF || rY > -_boardSprite.y + Codes.GAME_HEIGHT + EXP_OFF)) {
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
            x * Codes.PIXELS_PER_TILE, y * Codes.PIXELS_PER_TILE, movie);
        _explosionLayer.addChild(exp);
    }

    override public function hitObs (obj :BoardObject, x :Number, y :Number, owner :Boolean,
        damage :Number) :void
    {
        super.hitObs(obj, x, y, owner, damage);
        if (obj.hitSoundName != null) {
            var hitSound :Sound = Resources.getSound(obj.hitSoundName);
            if (hitSound != null) {
                ClientContext.game.playSoundAt(hitSound, x, y);
            }
        }
    }

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

    protected static const EXP_OFF :int = 2 * Codes.PIXELS_PER_TILE;
}

}
