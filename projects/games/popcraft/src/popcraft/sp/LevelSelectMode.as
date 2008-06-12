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
    override public function update (dt :Number) :void
    {
        if (!_hasSetup && AppContext.levelMgr.levelRecordsLoaded) {
            this.setup();
        }
    }

    override protected function setup () :void
    {
        // don't setup until our level records are loaded
        if (!AppContext.levelMgr.levelRecordsLoaded) {
            return;
        }

        _hasSetup = true;

        var g :Graphics = this.modeSprite.graphics;
        g.beginFill(0xB7B6B4);
        g.drawRect(0, 0, Constants.SCREEN_DIMS.x, Constants.SCREEN_DIMS.y);
        g.endFill();

        var tf :TextField = new TextField();
        tf.selectable = false;
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.text = "PopCraft level select. (Score: " + AppContext.levelMgr.totalScore + ")";
        tf.scaleX = 2;
        tf.scaleY = 2;
        tf.x = (this.modeSprite.width * 0.5) - (tf.width * 0.5);
        tf.y = 20;

        this.modeSprite.addChild(tf);

        var levelNames :Array = AppContext.levelProgression.levelNames;
        var levelRecords :Array = AppContext.levelMgr.levelRecords;

        var button :SimpleButton;
        var yLoc :Number = 70;;
        // create a button for each level
        for (var i :int = 0; i < AppContext.levelMgr.numLevels; ++i) {
            var levelName :String = (i < levelNames.length ? levelNames[i] : "(Level " + String(i + 1) + ")");
            var levelRecord :LevelRecord = (i < levelRecords.length ? levelRecords[i] : null);
            if (null != levelRecord && !levelRecord.unlocked) {
                break;
            }

            if (null != levelRecord && levelRecord.score > 0) {
                levelName += " (" + levelRecord.score + ")";
            }

            button = this.createLevelSelectButton(i, levelName);
            button.x = (this.modeSprite.width * 0.5) - (button.width * 0.5);
            button.y = yLoc;
            this.modeSprite.addChild(button);

            yLoc += button.height + 3;
        }

        // animation test button
        button = new SimpleTextButton("Unit Anim Test");
        button.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                AppContext.mainLoop.pushMode(new UnitAnimTestMode());
            });
        button.x = 10;
        button.y = 450;

        this.modeSprite.addChild(button);

        // test level button
        button = new SimpleTextButton("Jon's stress test");
        button.addEventListener(MouseEvent.CLICK, function (...ignored) :void { levelSelected(-1); });
        button.x = 100;
        button.y = 450;

        this.modeSprite.addChild(button);

        // unlock all levels button
        button = new SimpleTextButton("Unlock levels");
        button.addEventListener(MouseEvent.CLICK, function (...ignored) :void { unlockLevels(); });
        button.x = 10;
        button.y = 10;

        this.modeSprite.addChild(button);
    }

    protected function unlockLevels () :void
    {
        var levelRecords :Array = AppContext.levelMgr.levelRecords;
        for each (var lr :LevelRecord in levelRecords) {
            lr.unlocked = true;
        }

        // reload the mode
        MainLoop.instance.changeMode(new LevelSelectMode());
    }

    protected function createLevelSelectButton (levelNum :int, levelName :String) :SimpleButton
    {
        var button :SimpleTextButton = new SimpleTextButton(levelName);
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

    protected var _hasSetup :Boolean;

}

}
