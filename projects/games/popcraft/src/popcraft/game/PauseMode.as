package popcraft.game {

import com.whirled.contrib.simplegame.AppMode;

import flash.display.Graphics;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;

import popcraft.*;
import popcraft.game.story.LevelSelectMode;
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

        var windowElements :Sprite = new Sprite();

        var tfTitle :TextField = UIBits.createTitleText("Paused");
        tfTitle.x = -(tfTitle.width * 0.5);
        tfTitle.y = 0;
        windowElements.addChild(tfTitle);

        var resumeBtn :SimpleButton = UIBits.createButton("Resume", 2.5, 300);
        resumeBtn.x = -(resumeBtn.width * 0.5);
        resumeBtn.y = windowElements.height + 20;
        windowElements.addChild(resumeBtn);
        registerOneShotCallback(resumeBtn, MouseEvent.CLICK,
            function (...ignored) :void {
                ClientCtx.mainLoop.popMode();
            });

        var endBtn :SimpleButton = UIBits.createButton("End Game", 1.5, 300);
        endBtn.x = -(endBtn.width * 0.5);
        endBtn.y = windowElements.height + 10;
        windowElements.addChild(endBtn);
        registerOneShotCallback(endBtn, MouseEvent.CLICK,
            function (...ignored) :void {
                LevelSelectMode.create();
            });

        var frame :Sprite = UIBits.createFrame(WIDTH, windowElements.height + (V_BORDER * 2));
        frame.x = (Constants.SCREEN_SIZE.x - WIDTH) * 0.5;
        frame.y = (Constants.SCREEN_SIZE.y - frame.height) * 0.5;
        _modeSprite.addChild(frame);

        windowElements.x = Constants.SCREEN_SIZE.x * 0.5;
        windowElements.y = (Constants.SCREEN_SIZE.y - windowElements.height) * 0.5;
        _modeSprite.addChild(windowElements);
    }

    protected static const WIDTH :Number = 370;
    protected static const V_BORDER :Number = 25;
}

}
