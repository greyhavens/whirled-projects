package bloodbloom.client {

import bloodbloom.*;
import bloodbloom.client.view.*;
import bloodbloom.net.*;

import com.threerings.flash.Vector2;
import com.threerings.util.Log;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.net.*;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.util.*;

import flash.display.MovieClip;
import flash.geom.Point;

public class GameMode extends AppMode
{
    public function GameMode (playerType :int)
    {
        _playerType = playerType;
    }

    override protected function setup () :void
    {
        super.setup();

        GameCtx.init();
        GameCtx.gameMode = this;

        setupNetwork();

        // Setup display layers
        _modeSprite.addChild(ClientCtx.instantiateBitmap("bg"));

        GameCtx.cellLayer = SpriteUtil.createSprite();
        GameCtx.cursorLayer = SpriteUtil.createSprite();
        GameCtx.effectLayer = SpriteUtil.createSprite();
        _modeSprite.addChild(GameCtx.cellLayer);
        _modeSprite.addChild(GameCtx.cursorLayer);
        _modeSprite.addChild(GameCtx.effectLayer);

        if (Constants.DEBUG_SHOW_STATS) {
            var statView :StatView = new StatView();
            statView.x = 0;
            statView.y = 460;
            addObject(statView, _modeSprite);
        }

        // Setup game objects
        GameCtx.heart = new Heart();
        GameCtx.gameMode.addObject(GameCtx.heart);

        var timerView :TimerView = new TimerView();
        timerView.x = TIMER_LOC.x;
        timerView.y = TIMER_LOC.y;
        addObject(timerView, GameCtx.effectLayer);

        GameCtx.bloodMeter = new PredatorBloodMeter();
        GameCtx.bloodMeter.x = BLOOD_METER_LOC.x;
        GameCtx.bloodMeter.y = BLOOD_METER_LOC.y;
        addObject(GameCtx.bloodMeter, GameCtx.effectLayer);

        var heartMovie :MovieClip = ClientCtx.instantiateMovieClip("blood", "circulatory");
        heartMovie.x = Constants.GAME_CTR.x;
        heartMovie.y = Constants.GAME_CTR.y;
        _modeSprite.addChild(heartMovie);

        _arteryBottom = heartMovie["artery_bottom"];
        _arteryTop = heartMovie["artery_TOP"];

        var heartView :HeartView = new HeartView(heartMovie["heart"]);
        addObject(heartView);

        // cursors
        GameCtx.cursor = GameObjects.createPlayerCursor(_playerType);

        // create initial cells
        for (var cellType :int = 0; cellType < Constants.CELL__LIMIT; ++cellType) {
            var count :int = Constants.INITIAL_CELL_COUNT[cellType];
            for (var ii :int = 0; ii < count; ++ii) {
                var loc :Vector2 = Cell.getBirthTargetLoc(cellType);
                var cell :Cell = GameObjects.createCell(cellType, false);
                cell.x = loc.x;
                cell.y = loc.y;
            }
        }
    }

    protected function setupNetwork () :void
    {
        if (ClientCtx.isConnected) {
            ClientCtx.gameCtrl.game.playerReady();
        }
    }

    override public function update (dt :Number) :void
    {
        GameCtx.timeLeft -= dt;
        if (GameCtx.timeLeft <= 0) {
            gameOver("Final score: " + GameCtx.bloodMeter.bloodCount);
        }

        // Move the player cursor towards the mouse
        var moveTarget :Vector2 = new Vector2(GameCtx.cellLayer.mouseX, GameCtx.cellLayer.mouseY);
        if (!moveTarget.equals(_lastMoveTarget)) {
            GameCtx.cursor.moveTarget = moveTarget;
            _lastMoveTarget = moveTarget;
        }

        super.update(dt);
    }

    public function gameOver (reason :String) :void
    {
        if (!_gameOver) {
            ClientCtx.mainLoop.changeMode(new GameOverMode(reason));
            _gameOver = true;
        }
    }

    public function hiliteArteries (hiliteTop :Boolean, hiliteBottom :Boolean) :void
    {
        //_arteryTop.filters = (hiliteTop ? [ new GlowFilter(0x00ff00) ] : []);
        //_arteryBottom.filters = (hiliteBottom ? [ new GlowFilter(0x00ff00) ] : []);
    }

    protected var _playerType :int;
    protected var _gameOver :Boolean;
    protected var _arteryTop :MovieClip;
    protected var _arteryBottom :MovieClip;
    protected var _lastMoveTarget :Vector2 = new Vector2();

    protected static var log :Log = Log.getLog(GameMode);

    protected static const BLOOD_METER_LOC :Point = new Point(550, 75);
    protected static const TIMER_LOC :Point = new Point(550, 25);
}

}
