package popcraft.sp.endless {

import com.whirled.contrib.simplegame.*;

import flash.display.Graphics;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.text.TextField;

import popcraft.*;
import popcraft.ui.UIBits;

public class EndlessSpGameOverMode extends AppMode
{
    public function EndlessSpGameOverMode ()
    {
        var g :Graphics = this.modeSprite.graphics;
        g.beginFill(0, 1);
        g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
        g.endFill();

        var text :TextField = new TextField();
        UIBits.initTextField(text, "You have died of dysentery.", 2,
            Constants.SCREEN_SIZE.x - 30, 0xFFFFFF);
        text.x = (Constants.SCREEN_SIZE.x - text.width) * 0.5;
        text.y = (Constants.SCREEN_SIZE.y - text.height) * 0.5;
        this.modeSprite.addChild(text);

        var retry :SimpleButton = UIBits.createButton("Play Again!", 1.5);
        retry.x = Constants.SCREEN_SIZE.x - retry.width - 15;
        retry.y = Constants.SCREEN_SIZE.y - retry.height - 15;
        this.modeSprite.addChild(retry);
        this.registerOneShotCallback(retry, MouseEvent.CLICK,
            function (...ignored) :void {
                AppContext.endlessLevelMgr.playSpLevel();
            });

        var mainMenu :SimpleButton = UIBits.createButton("Main Menu", 1.5);
        mainMenu.x = retry.x - mainMenu.width - 3;
        mainMenu.y = Constants.SCREEN_SIZE.y - mainMenu.height - 15;
        this.modeSprite.addChild(mainMenu);
        this.registerOneShotCallback(mainMenu, MouseEvent.CLICK,
            function (...ignored) :void {
                AppContext.mainLoop.pushMode(new EndlessLevelSelectMode());
            });
    }

}

}
