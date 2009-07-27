package redrover {

import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.game.SizeChangedEvent;
import com.whirled.game.loopback.LoopbackGameControl;

import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;

import redrover.data.*;
import redrover.net.GameMessageMgr;
import redrover.server.Server;

public class RedRover extends Sprite
{
    public function RedRover ()
    {
        ClientCtx.mainSprite = this;

        // Connect to Whirled
        var gameCtrl :LoopbackGameControl = new LoopbackGameControl(this, false, false, false);

        // Start a local server
        _localServer = new Server(true);

        // initialize ClientCtx
        ClientCtx.gameCtrl = gameCtrl;
        ClientCtx.msgMgr = new GameMessageMgr(ClientCtx.gameCtrl);
        ClientCtx.seatingMgr.init(ClientCtx.gameCtrl);
        ClientCtx.localPlayerIdx = ClientCtx.seatingMgr.localPlayerSeat;

        var isConnected :Boolean = ClientCtx.gameCtrl.isConnected();

        _events.registerListener(this, Event.REMOVED_FROM_STAGE, handleUnload);

        // draw a black background
        var g :Graphics = this.graphics;
        g.beginFill(0);
        g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
        g.endFill();

        // set a clip rect
        this.scrollRect = new Rectangle(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);

        // setup simplegame
        _sg = new SimpleGame(new Config());
        ClientCtx.mainLoop = _sg.ctx.mainLoop;
        ClientCtx.rsrcs = _sg.ctx.rsrcs;
        ClientCtx.audio = _sg.ctx.audio;

        // custom resource factories
        ClientCtx.rsrcs.registerResourceType(Constants.RESTYPE_LEVEL, LevelResource);

        // sound volume
        ClientCtx.audio.masterControls.volume(
            Constants.DEBUG_DISABLE_AUDIO ? 0 : Constants.SOUND_MASTER_VOLUME);

        if (ClientCtx.gameCtrl.isConnected()) {
            // if we're connected to Whirled, keep the game centered
            _events.registerListener(ClientCtx.gameCtrl.local, SizeChangedEvent.SIZE_CHANGED,
                handleSizeChanged)

            handleSizeChanged();
        }

        _sg.run(this, (isConnected ? ClientCtx.gameCtrl.local : this.stage));
        ClientCtx.mainLoop.pushMode(new LoadingMode());
    }

    protected function handleSizeChanged (...ignored) :void
    {
        var size :Point = ClientCtx.gameCtrl.local.getSize();
        ClientCtx.mainSprite.x = (size.x * 0.5) - (Constants.SCREEN_SIZE.x * 0.5);
        ClientCtx.mainSprite.y = (size.y * 0.5) - (Constants.SCREEN_SIZE.y * 0.5);
    }

    protected function handleUnload (...ignored) :void
    {
        _events.freeAllHandlers();
        _sg.shutdown();
    }

    protected var _localServer :Server;

    protected var _sg :SimpleGame;
    protected var _events :EventHandlerManager = new EventHandlerManager();
}

}

import redrover.*;
import redrover.ui.*;
import redrover.game.GameMode;
import redrover.data.LevelData;

class LoadingMode extends GenericLoadingMode
{
    override protected function setup () :void
    {
        _loadingResources = true;
        Resources.loadResources(onLoadComplete, onLoadError);
    }

    override public function update (dt :Number) :void
    {
        super.update(dt);
        if (!_loadingResources) {
            ClientCtx.levelMgr.playLevel(0,
                function (loadedLevel :LevelData) :void {
                    ClientCtx.mainLoop.changeMode(new GameMode(loadedLevel));
                    if (!Constants.DEBUG_SKIP_INSTRUCTIONS) {
                        ClientCtx.mainLoop.pushMode(new InstructionsMode());
                    }
                });
        }
    }

    protected function onLoadComplete () :void
    {
        _loadingResources = false;
    }

    protected function onLoadError (err :String) :void
    {
        ClientCtx.mainLoop.unwindToMode(new GenericLoadErrorMode(err));
    }

    protected var _loadingResources :Boolean;
}
