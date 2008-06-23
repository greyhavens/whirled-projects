package popcraft {

import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.resource.SwfResource;

public class SplashScreenModeBase extends AppMode
{
    override protected function setup () :void
    {
        this.modeSprite.addChild(SwfResource.getSwfDisplayRoot("splash"));
        _soundChannel = AudioManager.instance.playSoundNamed("sfx_introscreen", null, -1);
    }

    override protected function destroy () :void
    {
        _soundChannel.audioControls.fadeOut(0.5).stopAfter(0.5);
    }

    protected var _soundChannel :AudioChannel;

}

}
