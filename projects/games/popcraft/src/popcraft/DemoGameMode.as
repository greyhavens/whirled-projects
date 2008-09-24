package popcraft {

import com.whirled.contrib.simplegame.audio.*;

import popcraft.sp.story.LevelManager;
import popcraft.sp.story.StoryGameMode;

public class DemoGameMode extends StoryGameMode
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
        if (_hasSetupGame) {
            super.destroy();
        }

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
    }

    override public function get playAudio () :Boolean
    {
        return false;
    }

    override public function get canPause () :Boolean
    {
        return false;
    }

    override protected function showIntro () :void
    {
        // no-op (Demo mode has no intro)
    }

    protected var _hasLoaded :Boolean;
    protected var _hasSetupGame :Boolean;
    protected var _soundChannel :AudioChannel;

    protected static const UPDATE_DT :Number = 1/30; // 30 fps
}

}
