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

        /*var bgSprite :Sprite = UIBits.createFrame(250, 200);

        bgSprite.x = (Constants.SCREEN_SIZE.x * 0.5) - (bgSprite.width * 0.5);
        bgSprite.y = (Constants.SCREEN_SIZE.y * 0.5) - (bgSprite.height * 0.5);

        this.modeSprite.addChild(bgSprite);

        // "Paused" text
        var tfPaused :TextField = UIBits.createTitleText("Paused");
        tfPaused.x = (bgSprite.width * 0.5) - (tfPaused.width * 0.5);
        tfPaused.y = 25;
        bgSprite.addChild(tfPaused);

        // Resume button
        button = UIBits.createButton("Resume", 1.5, 150);
        registerOneShotCallback(button, MouseEvent.CLICK,
            function (...ignored) :void {
                ClientCtx.mainLoop.popMode();
            });

        button.x = (bgSprite.width * 0.5) - (button.width * 0.5);
        button.y = 90;
        bgSprite.addChild(button);

        // Level Select button
        var button :SimpleButton = UIBits.createButton("End Game", 1.5, 150);
        registerOneShotCallback(button, MouseEvent.CLICK,
            function (...ignored) :void {
                LevelSelectMode.create();
            });

        button.x = (bgSprite.width * 0.5) - (button.width * 0.5);
        button.y = 140;
        bgSprite.addChild(button);*/

        var windowElements :Sprite = new Sprite();

        var tfTitle :TextField = UIBits.createTitleText("Paused");
        tfTitle.x = -(tfTitle.width * 0.5);
        tfTitle.y = 0;
        windowElements.addChild(tfTitle);

        var resumeBtn :SimpleButton = UIBits.createButton("Resume", 2, 240);
        resumeBtn.x = -(resumeBtn.width * 0.5);
        resumeBtn.y = windowElements.height + 20;
        windowElements.addChild(resumeBtn);
        registerOneShotCallback(resumeBtn, MouseEvent.CLICK,
            function (...ignored) :void {
                ClientCtx.mainLoop.popMode();
            });

        var endBtn :SimpleButton = UIBits.createButton("End Game", 1.5, 240);
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

    protected static const WIDTH :Number = 270;
    protected static const V_BORDER :Number = 25;
}

}
