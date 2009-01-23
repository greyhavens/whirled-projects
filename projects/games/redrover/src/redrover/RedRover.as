package redrover {

import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.audio.AudioManager;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.game.GameControl;
import com.whirled.game.SizeChangedEvent;

import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;

import redrover.data.*;

[SWF(width="700", height="500", frameRate="30")]
public class RedRover extends Sprite
{
    public function RedRover ()
    {
        AppContext.mainSprite = this;

        // setup GameControl
        AppContext.gameCtrl = new GameControl(this, false);
        var isConnected :Boolean = AppContext.gameCtrl.isConnected();

        _events.registerListener(this, Event.REMOVED_FROM_STAGE, handleUnload);

        // draw a black background
        var g :Graphics = this.graphics;
        g.beginFill(0);
        g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
        g.endFill();

        // set a clip rect
        this.scrollRect = new Rectangle(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);

        // setup simplegame
        var config :Config = new Config();
        config.hostSprite = this;
        config.keyDispatcher = (isConnected ? AppContext.gameCtrl.local : this.stage);
        _sg = new SimpleGame(config);
        AppContext.mainLoop = _sg.ctx.mainLoop;
        AppContext.rsrcs = _sg.ctx.rsrcs;
        AppContext.audio = _sg.ctx.audio;

        // custom resource factories
        AppContext.rsrcs.registerResourceType(Constants.RESTYPE_LEVEL, LevelResource);

        // sound volume
        AppContext.audio.masterControls.volume(
            Constants.DEBUG_DISABLE_AUDIO ? 0 : Constants.SOUND_MASTER_VOLUME);

        if (AppContext.gameCtrl.isConnected()) {
            // if we're connected to Whirled, keep the game centered
            _events.registerListener(AppContext.gameCtrl.local, SizeChangedEvent.SIZE_CHANGED,
                handleSizeChanged)

            handleSizeChanged();
        }

        _sg.run();
        AppContext.mainLoop.pushMode(new LoadingMode());
    }

    protected function handleSizeChanged (...ignored) :void
    {
        var size :Point = AppContext.gameCtrl.local.getSize();
        AppContext.mainSprite.x = (size.x * 0.5) - (Constants.SCREEN_SIZE.x * 0.5);
        AppContext.mainSprite.y = (size.y * 0.5) - (Constants.SCREEN_SIZE.y * 0.5);
    }

    protected function handleUnload (...ignored) :void
    {
        _events.freeAllHandlers();
        _sg.shutdown();
    }

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
            AppContext.levelMgr.playLevel(0,
                function (loadedLevel :LevelData) :void {
                    AppContext.mainLoop.changeMode(new GameMode(loadedLevel));
                    if (!Constants.DEBUG_SKIP_INSTRUCTIONS) {
                        AppContext.mainLoop.pushMode(new InstructionsMode());
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
        AppContext.mainLoop.unwindToMode(new GenericLoadErrorMode(err));
    }

    protected var _loadingResources :Boolean;
}
