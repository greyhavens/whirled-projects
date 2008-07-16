package popcraft.sp {

import com.threerings.flash.DisplayUtil;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.objects.SimpleSceneObject;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.LocationTask;
import com.whirled.contrib.simplegame.tasks.RepeatingTask;

import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;

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

        // if the player has beaten the game, they get to select which level to play.
        // otherwise, they get the "play" button, which allows them to play the next level, and
        // a little interactive tutorial.
        if (AppContext.levelMgr.playerBeatGame) {
            this.createLevelSelectLayout();
        } else {
            this.createTutorialLayout();
        }
    }

    protected function createTutorialLayout () :void
    {
        _playButton = SwfResource.instantiateButton("levelSelectUi", "play_button");
        _playButton.addEventListener(MouseEvent.CLICK, function (...ignored) :void {
            playNextLevel();
        });
        _playButton.x = 350;
        _playButton.y = 350;

        _modeLayer.addChild(_playButton);

        // unlock all levels button
        var button :SimpleButton = UIBits.createButton("Unlock levels");
        button.addEventListener(MouseEvent.CLICK, function (...ignored) :void { unlockLevels(); });
        button.x = 10;
        button.y = 10;
        _modeLayer.addChild(button);

        // create the tutorial objects
        var puzzleIntroMovie :MovieClip = SwfResource.instantiateMovieClip("levelSelectUi", "puzzle_intro");
        puzzleIntroMovie.mouseEnabled = false;
        _puzzleIntro = new SimpleSceneObject(puzzleIntroMovie);
        _puzzleIntro.x = 470;
        _puzzleIntro.y = 395;
        createHelpTextAnimTask(_puzzleIntro, 470, 475);
        this.addObject(_puzzleIntro, _modeLayer);

        var unitIntroMovie :MovieClip = SwfResource.instantiateMovieClip("levelSelectUi", "unit_intro");
        unitIntroMovie.mouseEnabled = false;
        _unitIntro = new SimpleSceneObject(unitIntroMovie);
        _unitIntro.x = 9;
        _unitIntro.y = 385;
        createHelpTextAnimTask(_unitIntro, 9, 4);
        this.addObject(_unitIntro, _modeLayer);

        var resourceIntroMovie :MovieClip = SwfResource.instantiateMovieClip("levelSelectUi", "resource_intro");
        resourceIntroMovie.mouseEnabled = false;
        _resourceIntro = new SimpleSceneObject(resourceIntroMovie);
        _resourceIntro.x = 9;
        _resourceIntro.y = 385;
        createHelpTextAnimTask(_resourceIntro, 9, 4);
        this.addObject(_resourceIntro, _modeLayer);
    }

    protected static function createHelpTextAnimTask (obj :SceneObject, startX :Number, endX :Number) :void
    {
        var task :RepeatingTask = new RepeatingTask();
        task.addTask(LocationTask.CreateSmooth(endX, obj.y, 1));
        task.addTask(LocationTask.CreateSmooth(startX, obj.y, 1));
        obj.addTask(task);
    }

    override public function update (dt :Number) :void
    {
        super.update(dt);

        if (null != _unitIntro) {
            _unitIntro.visible = GameContext.localPlayerInfo.canPurchaseCreature(Constants.UNIT_TYPE_GRUNT);
            _resourceIntro.visible = !_unitIntro.visible && GameContext.localPlayerInfo.totalResourceAmount > 0;
            _puzzleIntro.visible = !_unitIntro.visible && !_resourceIntro.visible;
        }
    }

    protected function playNextLevel () :void
    {
        _playButton.parent.removeChild(_playButton);
        this.levelSelected(AppContext.levelMgr.highestUnlockedLevelIndex);
    }

    protected function createLevelSelectLayout () :void
    {
        // put the "manual" up on the screen
        var manualFront :MovieClip = SwfResource.instantiateMovieClip("manual", "manual_front");
        manualFront.scaleX = 1.3;
        manualFront.scaleY = 1.3;
        manualFront.x = 370;
        manualFront.y = 250;

        // hide some stuff we don't need
        var cover :MovieClip = manualFront["cover"];
        var primer :MovieClip = cover["primer"];
        primer.visible = false;

        _modeLayer.addChild(manualFront);

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

            // if the player has completed the level with an expert score,
            // indicate this in the button title.
            if (levelRecord.expert) {
                levelName += " *";
            }

            button = this.createLevelSelectButton(i, levelName);
            button.x = columnLoc.x - (button.width * 0.5);
            button.y = yLoc;
            buttonSprite.addChild(button);

            yLoc += button.height + 3;
        }

        // epilogue button
        button = UIBits.createButton("Epilogue", 1.1, LEVEL_SELECT_BUTTON_WIDTH);
        button.x = EPILOGUE_LOC.x - (button.width * 0.5);
        button.y = EPILOGUE_LOC.y;
        button.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void { fadeOutToMode(new EpilogueMode(EpilogueMode.TRANSITION_LEVELSELECT)); });
        buttonSprite.addChild(button);

        DisplayUtil.positionBounds(buttonSprite,
            (Constants.SCREEN_SIZE.x * 0.5) - (buttonSprite.width * 0.5) + 20, BUTTON_CONTAINER_Y);

        _modeLayer.addChild(buttonSprite);
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
        var button :SimpleButton = UIBits.createButton(levelName, 1.1, LEVEL_SELECT_BUTTON_WIDTH);
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

    protected var _playButton :SimpleButton;
    protected var _puzzleIntro :SceneObject;
    protected var _unitIntro :SceneObject;
    protected var _resourceIntro :SceneObject;

    protected static const NUM_COLUMNS :int = 2;
    protected static const COLUMN_LOCS :Array = [ new Point(0, 0), new Point(200, 0) ];
    protected static const EPILOGUE_LOC :Point = new Point(100, 240);
    protected static const BUTTON_CONTAINER_Y :Number = 180;

    protected static const LEVEL_SELECT_BUTTON_WIDTH :Number = 190;
}

}
