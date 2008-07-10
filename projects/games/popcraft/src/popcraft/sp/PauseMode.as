package popcraft.sp {

import com.whirled.contrib.simplegame.AppMode;

import flash.display.Graphics;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;

import popcraft.*;
import popcraft.ui.UIBits;

public class PauseMode extends AppMode
{
    override protected function setup () :void
    {
        // draw dim background
        var g :Graphics = this.modeSprite.graphics;
        g.beginFill(0, 0.6);
        g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
        g.endFill();

        var bgSprite :Sprite = UIBits.createFrame(250, 200);

        bgSprite.x = (Constants.SCREEN_SIZE.x * 0.5) - (bgSprite.width * 0.5);
        bgSprite.y = (Constants.SCREEN_SIZE.y * 0.5) - (bgSprite.height * 0.5);

        this.modeSprite.addChild(bgSprite);

        // "Paused" text
        var tfPaused :TextField = UIBits.createTitleText("Paused");
        tfPaused.x = (bgSprite.width * 0.5) - (tfPaused.width * 0.5);
        tfPaused.y = 25;
        bgSprite.addChild(tfPaused);

        // Resume button
        button = UIBits.createButton("Resume", 1.5);
        button.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                AppContext.mainLoop.popMode();
            });

        button.x = (bgSprite.width * 0.5) - (button.width * 0.5);
        button.y = 100;
        bgSprite.addChild(button);

        // Level Select button
        var button :SimpleButton = UIBits.createButton("End Game", 1.5);
        button.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                AppContext.mainLoop.unwindToMode(new LevelSelectMode());
            });

        button.x = (bgSprite.width * 0.5) - (button.width * 0.5);
        button.y = 150;
        bgSprite.addChild(button);
    }

}

}
