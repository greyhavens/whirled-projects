package redrover.game.view {

import com.whirled.contrib.simplegame.AppMode;

import flash.display.Graphics;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;

import redrover.*;
import redrover.game.*;
import redrover.ui.UIBits;

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
        var resumeButton :SimpleButton = UIBits.createButton("Resume", 1.5, 150);
        registerOneShotCallback(resumeButton, MouseEvent.CLICK,
            function (...ignored) :void {
                AppContext.mainLoop.popMode();
            });

        resumeButton.x = (bgSprite.width - resumeButton.width) * 0.5;
        resumeButton.y = bgSprite.height - resumeButton.height - 20;
        bgSprite.addChild(resumeButton);

        // Help button
        var helpButton :SimpleButton = UIBits.createButton("Help", 1.5, 150);
        registerListener(helpButton, MouseEvent.CLICK,
            function (...ignored) :void {
                AppContext.mainLoop.pushMode(new InstructionsMode());
            });
        helpButton.x = (bgSprite.width - helpButton.width) * 0.5;
        helpButton.y = resumeButton.y - helpButton.height - 5;
        bgSprite.addChild(helpButton);

        // Restart button
        var restartButton :SimpleButton = UIBits.createButton("Restart", 1.2, 150);
        registerOneShotCallback(restartButton, MouseEvent.CLICK,
            function (...ignored) :void {
                AppContext.mainLoop.unwindToMode(new GameMode(GameContext.levelData));
            });
        restartButton.x = (bgSprite.width - restartButton.width) * 0.5;
        restartButton.y = helpButton.y - restartButton.height - 5;
        bgSprite.addChild(restartButton);
    }

}

}
