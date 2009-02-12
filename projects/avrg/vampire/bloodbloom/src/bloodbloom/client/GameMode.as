package bloodbloom.client {

import bloodbloom.*;
import bloodbloom.client.view.*;
import bloodbloom.net.*;

import com.threerings.flash.Vector2;
import com.threerings.util.Log;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.audio.AudioChannel;
import com.whirled.contrib.simplegame.net.*;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.util.*;
import com.whirled.net.MessageReceivedEvent;

import flash.display.MovieClip;
import flash.filters.GlowFilter;
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
        GameCtx.bgLayer = SpriteUtil.createSprite();
        GameCtx.cellLayer = SpriteUtil.createSprite();
        GameCtx.cursorLayer = SpriteUtil.createSprite();
        GameCtx.effectLayer = SpriteUtil.createSprite();
        _modeSprite.addChild(GameCtx.bgLayer);
        _modeSprite.addChild(GameCtx.cellLayer);
        _modeSprite.addChild(GameCtx.cursorLayer);
        _modeSprite.addChild(GameCtx.effectLayer);

        if (Constants.DEBUG_SHOW_STATS) {
            var statView :StatView = new StatView();
            statView.x = 0;
            statView.y = 460;
            addObject(statView, GameCtx.effectLayer);
        }

        // Setup game objects
        GameCtx.heart = new Heart();
        GameCtx.gameMode.addObject(GameCtx.heart);
        registerListener(GameCtx.heart, GameEvent.HEARTBEAT, onHeartbeat);

        // spawn white cells on a timer separate from the heartbeat
        var whiteCellSpawner :SimObject = new SimObject();
        whiteCellSpawner.addTask(new RepeatingTask(
            new VariableTimedTask(
                Constants.WHITE_CELL_CREATION_TIME.min,
                Constants.WHITE_CELL_CREATION_TIME.max,
                Rand.STREAM_GAME),
            new FunctionTask(function () :void {
                spawnCells(Constants.CELL_WHITE, Constants.WHITE_CELL_CREATION_COUNT.next());
            })));
        addObject(whiteCellSpawner);

        var timerView :TimerView = new TimerView();
        timerView.x = TIMER_LOC.x;
        timerView.y = TIMER_LOC.y;
        addObject(timerView, GameCtx.effectLayer);

        GameCtx.bloodMeter = new PredatorBloodMeter();
        GameCtx.bloodMeter.x = BLOOD_METER_LOC.x;
        GameCtx.bloodMeter.y = BLOOD_METER_LOC.y;
        addObject(GameCtx.bloodMeter, GameCtx.effectLayer);

        GameCtx.bgLayer.addChild(ClientCtx.instantiateBitmap("bg"));

        var heartMovie :MovieClip = ClientCtx.instantiateMovieClip("blood", "circulatory");
        heartMovie.x = Constants.GAME_CTR.x;
        heartMovie.y = Constants.GAME_CTR.y;
        GameCtx.bgLayer.addChild(heartMovie);

        _arteryBottom = heartMovie["artery_bottom"];
        _arteryTop = heartMovie["artery_TOP"];

        var heartView :HeartView = new HeartView(heartMovie["heart"]);
        addObject(heartView);

        // cursors
        GameCtx.cursor = GameObjects.createPlayerCursor(_playerType);
        registerListener(GameCtx.cursor, GameEvent.WHITE_CELL_DELIVERED, onWhiteCellDelivered);

        // create initial cells
        /*for (var cellType :int = 0; cellType < Constants.CELL__LIMIT; ++cellType) {
            var count :int = Constants.INITIAL_CELL_COUNT[cellType];
            for (var ii :int = 0; ii < count; ++ii) {
                var loc :Vector2 = Cell.getBirthTargetLoc(cellType);
                var cell :Cell = GameObjects.createCell(cellType, false);
                cell.x = loc.x;
                cell.y = loc.y;
            }
        }*/
    }

    override protected function enter () :void
    {
        super.enter();
        if (_musicChannel == null) {
            _musicChannel = ClientCtx.audio.playSoundNamed("mus_music", null, -1);
        }
    }

    override protected function destroy () :void
    {
        if (_musicChannel != null) {
            _musicChannel.audioControls.fadeOutAndStop(0.5);
        }
    }

    protected function setupNetwork () :void
    {
        if (ClientCtx.isConnected) {
            ClientCtx.gameCtrl.game.playerReady();
            registerListener(ClientCtx.gameCtrl.net, MessageReceivedEvent.MESSAGE_RECEIVED,
                onMsgReceived);
        }
    }

    protected function onMsgReceived (e :MessageReceivedEvent) :void
    {
        var msg :Message = ClientCtx.msgMgr.deserializeMessage(e.name, e.value);
        if (msg is CreateBonusMsg) {
            onNewMultiplier(msg as CreateBonusMsg);
        }
    }

    protected function onNewMultiplier (msg :CreateBonusMsg) :void
    {
        if (msg.playerId != ClientCtx.localPlayerId) {
            var cell :Cell = GameObjects.createCell(Constants.CELL_BONUS, false);
            cell.x = msg.x;
            cell.y = msg.y;
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
        _arteryTop.filters = (hiliteTop ? [ new GlowFilter(0x00ff00) ] : []);
        _arteryBottom.filters = (hiliteBottom ? [ new GlowFilter(0x00ff00) ] : []);
    }

    protected function onHeartbeat (...ignored) :void
    {
        // spawn new red cells
        spawnCells(Constants.CELL_RED, Constants.BEAT_CELL_BIRTH_COUNT.next());
    }

    protected function spawnCells (cellType :int, count :int) :void
    {
        count = Math.min(count, Constants.MAX_CELL_COUNT[cellType] - Cell.getCellCount(cellType));
        for (var ii :int = 0; ii < count; ++ii) {
            GameObjects.createCell(cellType, true);
        }
    }

    protected function onWhiteCellDelivered (...ignored) :void
    {
        GameCtx.heart.deliverWhiteCell();
    }

    protected var _playerType :int;
    protected var _gameOver :Boolean;
    protected var _arteryTop :MovieClip;
    protected var _arteryBottom :MovieClip;
    protected var _lastMoveTarget :Vector2 = new Vector2();
    protected var _musicChannel :AudioChannel;

    protected static var log :Log = Log.getLog(GameMode);

    protected static const BLOOD_METER_LOC :Point = new Point(550, 75);
    protected static const TIMER_LOC :Point = new Point(550, 25);
}

}
