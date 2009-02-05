package bloodbloom.client {

import bloodbloom.*;
import bloodbloom.client.view.*;

import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.SimObjectRef;
import com.whirled.contrib.simplegame.net.OfflineTickedMessageManager;
import com.whirled.contrib.simplegame.net.OnlineTickedMessageManager;
import com.whirled.contrib.simplegame.net.TickedMessageManager;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.util.Rand;

import flash.display.Bitmap;
import flash.display.DisplayObjectContainer;
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
        GameCtx.heartbeatDb = new NetObjDb();

        // network stuff
        _msgMgr = (ClientCtx.isConnected ?
            new OnlineTickedMessageManager(ClientCtx.gameCtrl,
                false,
                Constants.HEARTBEAT_TIME * 1000,
                Constants.MSG_S_HEARTBEAT) :
            new OfflineTickedMessageManager(ClientCtx.gameCtrl,
                Constants.HEARTBEAT_TIME * 1000));
        _msgMgr.run();

        if (ClientCtx.isConnected) {
            ClientCtx.gameCtrl.game.playerReady();
        }

        // Setup display layers
        _modeSprite.addChild(ClientCtx.instantiateBitmap("bg"));

        _arteryBottom = ClientCtx.instantiateBitmap("artery_blue");
        _arteryBottom.x = Constants.GAME_CTR.x - (_arteryBottom.width * 0.5);
        _arteryBottom.y = 290;
        _modeSprite.addChild(_arteryBottom);

        _arteryTop = ClientCtx.instantiateBitmap("artery_red");
        _arteryTop.x = Constants.GAME_CTR.x - (_arteryTop.width * 0.5);
        _arteryTop.y = 30;
        _modeSprite.addChild(_arteryTop);

        GameCtx.cellLayer = SpriteUtil.createSprite();
        GameCtx.cursorLayer = SpriteUtil.createSprite();
        GameCtx.effectLayer = SpriteUtil.createSprite();
        _modeSprite.addChild(GameCtx.cellLayer);
        _modeSprite.addChild(GameCtx.cursorLayer);
        _modeSprite.addChild(GameCtx.effectLayer);

        // Setup game objects
        GameCtx.beat = new Beat();
        GameCtx.heartbeatDb.addObject(GameCtx.beat);

        GameCtx.bloodMeter = new PredatorBloodMeter();
        GameCtx.bloodMeter.x = BLOOD_METER_LOC.x;
        GameCtx.bloodMeter.y = BLOOD_METER_LOC.y;
        addObject(GameCtx.bloodMeter, GameCtx.effectLayer);

        var heart :Heart = new Heart();
        heart.x = Constants.GAME_CTR.x;
        heart.y = Constants.GAME_CTR.y;
        addObject(heart, GameCtx.cellLayer);

        // spawn cells when the heart beats
        registerListener(GameCtx.beat, GameEvent.HEARTBEAT,
            function (...ignored) :void {
                var count :int = Constants.BEAT_CELL_BIRTH_COUNT.next();
                count = Math.min(count, Constants.MAX_CELL_COUNT - Cell.getCellCount());
                for (var ii :int = 0; ii < count; ++ii) {
                    var cellType :int =
                        (Rand.nextNumber(Rand.STREAM_GAME) <= Constants.RED_CELL_PROBABILITY ?
                            Constants.CELL_RED : Constants.CELL_WHITE);

                    GameObjects.createCell(cellType, true);
                }
            });

        // cursors
        GameCtx.prey = new PreyCursor(_playerType == Constants.PLAYER_PREY);
        addObject(GameCtx.prey, GameCtx.cursorLayer);
        addObject(new PredatorCursor(_playerType == Constants.PLAYER_PREDATOR), GameCtx.cursorLayer);
    }

    override protected function destroy () :void
    {
        _msgMgr.stop();
        super.destroy();
    }

    override public function update (dt :Number) :void
    {
        super.update(dt);

        // process our network ticks
        _msgMgr.update(dt);
        while (_msgMgr.unprocessedTickCount > 0) {
            var tick :Array = _msgMgr.getNextTick();
            GameCtx.heartbeatDb.update(Constants.HEARTBEAT_TIME);
        }

        _modeTime += dt;
    }

    public function gameOver (reason :String) :void
    {
        if (!_gameOver) {
            ClientCtx.mainLoop.changeMode(new GameOverMode(reason));
            _gameOver = true;
        }
    }

    public function get modeTime () :Number
    {
        return _modeTime;
    }

    public function hiliteArteries (hiliteTop :Boolean, hiliteBottom :Boolean) :void
    {
        _arteryTop.filters = (hiliteTop ? [ new GlowFilter(0x00ff00) ] : []);
        _arteryBottom.filters = (hiliteBottom ? [ new GlowFilter(0x00ff00) ] : []);
    }

    override public function addObject (obj :SimObject,
        displayParent :DisplayObjectContainer = null) :SimObjectRef
    {
        if (obj is NetObj) {
            throw new Error("HeartBeatObjs cannot be added to GameMode");
        } else {
            return super.addObject(obj, displayParent);
        }
    }

    protected var _playerType :int;
    protected var _modeTime :Number = 0;
    protected var _gameOver :Boolean;
    protected var _arteryTop :Bitmap;
    protected var _arteryBottom :Bitmap;
    protected var _msgMgr :TickedMessageManager;

    protected static const BLOOD_METER_LOC :Point = new Point(550, 75);
}

}
