package popcraft.sp {

import com.threerings.flash.DisplayUtil;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;

import popcraft.*;
import popcraft.battle.view.PlayerBaseUnitView;
import popcraft.ui.PlayerStatusView;
import popcraft.ui.UIBits;

public class LevelSelectMode extends DemoGameMode
{
    override protected function setup () :void
    {
        super.setup();
        this.fadeIn();
    }

    override protected function setupGameScreen () :void
    {
        super.setupGameScreen();

        // hide the player's workshop to make it look like streetwalkers are
        // appearing in front of the school
        PlayerBaseUnitView.getForPlayer(0).visible = false;

        // hide the player status views
        var statusViews :Array = PlayerStatusView.getAll();
        for each (var view :PlayerStatusView in statusViews) {
            view.visible = false;
        }

        // overlay
        _modeLayer.addChild(ImageResource.instantiateBitmap("levelSelectOverlay"));

        // "click to play story" button
        _clickToStartButton = new Sprite();
        _clickToStartButton.addChild(UIBits.createTitleText("Click Here To Begin The Story..."));
        _clickToStartButton.addEventListener(MouseEvent.CLICK, function (...ignored) :void {
            createLevelSelectLayout();
        });
        DisplayUtil.positionBounds(_clickToStartButton,
            (Constants.SCREEN_SIZE.x * 0.5) - (_clickToStartButton.width * 0.5),
            40);

        _modeLayer.addChild(_clickToStartButton);
    }

    protected function createLevelSelectLayout () :void
    {
        _clickToStartButton.parent.removeChild(_clickToStartButton);

        var levelNames :Array = AppContext.levelProgression.levelNames;
        var levelRecords :Array = AppContext.levelMgr.levelRecords;
        var numLevels :int = levelRecords.length;

        // create a button for each level
        var buttonSprite :Sprite = new Sprite();
        var levelsPerColumn :int = numLevels / NUM_COLUMNS;
        var column :int = -1;
        var columnLoc :Point;
        var button :SimpleButton;
        var yLoc :Number;
        for (var i :int = 0; i < numLevels; ++i) {
            var levelRecord :LevelRecord = levelRecords[i];
            if (!levelRecord.unlocked) {
                break;
            }

            if (i % levelsPerColumn == 0) {
                columnLoc = COLUMN_LOCS[++column];
                yLoc = columnLoc.y;
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
            button.x = columnLoc.x - (button.width * 0.5);
            button.y = yLoc;
            buttonSprite.addChild(button);

            yLoc += button.height + 3;
        }

        // create the epilogue button if the player has finished the game
        if (AppContext.levelMgr.playerBeatGame) {
            button = UIBits.createButton("Epilogue");
            button.x = EPILOGUE_LOC.x - (button.width * 0.5);
            button.y = EPILOGUE_LOC.y;
            button.addEventListener(MouseEvent.CLICK,
                function (...ignored) :void { fadeOutToMode(new EpilogueMode(EpilogueMode.TRANSITION_LEVELSELECT)); });
            buttonSprite.addChild(button);
        }

        // frame the buttons
        var buttonFrame :Sprite = UIBits.createFrame(
            buttonSprite.width + (BUTTON_FRAME_BORDER_SIZE.x * 2),
            buttonSprite.height + (BUTTON_FRAME_BORDER_SIZE.y * 2));
        var buttonBounds :Rectangle = buttonSprite.getBounds(buttonSprite);
        buttonSprite.x = -buttonBounds.left + BUTTON_FRAME_BORDER_SIZE.x;
        buttonSprite.y = -buttonBounds.top + BUTTON_FRAME_BORDER_SIZE.y;
        buttonFrame.addChild(buttonSprite);
        buttonFrame.x = (Constants.SCREEN_SIZE.x * 0.5) - (buttonFrame.width * 0.5);
        buttonFrame.y = BUTTON_FRAME_Y;
        _modeLayer.addChild(buttonFrame);

        // unlock all levels button
        button = UIBits.createButton("Unlock levels");
        button.addEventListener(MouseEvent.CLICK, function (...ignored) :void { unlockLevels(); });
        button.x = 10;
        button.y = 10;
        _modeLayer.addChild(button);
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

        if (AppContext.levelMgr.curLevelIndex == 0) {
            // show the prologue before the first level
           AppContext.mainLoop.changeMode(new PrologueMode(PrologueMode.TRANSITION_GAME));
        } else {
            this.fadeOutToMode(new GameMode());
        }
    }

    protected var _clickToStartButton :Sprite;

    protected static const NUM_COLUMNS :int = 2;
    protected static const COLUMN_LOCS :Array = [ new Point(0, 0), new Point(200, 0) ];
    protected static const EPILOGUE_LOC :Point = new Point(100, 230);
    protected static const BUTTON_FRAME_BORDER_SIZE :Point = new Point(15, 15);
    protected static const BUTTON_FRAME_Y :Number = 5;
}

}
