package bloodbloom.client {

import bloodbloom.*;
import bloodbloom.client.view.*;
import bloodbloom.net.*;

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.net.*;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.util.*;
import com.whirled.net.PropertyChangedEvent;

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
        GameCtx.netObjDb = new NetObjDb();

        setupNetwork();

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

        var statView :StatView = new StatView();
        statView.x = 0;
        statView.y = 460;
        addObject(statView, _modeSprite);

        // Setup game objects
        GameCtx.heart = new Heart();
        GameCtx.netObjDb.addObject(GameCtx.heart);

        GameCtx.bloodMeter = new PredatorBloodMeter();
        GameCtx.bloodMeter.x = BLOOD_METER_LOC.x;
        GameCtx.bloodMeter.y = BLOOD_METER_LOC.y;
        addObject(GameCtx.bloodMeter, GameCtx.effectLayer);

        var heart :HeartView = new HeartView();
        heart.x = Constants.GAME_CTR.x;
        heart.y = Constants.GAME_CTR.y;
        addObject(heart, GameCtx.cellLayer);

        // cursors
        GameCtx.predator = GameObjects.createPlayerCursor(Constants.PLAYER_PREDATOR);
        GameCtx.prey = GameObjects.createPlayerCursor(Constants.PLAYER_PREY);
    }

    protected function setupNetwork () :void
    {
        _msgMgr = (ClientCtx.isConnected ?
            new OnlineTickedMessageManager(ClientCtx.gameCtrl,
                false,
                Constants.HEARTBEAT_TIME * 1000,
                Constants.MSG_S_HEARTBEAT) :
            new OfflineTickedMessageManager(ClientCtx.gameCtrl,
                Constants.HEARTBEAT_TIME * 1000));
        _msgMgr.addMessageType(CursorTargetMsg);
        _msgMgr.run();

        if (ClientCtx.isConnected) {
            ClientCtx.gameCtrl.game.playerReady();

            registerListener(
                ClientCtx.gameCtrl.net,
                PropertyChangedEvent.PROPERTY_CHANGED,
                checkIsInited);

            checkIsInited();

            // wait for the INITED property to be true; at that point, we can seed our RNG;
            // the game will begin receiving heartbeat messages shortly afterwards
            function checkIsInited (...ignored) :void {
                if (ClientCtx.gameCtrl.net.get(Constants.PROP_INITED) as Boolean) {
                    var randSeed :uint = ClientCtx.gameCtrl.net.get(Constants.PROP_RAND_SEED) as uint;
                    Rand.seedStream(Rand.STREAM_GAME, randSeed);
                    unregisterListener(
                        ClientCtx.gameCtrl.net,
                        PropertyChangedEvent.PROPERTY_CHANGED,
                        checkIsInited);
                }
            }

        } else {
            Rand.seedStream(Rand.STREAM_GAME, uint(Math.random() * uint.MAX_VALUE));
        }
    }

    override protected function destroy () :void
    {
        _msgMgr.stop();
        super.destroy();
    }

    override public function update (dt :Number) :void
    {
        // process our network ticks (updates network objects)
        _msgMgr.update(dt);
        while (_msgMgr.unprocessedTickCount > 0) {
            for each (var msg :Object in _msgMgr.getNextTick()) {
                handleGameMessage(msg);
            }

            GameCtx.netObjDb.update(Constants.HEARTBEAT_TIME);
        }

        // update all the view objects
        _modeTime += dt;
        super.update(dt);

        // send cursor target messages when the mouse moves.
        //if (this.modeTime - _lastCursorUpdate >= 0.5) {
            var mouseX :int = GameCtx.cursorLayer.mouseX;
            var mouseY :int = GameCtx.cursorLayer.mouseY;
            if (mouseX != _lastMouseX && mouseY != _lastMouseY) {
                _msgMgr.sendMessage(CursorTargetMsg.create(_playerType, mouseX, mouseY));
                _lastMouseX = mouseX;
                _lastMouseY = mouseY;
                _lastCursorUpdate = this.modeTime;
            }
        //}
    }

    protected function handleGameMessage (msg :Object) :void
    {
        if (msg is CursorTargetMsg) {
            var cursorTargetMsg :CursorTargetMsg = msg as CursorTargetMsg;
            var cursor :PlayerCursor = (cursorTargetMsg.playerId == Constants.PLAYER_PREDATOR ?
                GameCtx.predator :
                GameCtx.prey);
            cursor.moveTarget = new Vector2(cursorTargetMsg.x, cursorTargetMsg.y);
        }
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
            throw new Error("NetObjs cannot be added to GameMode");
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
    protected var _lastMouseX :int = -1;
    protected var _lastMouseY :int = -1;

    protected var _lastCursorUpdate :Number = 0;

    protected static const BLOOD_METER_LOC :Point = new Point(550, 75);
}

}
