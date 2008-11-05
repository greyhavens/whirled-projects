package popcraft.game.mpbattle {

import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.resource.ImageResource;

import popcraft.TransitionMode;

public class MultiplayerDialog extends TransitionMode
{
    override protected function setup () :void
    {
        _modeLayer.addChild(ImageResource.instantiateBitmap("zombieBg"));
        _soundChannel = AudioManager.instance.playSoundNamed("sfx_introscreen", null, -1);
    }

    override protected function destroy () :void
    {
        _soundChannel.audioControls.fadeOut(0.5).stopAfter(0.5);
    }

    protected var _soundChannel :AudioChannel;

}

}
