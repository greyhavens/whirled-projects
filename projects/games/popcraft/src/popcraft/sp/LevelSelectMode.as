package popcraft.sp {

import com.whirled.contrib.simplegame.*;

import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import popcraft.*;
import popcraft.ui.UIBits;

public class LevelSelectMode extends SplashScreenModeBase
{
    override public function update (dt :Number) :void
    {
        super.update(dt);

        if (!_createdLayout && !UserCookieManager.isLoadingCookie && AppContext.levelMgr.levelRecordsLoaded) {
            this.createLayout();
        }
    }

    override protected function setup () :void
    {
        super.setup();

        this.fadeIn();

        if (AppContext.levelMgr.levelRecordsLoaded) {
            this.createLayout();
        }
    }

    protected function createLayout () :void
    {
        _createdLayout = true;

        var tf :TextField = new TextField();
        tf.selectable = false;
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.textColor = 0xFFFFFF;
        tf.text = "PopCraft level select. (Score: " + AppContext.levelMgr.totalScore + ")";
        tf.scaleX = 1;
        tf.scaleY = 1;
        tf.x = (Constants.SCREEN_SIZE.x * 0.5) - (tf.width * 0.5);
        tf.y = 10;

        _modeLayer.addChild(tf);

        var levelNames :Array = AppContext.levelProgression.levelNames;
        var levelRecords :Array = AppContext.levelMgr.levelRecords;

        var button :SimpleButton;
        var yLoc :Number = tf.height + 15;

        // create a button for each level
        for (var i :int = 0; i < levelRecords.length; ++i) {
            var levelRecord :LevelRecord = levelRecords[i];
            if (!levelRecord.unlocked) {
                break;
            }

            var levelName :String = String(i + 1) + ". " + levelNames[i];
            if (levelRecord.score > 0) {
                levelName += " (" + levelRecord.score;
                if (levelRecord.expert) {
                    levelName += " *";
                }
                levelName += ")";
            }

            button = this.createLevelSelectButton(i, levelName);
            button.x = (Constants.SCREEN_SIZE.x * 0.5) - (button.width * 0.5);
            button.y = yLoc;
            _modeLayer.addChild(button);

            yLoc += button.height + 3;
        }

        // animation test button
        button = UIBits.createButton("Unit Anim Test");
        button.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                AppContext.mainLoop.pushMode(new UnitAnimTestMode());
            });
        button.x = 10;
        button.y = 450;

        _modeLayer.addChild(button);

        // test level button
        button = UIBits.createButton("Jon's stress test");
        button.addEventListener(MouseEvent.CLICK, function (...ignored) :void { levelSelected(-1); });
        button.x = 100;
        button.y = 450;
        _modeLayer.addChild(button);

        // unlock all levels button
        button = UIBits.createButton("Unlock levels");
        button.addEventListener(MouseEvent.CLICK, function (...ignored) :void { unlockLevels(); });
        button.x = 10;
        button.y = 10;
        _modeLayer.addChild(button);

        // @TEMP - prologue, epilogue button
        button = UIBits.createButton("Prologue");
        button.x = 10;
        button.y = 50;
        button.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void { fadeOutToMode(new PrologueMode(PrologueMode.TRANSITION_LEVELSELECT)); });
        _modeLayer.addChild(button);

        if (AppContext.levelMgr.playerBeatGame) {
            button = UIBits.createButton("Epilogue");
            button.x = 10
            button.y = 90;
            button.addEventListener(MouseEvent.CLICK,
                function (...ignored) :void { fadeOutToMode(new EpilogueMode(EpilogueMode.TRANSITION_LEVELSELECT)); });
            _modeLayer.addChild(button);
        }
    }

    protected function unlockLevels () :void
    {
        var levelRecords :Array = AppContext.levelMgr.levelRecords;
        for each (var lr :LevelRecord in levelRecords) {
            lr.unlocked = true;
            lr.score = 1;
        }

        // reload the mode
        MainLoop.instance.changeMode(new LevelSelectMode());
    }

    protected function createLevelSelectButton (levelNum :int, levelName :String) :SimpleButton
    {
        var button :SimpleButton = UIBits.createButton(levelName);
        button.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                levelSelected(levelNum);
            });

        return button;
    }

    protected function levelSelected (levelNum :int) :void
    {
        AppContext.levelMgr.curLevelIndex = levelNum;
        AppContext.levelMgr.playLevel(startGame);
    }

    protected function startGame () :void
    {
        // called when the level is loaded

        var nextMode :AppMode;
        if (AppContext.levelMgr.curLevelIndex == 0) {
            // show the prologue before the first level
           nextMode = new PrologueMode(PrologueMode.TRANSITION_GAME);
        } else {
            nextMode = new GameMode();
        }

        this.fadeOutToMode(nextMode);
    }

    protected var _createdLayout :Boolean;

}

}
