package popcraft {

import com.whirled.contrib.simplegame.*;

import flash.display.DisplayObject;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.text.TextFormatAlign;

import popcraft.sp.LevelSelectMode;
import popcraft.ui.UIBits;

public class MultiplayerFailureMode extends SplashScreenModeBase
{
    override protected function setup () :void
    {
        super.setup();

        var tf :DisplayObject = UIBits.createTextPanel(
            "Your enemies have fled!\nPlay the story instead?",
            3, 0, 0, TextFormatAlign.CENTER, 20, 15);

        tf.x = (Constants.SCREEN_SIZE.x * 0.5) - (tf.width * 0.5);
        tf.y = (Constants.SCREEN_SIZE.y * 0.5) - (tf.height * 0.5);

        this.modeSprite.addChild(tf);

        _button = UIBits.createButton("OK", 2);
        _button.addEventListener(MouseEvent.CLICK, handleButtonClicked);
        _button.x = (Constants.SCREEN_SIZE.x * 0.5) - (_button.width * 0.5);
        _button.y = 350;
        this.modeSprite.addChild(_button);
    }

    protected function handleButtonClicked (...ignored) :void
    {
        _button.removeEventListener(MouseEvent.CLICK, handleButtonClicked);
        AppContext.mainLoop.unwindToMode(new LevelSelectMode());
    }

    protected var _button :SimpleButton;
}

}
