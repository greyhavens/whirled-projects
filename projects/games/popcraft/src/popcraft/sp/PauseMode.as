package popcraft.sp {

import com.threerings.flash.SimpleTextButton;
import com.whirled.contrib.simplegame.AppMode;

import flash.display.Graphics;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;

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

        var bgSprite :Sprite = new Sprite();
        g = bgSprite.graphics;
        g.beginFill(0xB50000);
        g.drawRect(0, 0, 250, 200);
        g.endFill();

        bgSprite.x = (Constants.SCREEN_SIZE.x * 0.5) - (bgSprite.width * 0.5);
        bgSprite.y = (Constants.SCREEN_SIZE.y * 0.5) - (bgSprite.height * 0.5);

        this.modeSprite.addChild(bgSprite);

        // Main Menu button
        var button :SimpleButton = UIBits.createButton("Main Menu");
        button.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                AppContext.mainLoop.unwindToMode(new LevelSelectMode());
            });

        button.tabEnabled = false;
        button.x = (bgSprite.width * 0.5) - (button.width * 0.5);
        button.y = 100;
        bgSprite.addChild(button);

        // Resume button
        button = UIBits.createButton("Resume");
        button.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                AppContext.mainLoop.popMode();
            });

        button.tabEnabled = false;
        button.x = (bgSprite.width * 0.5) - (button.width * 0.5);
        button.y = 150;
        bgSprite.addChild(button);
    }

}

}
