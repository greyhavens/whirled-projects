package popcraft.sp {

import com.whirled.contrib.simplegame.*;

import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.geom.Point;

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

        var levelNames :Array = AppContext.levelProgression.levelNames;
        var levelRecords :Array = AppContext.levelMgr.levelRecords;
        var numLevels :int = levelRecords.length;

        // create a button for each level
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
            _modeLayer.addChild(button);

            yLoc += button.height + 3;
        }

        // animation test button
        /*button = UIBits.createButton("Unit Anim Test");
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
        _modeLayer.addChild(button);*/

        // unlock all levels button
        button = UIBits.createButton("Unlock levels");
        button.addEventListener(MouseEvent.CLICK, function (...ignored) :void { unlockLevels(); });
        button.x = 10;
        button.y = 10;
        _modeLayer.addChild(button);

        // epilogue button
        if (AppContext.levelMgr.playerBeatGame) {
            button = UIBits.createButton("Epilogue");
            button.x = EPILOGUE_LOC.x - (button.width * 0.5);
            button.y = EPILOGUE_LOC.y;
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

        if (AppContext.levelMgr.curLevelIndex == 0) {
            // show the prologue before the first level
           AppContext.mainLoop.changeMode(new PrologueMode(PrologueMode.TRANSITION_GAME));
        } else {
            this.fadeOutToMode(new GameMode());
        }
    }

    protected var _createdLayout :Boolean;

    protected static const NUM_COLUMNS :int = 2;
    protected static const COLUMN_LOCS :Array = [ new Point(200, 210), new Point(500, 210) ];
    protected static const EPILOGUE_LOC :Point = new Point(350, 450);
}

}
