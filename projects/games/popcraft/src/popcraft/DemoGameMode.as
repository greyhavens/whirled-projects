package popcraft {

import com.whirled.contrib.simplegame.audio.*;

import popcraft.data.LevelData;
import popcraft.game.story.LevelManager;
import popcraft.game.story.StoryGameMode;

public class DemoGameMode extends StoryGameMode
{
    public function DemoGameMode (level :LevelData)
    {
        super(level);
    }

    override protected function setup () :void
    {
        super.setup();
        _soundChannel = ClientCtx.audio.playSoundNamed("sfx_introscreen", null, -1);
    }

    override protected function destroy () :void
    {
        _soundChannel.audioControls.fadeOut(0.5).stopAfter(0.5);
        super.destroy();
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


    protected var _soundChannel :AudioChannel;

    protected static const UPDATE_DT :Number = 1/30; // 30 fps
}

}
