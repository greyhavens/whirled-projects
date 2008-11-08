package popcraft.game.mpbattle {

import com.whirled.contrib.simplegame.*;

import flash.display.DisplayObject;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.text.TextFormatAlign;

import popcraft.*;
import popcraft.game.story.LevelSelectMode;
import popcraft.ui.UIBits;

public class MultiplayerFailureMode extends MultiplayerDialog
{
    override protected function setup () :void
    {
        super.setup();

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

        registerOneShotCallback(_button, MouseEvent.CLICK, handleButtonClicked);
    }

    protected function handleButtonClicked (...ignored) :void
    {
        Resources.loadLevelPackResources(Resources.SP_LEVEL_PACK_RESOURCES, LevelSelectMode.create);
    }

    protected var _button :SimpleButton;
}

}