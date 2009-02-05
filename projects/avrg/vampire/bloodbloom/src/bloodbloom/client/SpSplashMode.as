package bloodbloom.client {

import com.whirled.contrib.simplegame.AppMode;

import flash.display.Graphics;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;

import bloodbloom.*;
import bloodbloom.client.view.*;

public class SpSplashMode extends AppMode
{
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

        var predatorButton :SimpleButton = UIBits.createButton("Predator", 2, 200);
        predatorButton.x = (WIDTH - predatorButton.width) * 0.5;
        predatorButton.y = 20;
        frame.addChild(predatorButton);
        registerOneShotCallback(predatorButton, MouseEvent.CLICK,
            function (...ignored) :void {
                ClientCtx.mainLoop.changeMode(new GameMode(Constants.PLAYER_PREDATOR));
            });

        var preyButton :SimpleButton = UIBits.createButton("Prey", 2, 200);
        preyButton.x = (WIDTH - preyButton.width) * 0.5;
        preyButton.y = predatorButton.y + predatorButton.height + 10;
        frame.addChild(preyButton);
        registerOneShotCallback(preyButton, MouseEvent.CLICK,
            function (...ignored) :void {
                ClientCtx.mainLoop.changeMode(new GameMode(Constants.PLAYER_PREY));
            });
    }

    protected static const WIDTH :int = 300;
    protected static const HEIGHT :int = 150;
}

}
