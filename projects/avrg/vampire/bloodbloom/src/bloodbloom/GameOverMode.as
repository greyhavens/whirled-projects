package bloodbloom {

import com.whirled.contrib.simplegame.AppMode;

import flash.display.Graphics;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;

public class GameOverMode extends AppMode
{
    public function GameOverMode (reason :String)
    {
        _reason = reason;
    }

    override protected function setup () :void
    {
        var g :Graphics = _modeSprite.graphics;
        g.beginFill(0);
        g.drawRect(0, 0, 700, 500);
        g.endFill();

        var frame :Sprite = UIBits.createFrame(WIDTH, HEIGHT);
        frame.x = (_modeSprite.width - WIDTH) * 0.5;
        frame.y = (_modeSprite.height - HEIGHT) * 0.5;
        _modeSprite.addChild(frame);

        var tfTitle :TextField = UIBits.createTitleText("Game Over");
        tfTitle.x = (WIDTH - tfTitle.width) * 0.5;
        tfTitle.y = 20;
        frame.addChild(tfTitle);

        var tfReason :TextField = UIBits.createText(_reason, 1.3);
        tfReason.x = (WIDTH - tfReason.width) * 0.5;
        tfReason.y = tfTitle.y + tfTitle.height + 10;
        frame.addChild(tfReason);

        var againButton :SimpleButton = UIBits.createButton("Again", 1.5);
        againButton.x = (WIDTH - againButton.width) * 0.5;
        againButton.y = tfReason.y + tfReason.height + 10;
        frame.addChild(againButton);
        registerOneShotCallback(againButton, MouseEvent.CLICK,
            function (...ignored) :void {
                ClientCtx.mainLoop.unwindToMode(new SpSplashMode());
            });
    }

    protected var _reason :String;

    protected static const WIDTH :int = 300;
    protected static const HEIGHT :int = 200;
}

}
