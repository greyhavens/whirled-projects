package popcraft.sp {

import com.threerings.flash.SimpleTextButton;
import com.whirled.contrib.simplegame.*;

import flash.display.Graphics;
import flash.display.SimpleButton;
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
        tf.y = 20;

        this.modeSprite.addChild(tf);

        var button :SimpleButton;
        var yLoc :Number = 70;;
        // create a button for each level
        for (var i :int = 0; i < AppContext.levelMgr.numLevels; ++i) {
            button = this.createLevelSelectButton(i);
            button.x = (this.modeSprite.width * 0.5) - (button.width * 0.5);
            button.y = yLoc;
            this.modeSprite.addChild(button);

            yLoc += button.height + 3;
        }

        button = new SimpleTextButton("Unit Anim Test");
        button.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                AppContext.mainLoop.pushMode(new UnitAnimTestMode());
            });
        button.x = (this.modeSprite.width * 0.5) - (button.width * 0.5);
        button.y = yLoc + 20;

        this.modeSprite.addChild(button);
    }

    protected function createLevelSelectButton (levelNum :int) :SimpleButton
    {
        var button :SimpleTextButton = new SimpleTextButton("Level " + String(levelNum + 1));
        button.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                levelSelected(levelNum);
            });

        return button;
    }

    protected function levelSelected (levelNum :int) :void
    {
        AppContext.levelMgr.curLevelNum = levelNum;
        AppContext.levelMgr.playLevel();
    }

}

}
