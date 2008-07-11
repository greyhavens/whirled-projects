package popcraft {

import com.whirled.contrib.simplegame.audio.*;

import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.MouseEvent;

import popcraft.sp.LevelManager;

public class DemoGameMode extends GameMode
{
    override protected function setup () :void
    {
        // don't call super.setup() here; the level hasn't been loaded yet

        AppContext.levelMgr.curLevelIndex = LevelManager.DEMO_LEVEL;
        AppContext.levelMgr.playLevel(demoLoaded);

        _soundChannel = AudioManager.instance.playSoundNamed("sfx_introscreen", null, -1);
    }

    override protected function destroy () :void
    {
        super.destroy();
        _soundChannel.audioControls.fadeOut(0.5).stopAfter(0.5);
    }

    override public function update (dt :Number) :void
    {
        if (!_hasSetupGame) {
            // don't start running the game logic until the level has loaded
            if (_hasLoaded) {
                this.setupGameScreen();
            }

        } else {
            super.update(dt);
        }
    }

    protected function demoLoaded (...ignored) :void
    {
        _hasLoaded = true;
    }

    protected function setupGameScreen () :void
    {
        _hasSetupGame = true;

        // allow the game to set itself up
        super.setup();

        // capture all mouse events that would otherwise go to the game, and discard them
        // (We're allowing the demo to be interactive for now)
        /*var mouseEater :Sprite = new Sprite();
        var g :Graphics = mouseEater.graphics;
        g.beginFill(1, 0);
        g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
        g.endFill();

        eatEvent(mouseEater, MouseEvent.CLICK);
        eatEvent(mouseEater, MouseEvent.MOUSE_DOWN);
        eatEvent(mouseEater, MouseEvent.MOUSE_UP);

        _modeLayer.addChild(mouseEater);*/
    }

    protected static function eatEvent (sprite :Sprite, eventName :String) :void
    {
        sprite.addEventListener(eventName, function (...ignored) :void {});
    }

    override public function get playAudio () :Boolean
    {
        return false;
    }

    override public function get canPause () :Boolean
    {
        return false;
    }

    override public function get showIntro () :Boolean
    {
        return false;
    }

    override public function get maxSPUpdateTime () :Number
    {
        return UPDATE_DT; // never drop below 30 fps
    }

    protected var _hasLoaded :Boolean;
    protected var _hasSetupGame :Boolean;
    protected var _soundChannel :AudioChannel;

    protected static const UPDATE_DT :Number = 1/30; // 30 fps
}

}
