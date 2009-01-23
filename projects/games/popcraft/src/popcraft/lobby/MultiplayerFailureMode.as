package popcraft.lobby {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.resource.ImageResource;

import flash.display.DisplayObject;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.text.TextFormatAlign;

import popcraft.*;
import popcraft.game.story.LevelSelectMode;
import popcraft.ui.UIBits;

public class MultiplayerFailureMode extends TransitionMode
{
    override protected function setup () :void
    {
        super.setup();

        _modeLayer.addChild(ImageResource.instantiateBitmap("zombieBg"));
        _soundChannel = AudioManager.instance.playSoundNamed("sfx_introscreen", null, -1);

        var tf :DisplayObject = UIBits.createTextPanel(
            "Your classmates have fled!\nPlay by yourself instead?",
            3, 0, 0, TextFormatAlign.CENTER, 20, 15);

        tf.x = (Constants.SCREEN_SIZE.x - tf.width) * 0.5;
        tf.y = 30;

        this.modeSprite.addChild(tf);

        _button = UIBits.createButton("OK", 2);
        _button.x = (Constants.SCREEN_SIZE.x - _button.width) * 0.5;
        _button.y = tf.y + tf.height + 30;
        this.modeSprite.addChild(_button);

        registerOneShotCallback(_button, MouseEvent.CLICK,
            function (...ignored) :void {
                Resources.loadLevelPackResources(Resources.SP_LEVEL_PACK_RESOURCES,
                                                 LevelSelectMode.create);
            });
    }

    override protected function destroy () :void
    {
        _soundChannel.audioControls.fadeOut(0.5).stopAfter(0.5);
        super.destroy();
    }

    protected var _button :SimpleButton;
    protected var _soundChannel :AudioChannel;
}

}
