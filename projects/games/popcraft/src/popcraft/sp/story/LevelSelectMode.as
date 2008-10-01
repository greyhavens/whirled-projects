package popcraft.sp.story {

import com.threerings.flash.DisplayUtil;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.objects.SimpleSceneObject;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.game.GameContentEvent;

import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;

import popcraft.*;
import popcraft.battle.view.WorkshopView;
import popcraft.data.LevelData;
import popcraft.ui.PlayerStatusView;
import popcraft.ui.UIBits;

public class LevelSelectMode extends DemoGameMode
{
    public static function create () :void
    {
        AppContext.levelMgr.curLevelIndex = LevelManager.DEMO_LEVEL;
        AppContext.levelMgr.playLevel(
            function (level :LevelData) :void {
                _demoLevel = level;
                AppContext.mainLoop.unwindToMode(new LevelSelectMode());
            });
    }

    public function LevelSelectMode ()
    {
        super(_demoLevel);

        if (_demoLevel == null) {
            throw new Error("LevelSelectMode must be instantiated via LevelSelectMode.create()");
        }
    }

    override protected function setup () :void
    {
        super.setup();

        // hide the player's workshop to make it look like streetwalkers are
        // appearing in front of the school
        WorkshopView.getForPlayer(0).visible = false;

        // hide the player status views
        var statusViews :Array = PlayerStatusView.getAll();
        for each (var view :PlayerStatusView in statusViews) {
            view.visible = false;
        }

        // overlay
        _modeLayer.addChild(ImageResource.instantiateBitmap("levelSelectOverlay"));

        registerEventListener(AppContext.gameCtrl.player, GameContentEvent.PLAYER_CONTENT_ADDED,
            onPlayerPurchasedContent);

        this.createTutorialLayout();

        this.fadeIn();
    }

    protected function createTutorialLayout () :void
    {
        var playerStartedGame :Boolean = AppContext.levelMgr.playerStartedGame;
        var playerCompletedGame :Boolean = AppContext.levelMgr.playerBeatGame;

        var playButtonName :String =
            (playerStartedGame && !playerCompletedGame ? "continue_button" : "play_button");
        var playButton :SimpleButton =
            SwfResource.instantiateButton("levelSelectUi", playButtonName);

        // if the player has beaten the game, the Play button will just take them to the level
        // select menu
        this.registerEventListener(playButton, MouseEvent.CLICK,
            function (...ignored) :void {
                onPlayClicked();
            });

        _playButtonObj = new SimpleSceneObject(playButton);
        _playButtonObj.x = 350;
        _playButtonObj.y = 350;
        this.addObject(_playButtonObj, _modeLayer);

        _levelSelectButton = UIBits.createButton("Select Level", 1.2);
        this.registerOneShotCallback(_levelSelectButton, MouseEvent.CLICK,
            function (...ignored) :void {
                createLevelSelectLayout();
            });
        _levelSelectButton.x = 10;
        _levelSelectButton.y = 10;
        _modeLayer.addChild(_levelSelectButton);

        if (!AppContext.isPremiumContentUnlocked) {
            _buyGameButton = UIBits.createButton("Unlock Full Version!", 1.2);
            this.registerEventListener(_buyGameButton, MouseEvent.CLICK,
                function (...ignored) :void {
                    AppContext.showGameShop();
                });
            _buyGameButton.x = Constants.SCREEN_SIZE.x - _buyGameButton.width - 10;
            _buyGameButton.y = 10;
            _modeLayer.addChild(_buyGameButton);
        }

        if (Constants.DEBUG_ALLOW_CHEATS) {
            var unlockLevelsButton :SimpleButton = UIBits.createButton("Unlock levels", 1.2);
            this.registerOneShotCallback(unlockLevelsButton, MouseEvent.CLICK,
                function (...ignored) :void {
                    unlockLevels();
                });
            unlockLevelsButton.x = 10;
            unlockLevelsButton.y = 45;
            _modeLayer.addChild(unlockLevelsButton);

            var lockLevelsButton :SimpleButton = UIBits.createButton("Lock levels", 1.2);
            this.registerOneShotCallback(lockLevelsButton, MouseEvent.CLICK,
                function (...ignored) :void {
                    lockLevels();
                });
            lockLevelsButton.x = 10;
            lockLevelsButton.y = 80;
            _modeLayer.addChild(lockLevelsButton);

            var testLevelButton :SimpleButton = UIBits.createButton("Test level", 1.2);
            this.registerOneShotCallback(testLevelButton, MouseEvent.CLICK,
                function (...ignored) : void {
                    levelSelected(LevelManager.TEST_LEVEL);
                });
            testLevelButton.x = 10;
            testLevelButton.y = 115;
            _modeLayer.addChild(testLevelButton);
        }

        // create the tutorial objects
        var puzzleIntroMovie :MovieClip = SwfResource.instantiateMovieClip("levelSelectUi",
            "puzzle_intro");
        puzzleIntroMovie.mouseEnabled = false;
        _puzzleIntro = new SimpleSceneObject(puzzleIntroMovie);
        _puzzleIntro.x = 470;
        _puzzleIntro.y = 395;
        createHelpTextAnimTask(_puzzleIntro, 470, 475);
        this.addObject(_puzzleIntro, _modeLayer);

        var unitIntroMovie :MovieClip = SwfResource.instantiateMovieClip("levelSelectUi",
            "unit_intro");
        unitIntroMovie.mouseEnabled = false;
        _unitIntro = new SimpleSceneObject(unitIntroMovie);
        _unitIntro.x = 9;
        _unitIntro.y = 385;
        createHelpTextAnimTask(_unitIntro, 9, 4);
        this.addObject(_unitIntro, _modeLayer);

        var resourceIntroMovie :MovieClip = SwfResource.instantiateMovieClip("levelSelectUi",
            "resource_intro");
        resourceIntroMovie.mouseEnabled = false;
        _resourceIntro = new SimpleSceneObject(resourceIntroMovie);
        _resourceIntro.x = 9;
        _resourceIntro.y = 385;
        createHelpTextAnimTask(_resourceIntro, 9, 4);
        this.addObject(_resourceIntro, _modeLayer);

        _showingTutorial = true;
    }

    protected function onPlayClicked () :void
    {
        if (!AppContext.isPremiumContentUnlocked &&
            AppContext.levelMgr.highestUnlockedLevelIndex >= Constants.NUM_FREE_SP_LEVELS) {
            AppContext.mainLoop.pushMode(new UpsellMode());

        } else {
            if (AppContext.levelMgr.playerBeatGame) {
                createLevelSelectLayout();
            } else {
                playNextLevel();
            }
        }
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

        if (_showingTutorial) {
            _unitIntro.visible = GameContext.localPlayerInfo.canAffordCreature(Constants.UNIT_TYPE_GRUNT);
            _resourceIntro.visible = !_unitIntro.visible && GameContext.localPlayerInfo.totalResourceAmount > 0;
            _puzzleIntro.visible = !_unitIntro.visible && !_resourceIntro.visible;
        }
    }

    override public function buildCreature (playerIndex :int, unitType :int, noCost :Boolean = false) :void
    {
        super.buildCreature(playerIndex, unitType, noCost);

        if (null != _playButtonObj && playerIndex == GameContext.localPlayerIndex && !_playButtonObj.hasTasks()) {
            // the play button starts pulsing when the player creates a creature
            _playButtonObj.addTask(new RepeatingTask(
                ScaleTask.CreateEaseIn(1.1, 1.1, 0.5),
                ScaleTask.CreateEaseOut(1, 1, 0.5)));
        }
    }

    protected function playNextLevel () :void
    {
        if (null != _playButtonObj) {
            _playButtonObj.displayObject.parent.removeChild(_playButtonObj.displayObject);
            _playButtonObj = null;

            this.levelSelected(AppContext.levelMgr.highestUnlockedLevelIndex);
        }
    }

    protected function createLevelSelectLayout () :void
    {
        // clean up from the tutorial, if it was being displayed before
        if (_showingTutorial) {
            _levelSelectButton.parent.removeChild(_levelSelectButton);
            _unitIntro.destroySelf();
            _resourceIntro.destroySelf();
            _puzzleIntro.destroySelf();
            _showingTutorial = false;

            _levelSelectButton = null;
            _unitIntro = null;
            _resourceIntro = null;
            _puzzleIntro = null;

            if (null != _buyGameButton) {
                _buyGameButton.parent.removeChild(_buyGameButton);
                _buyGameButton = null;
            }
        }

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
            if (!levelRecord.unlocked ||
                (!AppContext.isPremiumContentUnlocked && i >= Constants.NUM_FREE_SP_LEVELS)) {
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
        if (AppContext.levelMgr.playerBeatGame) {
            button = UIBits.createButton("Epilogue", 1.1, LEVEL_SELECT_BUTTON_WIDTH);
            button.x = EPILOGUE_LOC.x - (button.width * 0.5);
            button.y = EPILOGUE_LOC.y;
            registerOneShotCallback(button, MouseEvent.CLICK, onEpilogueSelected);
            buttonSprite.addChild(button);
        }

        DisplayUtil.positionBounds(buttonSprite,
            (Constants.SCREEN_SIZE.x * 0.5) - (buttonSprite.width * 0.5) + 20, BUTTON_CONTAINER_Y);

        _modeLayer.addChild(buttonSprite);

        // "Unlock Full Version!" button
        if (!AppContext.isPremiumContentUnlocked) {
            button = UIBits.createButton("Unlock Full Version To Continue!", 1.3);
            button.x = UNLOCK_MANUAL_LOC.x - (button.width * 0.5);
            button.y = UNLOCK_MANUAL_LOC.y;
            registerEventListener(button, MouseEvent.CLICK,
                function (...ignored) :void {
                    AppContext.showGameShop();
                });
        }
    }

    protected function onEpilogueSelected (e :MouseEvent) :void
    {
        fadeOut(function () :void {
            Resources.loadLevelPackResourcesAndSwitchModes(
                Resources.EPILOGUE_RESOURCES,
                new EpilogueMode(EpilogueMode.TRANSITION_LEVELSELECT));
        });
    }

    protected function lockLevels () :void
    {
        var levelRecords :Array = AppContext.levelMgr.levelRecords;
        var isFirstLevel :Boolean = true;
        for each (var lr :LevelRecord in levelRecords) {
            lr.unlocked = isFirstLevel;
            lr.score = 0;
            isFirstLevel = false;
        }

        UserCookieManager.setNeedsUpdate();

        // reload the mode
        LevelSelectMode.create();
    }

    protected function unlockLevels () :void
    {
        var levelRecords :Array = AppContext.levelMgr.levelRecords;
        for each (var lr :LevelRecord in levelRecords) {
            lr.unlocked = true;
            lr.score = 1;
        }

        UserCookieManager.setNeedsUpdate();

        // reload the mode
        LevelSelectMode.create();
    }

    protected function createLevelSelectButton (levelNum :int, levelName :String) :SimpleButton
    {
        var button :SimpleButton = UIBits.createButton(levelName, 1.1, LEVEL_SELECT_BUTTON_WIDTH);
        this.registerOneShotCallback(button, MouseEvent.CLICK,
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

    protected function startGame (loadedLevel :LevelData) :void
    {
        // called when the level is loaded

        if (AppContext.levelMgr.curLevelIndex == 0) {
            // show the prologue before the first level
            Resources.loadLevelPackResourcesAndSwitchModes(
                Resources.PROLOGUE_RESOURCES,
                new PrologueMode(PrologueMode.TRANSITION_GAME, loadedLevel));

        } else {
            this.fadeOutToMode(new StoryGameMode(loadedLevel));
        }
    }

    protected function onPlayerPurchasedContent (e :GameContentEvent) :void
    {
        if (e.contentType == GameContentEvent.LEVEL_PACK &&
            e.contentIdent == Constants.PREMIUM_SP_LEVEL_PACK_NAME) {
            // recreate the level select mode, which will rebuild the UI and remove the
            // "Unlock now!" buttons
            AppContext.reloadPlayerLevelPacks();
            LevelSelectMode.create();
        }
    }

    protected var _playButtonObj :SceneObject;
    protected var _puzzleIntro :SceneObject;
    protected var _unitIntro :SceneObject;
    protected var _resourceIntro :SceneObject;
    protected var _levelSelectButton :SimpleButton;
    protected var _showingTutorial :Boolean;
    protected var _buyGameButton :SimpleButton;

    protected static var _demoLevel :LevelData;

    protected static const NUM_COLUMNS :int = 2;
    protected static const COLUMN_LOCS :Array = [ new Point(0, 0), new Point(200, 0) ];
    protected static const EPILOGUE_LOC :Point = new Point(100, 240);
    protected static const UNLOCK_MANUAL_LOC :Point = new Point(100, 245);
    protected static const BUTTON_CONTAINER_Y :Number = 180;

    protected static const LEVEL_SELECT_BUTTON_WIDTH :Number = 190;
}

}
