package vampire.feeding.client {

import com.threerings.flash.Vector2;
import com.threerings.util.ArrayUtil;
import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.audio.AudioChannel;
import com.whirled.contrib.simplegame.net.*;
import com.whirled.contrib.simplegame.objects.SimpleSceneObject;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.util.*;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.geom.Point;
import flash.text.TextField;

import vampire.feeding.*;
import vampire.feeding.net.*;

public class GameMode extends AppMode
{
    public function GameMode ()
    {
        GameCtx.init();
        GameCtx.gameMode = this;
    }

    public function sendMultiplier (multiplier :int, x :int, y :int) :void
    {
        ClientCtx.msgMgr.sendMessage(
            CreateBonusMsg.create(ClientCtx.localPlayerId, x, y, multiplier));

        if (ClientCtx.isSinglePlayer) {
            // In single-player games, there's nobody else to volley our multipliers back
            // to us, so we fake it by sending occasionally sending fake multipliers to ourselves
            if (Rand.nextNumber(Rand.STREAM_GAME) < Constants.SP_MULTIPLIER_RETURN_CHANCE) {
                var sendMultiplierObj :SimObject = new SimObject();
                var loc :Vector2 = new Vector2(x, y);
                loc.x += Rand.nextNumberRange(5, 25, Rand.STREAM_COSMETIC);
                loc.y += Rand.nextNumberRange(5, 25, Rand.STREAM_COSMETIC);
                sendMultiplierObj.addTask(new SerialTask(
                    new TimedTask(Constants.SP_MULTIPLIER_RETURN_TIME.next()),
                    new FunctionTask(function () :void {
                        onNewMultiplier(CreateBonusMsg.create(
                            Constants.NULL_PLAYER, loc.x, loc.y, multiplier + 1));
                    }),
                    new SelfDestructTask()));
                addObject(sendMultiplierObj);
            }
        }
    }

    override protected function setup () :void
    {
        super.setup();

        registerListener(ClientCtx.msgMgr, ClientMsgEvent.MSG_RECEIVED, onMsgReceived);

        // Setup display layers
        GameCtx.bgLayer = SpriteUtil.createSprite();
        GameCtx.cellBirthLayer = SpriteUtil.createSprite();
        GameCtx.heartLayer = SpriteUtil.createSprite();
        GameCtx.burstLayer = SpriteUtil.createSprite();
        GameCtx.cellLayer = SpriteUtil.createSprite();
        GameCtx.cursorLayer = SpriteUtil.createSprite();
        GameCtx.uiLayer = SpriteUtil.createSprite(true, true);
        _modeSprite.addChild(GameCtx.bgLayer);
        _modeSprite.addChild(GameCtx.cellBirthLayer);
        _modeSprite.addChild(GameCtx.heartLayer);
        _modeSprite.addChild(GameCtx.burstLayer);
        _modeSprite.addChild(GameCtx.cellLayer);
        _modeSprite.addChild(GameCtx.cursorLayer);
        _modeSprite.addChild(GameCtx.uiLayer);

        if (Constants.DEBUG_SHOW_STATS) {
            var statView :StatView = new StatView();
            statView.x = 0;
            statView.y = 460;
            addObject(statView, GameCtx.uiLayer);
        }

        // Setup game objects
        GameCtx.bgLayer.addChild(ClientCtx.instantiateBitmap("bg"));

        var heartMovie :MovieClip = ClientCtx.instantiateMovieClip("blood", "circulatory");
        heartMovie.x = Constants.GAME_CTR.x;
        heartMovie.y = Constants.GAME_CTR.y;
        GameCtx.heartLayer.addChild(heartMovie);

        _arteries = ArrayUtil.create(2, null);
        _arteries[Constants.ARTERY_TOP] = heartMovie["artery_top"];
        _arteries[Constants.ARTERY_BOTTOM] = heartMovie["artery_bottom"];

        _sparkles = heartMovie["sparkles"];

        GameCtx.heart = new Heart(heartMovie["heart"]);
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
        addObject(timerView, GameCtx.uiLayer);

        GameCtx.scoreView = new ScoreHelpQuitView();
        GameCtx.scoreView.x = SCORE_LOC.x;
        GameCtx.scoreView.y = SCORE_LOC.y;
        addObject(GameCtx.scoreView, GameCtx.uiLayer);

        GameCtx.cursor = GameObjects.createPlayerCursor();
        registerListener(GameCtx.cursor, GameEvent.WHITE_CELL_DELIVERED, onWhiteCellDelivered);

        /* We're not doing this anymore
        // keep tabs on everyone else's score
        var yOffset :Number = 0;
        for each (var playerId :int in GameCtx.playerIds) {
            if (playerId != ClientCtx.localPlayerId) {
                var scoreView :RemotePlayerScoreView = new RemotePlayerScoreView(playerId);
                scoreView.x = SCORE_VIEWS_LOC.x;
                scoreView.y = SCORE_VIEWS_LOC.y + yOffset;
                addObject(scoreView, GameCtx.uiLayer);

                yOffset += scoreView.height + 1;
            }
        }

        addObject(new LocalScoreReporter()); // will report our score to everyone else periodically
        */

        // create some non-interactive debris that floats around the heart
        for (var ii :int = 0; ii < Constants.DEBRIS_COUNT; ++ii) {
            addObject(new Debris(), GameCtx.bgLayer);
        }

        if (ClientCtx.noMoreFeeding) {
            onNoMoreFeeding(false);
        }
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
            _musicChannel = null;
        }
    }

    protected function onMsgReceived (e :ClientMsgEvent) :void
    {
        if (e.msg is CreateBonusMsg) {
            onNewMultiplier(e.msg as CreateBonusMsg);

        } else if (e.msg is RoundOverMsg) {
            // Send our final score to the server. We'll wait for the GameResultsMsg
            // to display the round over screen.
            ClientCtx.msgMgr.sendMessage(RoundScoreMsg.create(GameCtx.scoreView.bloodCount));

        } else if (e.msg is RoundResultsMsg) {
            onRoundOver(e.msg as RoundResultsMsg);

        } else if (e.msg is NoMoreFeedingMsg) {
            onNoMoreFeeding(true);
        }
    }

    protected function onRoundOver (results :RoundResultsMsg) :void
    {
        ClientCtx.mainLoop.changeMode(new RoundOverMode(results));
    }

    protected function onNewMultiplier (msg :CreateBonusMsg) :void
    {
        if (msg.playerId != ClientCtx.localPlayerId) {
            // animate the bonus into the game, and call addMultiplierToBoard
            // when the anim completes
            var anim :NewBonusAnimation = new NewBonusAnimation(
                NewBonusAnimation.TYPE_RECEIVE,
                msg.multiplier,
                new Vector2(msg.x, msg.y),
                function () :void { addMultiplierToBoard(msg); });

            addObject(anim, GameCtx.uiLayer);
        }
    }

    protected function addMultiplierToBoard (msg :CreateBonusMsg) :void
    {
        var cell :Cell = GameObjects.createCell(Constants.CELL_MULTIPLIER, false, msg.multiplier);
        cell.x = msg.x;
        cell.y = msg.y;

        if (!ClientCtx.isSinglePlayer) {
            // show a little animation showing who gave us the multiplier
            var playerName :String = ClientCtx.getPlayerName(msg.playerId);
            var tfName :TextField = TextBits.createText(playerName, 1.4, 0, 0xffffff,
                                                        "center", TextBits.FONT_GARAMOND);
            tfName.cacheAsBitmap = true;
            var sprite :Sprite = SpriteUtil.createSprite();
            sprite.addChild(tfName);
            var animName :SimpleSceneObject = new SimpleSceneObject(sprite);
            var animX :Number = msg.x - (animName.width * 0.5);
            var animY :Number = msg.y - animName.height;
            animName.x = animX;
            animName.y = animY;
            animName.addTask(new SerialTask(
                new TimedTask(1),
                new AlphaTask(0, 0.5)));
            animName.addTask(new SerialTask(
                new TimedTask(0.5),
                LocationTask.CreateEaseIn(animX, animY - 50, 1),
                new SelfDestructTask()));
            addObject(animName, GameCtx.uiLayer);
        }
    }

    override public function update (dt :Number) :void
    {
        GameCtx.timeLeft = Math.max(GameCtx.timeLeft - dt, 0);

        // For testing purposes, end the game manually if we're in standalone mode, and
        // create some dummy game results
        if (GameCtx.timeLeft == 0 && !ClientCtx.isConnected) {
            var dummyScores :HashMap = new HashMap();
            for (var ii :int = 0; ii < 10; ++ii) {
                dummyScores.put(ii + 1, Rand.nextIntRange(50, 500, Rand.STREAM_COSMETIC));
            }
            onRoundOver(RoundResultsMsg.create(dummyScores, 1, 0.25));
            return;
        }

        // Move the player cursor towards the mouse
        var moveTarget :Vector2 = new Vector2(GameCtx.cellLayer.mouseX, GameCtx.cellLayer.mouseY);
        if (!moveTarget.equals(_lastMoveTarget)) {
            GameCtx.cursor.moveTarget = moveTarget;
            _lastMoveTarget = moveTarget;
        }

        super.update(dt);
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

    protected function onWhiteCellDelivered (e :GameEvent) :void
    {
        GameCtx.heart.deliverWhiteCell();

        // show the delivery animation
        var arteryType :int = e.data as int;
        var artery :MovieClip = _arteries[arteryType];
        artery.gotoAndPlay(2);

        _sparkles.gotoAndPlay(2);
    }

    protected function onNoMoreFeeding (animate :Boolean) :void
    {
        var color :ColorMatrix = new ColorMatrix();
        var greyscale :ColorMatrix = new ColorMatrix().makeGrayscale();

        if (animate) {
            var animObj :SimObject = new SimObject();
            animObj.addTask(new SerialTask(
                new ParallelTask(
                    new ColorMatrixBlendTask(GameCtx.bgLayer, color, greyscale, 4),
                    new ColorMatrixBlendTask(GameCtx.heartLayer, color, greyscale, 4)),
                new SelfDestructTask()));
            addObject(animObj);

        } else {
            GameCtx.bgLayer.filters = [ greyscale.createFilter() ];
            GameCtx.heartLayer.filters = [ greyscale.createFilter() ];
        }
    }

    protected var _playerType :int;
    protected var _gameOver :Boolean;
    protected var _arteries :Array;
    protected var _sparkles :MovieClip;
    protected var _lastMoveTarget :Vector2 = new Vector2();
    protected var _musicChannel :AudioChannel;

    protected static var log :Log = Log.getLog(GameMode);

    protected static const SCORE_LOC :Point = Constants.GAME_CTR.toPoint();
    protected static const TIMER_LOC :Point = Constants.GAME_CTR.toPoint();
    protected static const SCORE_VIEWS_LOC :Point = new Point(550, 120);
}

}
