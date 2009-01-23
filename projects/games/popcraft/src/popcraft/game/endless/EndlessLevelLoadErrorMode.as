package popcraft.game.endless {

import com.whirled.contrib.simplegame.AppMode;

import flash.display.Graphics;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import popcraft.*;
import popcraft.game.story.LevelSelectMode;
import popcraft.ui.UIBits;

public class EndlessLevelLoadErrorMode extends AppMode
{
    public function EndlessLevelLoadErrorMode (err :String)
    {
        _err = err;
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
                LevelSelectMode.create();
            });
        button.x = 100;
        button.y = 450;
        this.modeSprite.addChild(button);

        button = UIBits.createButton("Retry");
        registerOneShotCallback(button, MouseEvent.CLICK,
            function (...ignored) :void {
                ClientCtx.endlessLevelMgr.playSpLevel(null, true);
            });
        button.x = 50;
        button.y = 450;
        this.modeSprite.addChild(button);
    }

    protected var _err :String;
}

}
