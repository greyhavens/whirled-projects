package popcraft {

import com.whirled.contrib.simplegame.*;

import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import popcraft.sp.LevelSelectMode;
import popcraft.ui.UIBits;

public class MultiplayerFailureMode extends SplashScreenModeBase
{
    override protected function setup () :void
    {
        super.setup();

        var tf :TextField = new TextField();
        tf.selectable = false;
        tf.multiline = true;
        tf.scaleX = 2;
        tf.scaleY = 2;
        tf.background = true;
        tf.backgroundColor = 0;
        tf.textColor = 0xFFFFFF;
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.text = "Your enemies have fled!\nTry the single-player game instead?";
        tf.x = (Constants.SCREEN_SIZE.x * 0.5) - (tf.width * 0.5);
        tf.y = (Constants.SCREEN_SIZE.y * 0.5) - (tf.height * 0.5);

        // center the text
        var format :TextFormat = new TextFormat();
        format.align = TextFormatAlign.CENTER;
        tf.setTextFormat(format);

        this.modeSprite.addChild(tf);

        _button = UIBits.createButton("OK");
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
