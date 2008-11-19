package redrover.ui {

import com.whirled.contrib.simplegame.AppMode;

import flash.display.Graphics;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import redrover.*;

public class LevelLoadErrorMode extends AppMode
{
    public function LevelLoadErrorMode (err :String, levelIndex :int, levelReadyCallback :Function)
    {
        _err = err;
        _levelIndex = levelIndex;
        _levelReadyCallback = levelReadyCallback;
    }

    override protected function setup () :void
    {
        var g :Graphics = this.modeSprite.graphics;
        g.beginFill(0xFF7272);
        g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
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

        var button :SimpleButton = UIBits.createButton("Back");
        registerOneShotCallback(button, MouseEvent.CLICK,
            function (...ignored) :void {
                AppContext.mainLoop.popMode();
            });
        button.x = 100;
        button.y = 450;
        this.modeSprite.addChild(button);

        button = UIBits.createButton("Retry");
        registerOneShotCallback(button, MouseEvent.CLICK,
            function (...ignored) :void {
                AppContext.levelMgr.playLevel(_levelIndex, _levelReadyCallback);
            });
        button.x = 50;
        button.y = 450;
        this.modeSprite.addChild(button);
    }

    protected var _err :String;
    protected var _levelIndex :int;
    protected var _levelReadyCallback :Function;
}

}
