package popcraft.sp {

import com.threerings.flash.SimpleTextButton;
import com.whirled.contrib.simplegame.AppMode;

import flash.display.Graphics;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import popcraft.*;

public class LevelLoadErrorMode extends AppMode
{
    public function LevelLoadErrorMode (err :String)
    {
        _err = err;
    }

    override protected function setup () :void
    {
        var g :Graphics = this.modeSprite.graphics;
        g.beginFill(0xFF7272);
        g.drawRect(0, 0, Constants.SCREEN_DIMS.x, Constants.SCREEN_DIMS.y);
        g.endFill();

        var tf :TextField = new TextField();
        tf.multiline = true;
        tf.wordWrap = true;
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.scaleX = 1.5;
        tf.scaleY = 1.5;
        tf.width = 400;
        tf.x = 50;
        tf.y = 50;
        tf.text = _err;

        this.modeSprite.addChild(tf);

        var button :SimpleButton = new SimpleTextButton("Back");
        button.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                AppContext.mainLoop.changeMode(new LevelSelectMode());
            });
        button.x = 100;
        button.y = 450;
        this.modeSprite.addChild(button);

        button = new SimpleTextButton("Retry");
        button.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                AppContext.levelMgr.playLevel(true);
            });
        button.x = 50;
        button.y = 450;
        this.modeSprite.addChild(button);
    }

    protected var _err :String;
}

}
