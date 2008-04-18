package popcraft.sp {

import com.threerings.flash.SimpleTextButton;
import com.whirled.contrib.simplegame.*;

import flash.display.Graphics;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import popcraft.*;

public class LevelSelectMode extends AppMode
{
    override protected function setup () :void
    {
        var g :Graphics = this.modeSprite.graphics;
        g.beginFill(0xB7B6B4);
        g.drawRect(0, 0, Constants.SCREEN_DIMS.x, Constants.SCREEN_DIMS.y);
        g.endFill();

        var tf :TextField = new TextField();
        tf.selectable = false;
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.text = "PopCraft single player level select";
        tf.scaleX = 2;
        tf.scaleY = 2;
        tf.x = (this.modeSprite.width * 0.5) - (tf.width * 0.5);
        tf.y = 100;

        this.modeSprite.addChild(tf);

        var button :SimpleTextButton = new SimpleTextButton("Level 1");
        button.addEventListener(MouseEvent.CLICK, levelSelected);
        button.x = (this.modeSprite.width * 0.5) - (button.width * 0.5);
        button.y = 200;

        this.modeSprite.addChild(button);
    }

    protected function levelSelected (...ignored) :void
    {
        // @TEMP - construct a test level
        var initialWave :UnitWave = new UnitWave();
        initialWave.delayBefore = 10;
        initialWave.units = [ Constants.UNIT_TYPE_GRUNT ];

        var repeatingWave :UnitWave = new UnitWave();
        repeatingWave.delayBefore = 5;
        repeatingWave.units = [ Constants.UNIT_TYPE_GRUNT, Constants.UNIT_TYPE_GRUNT ];

        var testOpponent :ComputerPlayerData = new ComputerPlayerData();
        testOpponent.initialWaves = [ initialWave ];
        testOpponent.repeatingWaves = [ repeatingWave ];

        var testLevel :LevelData = new LevelData();
        testLevel.name = "Tutorial 1";
        testLevel.introText = "Learn how to use the Madame and the Handy Man!";
        testLevel.availableUnits = [ Constants.UNIT_TYPE_GRUNT, Constants.UNIT_TYPE_HEAVY ];
        testLevel.disableDiurnalCycle = true;
        testLevel.computers = [ testOpponent ];

        // start the game
        GameContext.gameType = GameContext.GAME_TYPE_SINGLEPLAYER;
        GameContext.spLevel = testLevel;
        MainLoop.instance.changeMode(new GameMode());
    }

}

}
