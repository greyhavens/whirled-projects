package popcraft.mp {

import com.whirled.contrib.simplegame.*;

import flash.display.DisplayObject;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.text.TextFormatAlign;

import popcraft.*;
import popcraft.sp.story.LevelSelectMode;
import popcraft.ui.UIBits;

public class MultiplayerFailureMode extends MultiplayerDialog
{
    override protected function setup () :void
    {
        super.setup();

        var tf :DisplayObject = UIBits.createTextPanel(
            "Your enemies have fled!\nPlay the story instead?",
            3, 0, 0, TextFormatAlign.CENTER, 20, 15);

        tf.x = (Constants.SCREEN_SIZE.x - tf.width) * 0.5;
        tf.y = 30;

        this.modeSprite.addChild(tf);

        _button = UIBits.createButton("OK", 2);
        _button.addEventListener(MouseEvent.CLICK, handleButtonClicked);
        _button.x = (Constants.SCREEN_SIZE.x - _button.width) * 0.5;
        _button.y = tf.y + tf.height + 30;
        this.modeSprite.addChild(_button);
    }

    protected function handleButtonClicked (...ignored) :void
    {
        _button.removeEventListener(MouseEvent.CLICK, handleButtonClicked);

        Resources.loadLevelPackResourcesAndSwitchModes(
            Resources.SP_LEVEL_PACK_RESOURCES,
            new LevelSelectMode());
    }

    protected var _button :SimpleButton;
}

}
