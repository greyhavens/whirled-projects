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
import popcraft.sp.UnitAnimTestMode;
import popcraft.sp.endless.SpEndlessLevelSelectMode;
import popcraft.ui.PlayerStatusView;
import popcraft.ui.UIBits;
import popcraft.util.SpriteUtil;

public class LevelSelectMode extends DemoGameMode
{
    public static function create (fadeIn :Boolean = true, callback :Function = null) :void
    {
        AppContext.levelMgr.curLevelIndex = LevelManager.DEMO_LEVEL;
        AppContext.levelMgr.playLevel(
            function (level :LevelData) :void {
                _demoLevel = level;
                var mode :LevelSelectMode = new LevelSelectMode(fadeIn);
                if (callback != null) {
                    callback(mode);
                } else {
                    AppContext.mainLoop.unwindToMode(mode);
                }
            });
    }

    public function LevelSelectMode (fadeIn :Boolean)
    {
        super(_demoLevel);

        if (_demoLevel == null) {
            throw new Error("LevelSelectMode must be instantiated via LevelSelectMode.create()");
        }

        _shouldFadeIn = fadeIn;
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

        var ralphPortrait :MovieClip = SwfResource.instantiateMovieClip("splashUi",
            "ralph_portrait");
        ralphPortrait.x = RALPH_PORTRAIT_LOC.x;
        ralphPortrait.y = RALPH_PORTRAIT_LOC.y;
        _modeLayer.addChild(ralphPortrait);

        var jackPortrait :MovieClip = SwfResource.instantiateMovieClip("splashUi",
            "jack_portrait");
        jackPortrait.x = JACK_PORTRAIT_LOC.x;
        jackPortrait.y = JACK_PORTRAIT_LOC.y;
        _modeLayer.addChild(jackPortrait);

        this.registerListener(AppContext.gameCtrl.player,
            GameContentEvent.PLAYER_CONTENT_ADDED, onPlayerPurchasedContent);

        this.createDefaultLayout();

        if (_shouldFadeIn) {
            this.fadeIn();
        }
    }

    protected function createDefaultLayout () :void
    {
        var playerStartedGame :Boolean = AppContext.levelMgr.playerStartedGame;
        var playerCompletedGame :Boolean = AppContext.levelMgr.playerBeatGame;

        var storyBanner :MovieClip = SwfResource.instantiateMovieClip("splashUi",
            "story_banner");
        storyBanner.x = STORY_BANNER_LOC.x;
        storyBanner.y = STORY_BANNER_LOC.y;
        _modeLayer.addChild(storyBanner);

        var playButtonName :String =
            (playerStartedGame && !playerCompletedGame ? "continue_button" : "play_button");
        var playButton :SimpleButton = SwfResource.instantiateButton("splashUi", playButtonName);
        playButton.x = STORY_BUTTON_LOC.x;
        playButton.y = STORY_BUTTON_LOC.y;
        this.registerListener(playButton, MouseEvent.CLICK, onPlayClicked);
        _playButtonObj = new SimpleSceneObject(playButton);
        this.addObject(_playButtonObj, _modeLayer);

        if (playerStartedGame) {
            if (AppContext.levelMgr.highestUnlockedLevelIndex > Constants.UNLOCK_ENDLESS_AFTER_LEVEL) {
                // The player has unlocked endless mode. Show the endless mode button
                var endlessPanel :MovieClip = SwfResource.instantiateMovieClip("splashUi",
                    "challenge_panel");
                endlessPanel.x = ENDLESS_PANEL_LOC.x;
                endlessPanel.y = ENDLESS_PANEL_LOC.y;
                _modeLayer.addChild(endlessPanel);
                var endlessButton :SimpleButton = endlessPanel["challenge_button"];
                registerOneShotCallback(endlessButton, MouseEvent.CLICK, onEndlessClicked);

            } else {
                // the player has played the game but hasn't unlocked endless mode.
                var lockedEndlessPanel :MovieClip = SwfResource.instantiateMovieClip("splashUi",
                    "challenge_panel_locked");
                lockedEndlessPanel.x = ENDLESS_PANEL_LOC.x;
                lockedEndlessPanel.y = ENDLESS_PANEL_LOC.y;
                _modeLayer.addChild(lockedEndlessPanel);
            }

            // show the "select panel, which shows the level-select and credits buttons
            var selectPanel :MovieClip = SwfResource.instantiateMovieClip("splashUi",
                "select_panel");
            selectPanel.x = SELECT_PANEL_LOC.x;
            selectPanel.y = SELECT_PANEL_LOC.y;
            _modeLayer.addChild(selectPanel);

            // buttons
            var buttonParent :Sprite = SpriteUtil.createSprite(true);

            _levelSelectButton = UIBits.createButton("Select Level", 1.5);
            this.registerOneShotCallback(_levelSelectButton, MouseEvent.CLICK,
                function (...ignored) :void {
                    createLevelSelectLayout();
                });
            DisplayUtil.positionBounds(_levelSelectButton, -_levelSelectButton.width * 0.5, 0);
            buttonParent.addChild(_levelSelectButton);

            var creditsButton :SimpleButton = UIBits.createButton("Credits", 1.5);
            this.registerOneShotCallback(creditsButton, MouseEvent.CLICK,
                function (...ignored) :void {
                    // TODO
                });
            DisplayUtil.positionBounds(creditsButton, -creditsButton.width * 0.5,
                buttonParent.height + 5);
            buttonParent.addChild(creditsButton);

            DisplayUtil.positionBounds(buttonParent,
                (selectPanel.width - buttonParent.width) * 0.5,
                (selectPanel.height - buttonParent.height) * 0.5);
            selectPanel.addChild(buttonParent);


        } else {
            // it's the player's first time playing: show them the tutorial
            this.createTutorialLayout();
        }

        /*if (!AppContext.isPremiumContentUnlocked) {
            _buyGameButton = UIBits.createButton("Unlock Full Version!", 1.2);
            this.registerListener(_buyGameButton, MouseEvent.CLICK,
                function (...ignored) :void {
                    AppContext.showGameShop();
                });
            _buyGameButton.x = Constants.SCREEN_SIZE.x - _buyGameButton.width - 10;
            _buyGameButton.y = 10;
            _modeLayer.addChild(_buyGameButton);
        }*/

        if (Constants.DEBUG_ALLOW_CHEATS) {
            this.createDebugLayout();
        }
    }

    protected function createTutorialLayout () :void
    {
        var puzzleIntroMovie :MovieClip = SwfResource.instantiateMovieClip("splashUi",
            "puzzle_intro");
        puzzleIntroMovie.mouseEnabled = false;
        _puzzleIntro = new SimpleSceneObject(puzzleIntroMovie);
        _puzzleIntro.x = 470;
        _puzzleIntro.y = 395;
        createHelpTextAnimTask(_puzzleIntro, 470, 475);
        this.addObject(_puzzleIntro, _modeLayer);

        var unitIntroMovie :MovieClip = SwfResource.instantiateMovieClip("splashUi",
            "unit_intro");
        unitIntroMovie.mouseEnabled = false;
        _unitIntro = new SimpleSceneObject(unitIntroMovie);
        _unitIntro.x = 9;
        _unitIntro.y = 385;
        createHelpTextAnimTask(_unitIntro, 9, 4);
        this.addObject(_unitIntro, _modeLayer);

        var resourceIntroMovie :MovieClip = SwfResource.instantiateMovieClip("splashUi",
            "resource_intro");
        resourceIntroMovie.mouseEnabled = false;
        _resourceIntro = new SimpleSceneObject(resourceIntroMovie);
        _resourceIntro.x = 9;
        _resourceIntro.y = 385;
        createHelpTextAnimTask(_resourceIntro, 9, 4);
        this.addObject(_resourceIntro, _modeLayer);

        _showingTutorial = true;
        this.updateTutorial();
    }

    protected function createDebugLayout () :void
    {
        var buttonY :Number = 45;

        var unlockLevelsButton :SimpleButton = UIBits.createButton("Unlock levels", 1.2);
        this.registerOneShotCallback(unlockLevelsButton, MouseEvent.CLICK,
            function (...ignored) :void {
                unlockLevels();
            });
        unlockLevelsButton.x = 10;
        unlockLevelsButton.y = buttonY;
        buttonY += 35;
        _modeLayer.addChild(unlockLevelsButton);

        var lockLevelsButton :SimpleButton = UIBits.createButton("Lock levels", 1.2);
        this.registerOneShotCallback(lockLevelsButton, MouseEvent.CLICK,
            function (...ignored) :void {
                lockLevels();
            });
        lockLevelsButton.x = 10;
        lockLevelsButton.y = buttonY;
        buttonY += 35;
        _modeLayer.addChild(lockLevelsButton);

        var testLevelButton :SimpleButton = UIBits.createButton("Test level", 1.2);
        this.registerOneShotCallback(testLevelButton, MouseEvent.CLICK,
            function (...ignored) : void {
                levelSelected(LevelManager.TEST_LEVEL);
            });
        testLevelButton.x = 10;
        testLevelButton.y = buttonY;
        buttonY += 35;
        _modeLayer.addChild(testLevelButton);

        var testAnimButton :SimpleButton = UIBits.createButton("Anim test", 1.2);
        this.registerListener(testAnimButton, MouseEvent.CLICK,
            function (...ignored) : void {
                AppContext.mainLoop.pushMode(new UnitAnimTestMode());
            });
        testAnimButton.x = 10;
        testAnimButton.y = buttonY;
        buttonY += 35;
        _modeLayer.addChild(testAnimButton);

        var upsellButton :SimpleButton = UIBits.createButton("Upsell", 1.2);
        this.registerListener(upsellButton, MouseEvent.CLICK,
            function (...ignored) :void {
                AppContext.mainLoop.pushMode(new UpsellMode());
            });
        upsellButton.x = 10;
        upsellButton.y = buttonY;
        buttonY += 35;
        _modeLayer.addChild(upsellButton);
    }

    protected function onPlayClicked (...ignored) :void
    {
        if (!AppContext.isStoryModeUnlocked &&
            AppContext.levelMgr.highestUnlockedLevelIndex >= Constants.NUM_FREE_SP_LEVELS) {
            AppContext.mainLoop.pushMode(new UpsellMode());

        } else {
            if (AppContext.levelMgr.playerBeatGame) {
                // if the player has beaten the game, the Play button will just take them to the
                // level select menu
                createLevelSelectLayout();
            } else {
                playNextLevel();
            }
        }
    }

    protected function onEndlessClicked (...ignored) :void
    {
        if (!AppContext.isEndlessModeUnlocked) {
            AppContext.mainLoop.pushMode(new UpsellMode());
        } else {
            AppContext.mainLoop.pushMode(new SpEndlessLevelSelectMode());
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
            this.updateTutorial();
        }
    }

    protected function updateTutorial () :void
    {
        _unitIntro.visible = GameContext.localPlayerInfo.canAffordCreature(Constants.UNIT_TYPE_GRUNT);
        _resourceIntro.visible = !_unitIntro.visible && GameContext.localPlayerInfo.totalResourceAmount > 0;
        _puzzleIntro.visible = !_unitIntro.visible && !_resourceIntro.visible;
    }

    override public function sendBuildCreatureMsg (playerIndex :int, unitType :int, noCost :Boolean,
        isAiMsg :Boolean) :void
    {
        super.sendBuildCreatureMsg(playerIndex, unitType, noCost, isAiMsg);

        if (null != _playButtonObj && playerIndex == GameContext.localPlayerIndex && !_playButtonObj.hasTasks()) {
            // the play button starts pulsing when the player creates a creature
            _playButtonObj.addTask(new RepeatingTask(
                ScaleTask.CreateEaseIn(1.1, 1.1, 0.5),
                ScaleTask.CreateEaseOut(1, 1, 0.5)));
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
        var buttonSprite :Sprite = SpriteUtil.createSprite(true, false);
        var levelsPerColumn :int = numLevels / NUM_COLUMNS;
        var column :int = -1;
        var columnLoc :Point;
        var button :SimpleButton;
        var yLoc :Number;
        for (var i :int = 0; i < numLevels; ++i) {
            var levelRecord :LevelRecord = levelRecords[i];
            if (!levelRecord.unlocked ||
                (!AppContext.isStoryModeUnlocked && i >= Constants.NUM_FREE_SP_LEVELS)) {
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
        if (!AppContext.isStoryModeUnlocked) {
            button = UIBits.createButton("Unlock Full Version To Continue!", 1.3);
            button.x = UNLOCK_MANUAL_LOC.x - (button.width * 0.5);
            button.y = UNLOCK_MANUAL_LOC.y;
            registerListener(button, MouseEvent.CLICK,
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

        AppContext.userCookieMgr.setNeedsUpdate();

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

        AppContext.userCookieMgr.setNeedsUpdate();

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

    protected function playNextLevel () :void
    {
        this.levelSelected(AppContext.levelMgr.highestUnlockedLevelIndex);
    }

    protected function levelSelected (levelNum :int) :void
    {
        AppContext.levelMgr.curLevelIndex = levelNum;
        AppContext.levelMgr.playLevel(onLevelLoaded);
    }

    protected function onLevelLoaded (loadedLevel :LevelData) :void
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
    protected var _shouldFadeIn :Boolean;

    protected static var _demoLevel :LevelData;

    protected static const NUM_COLUMNS :int = 2;
    protected static const COLUMN_LOCS :Array = [ new Point(0, 0), new Point(200, 0) ];
    protected static const EPILOGUE_LOC :Point = new Point(100, 240);
    protected static const UNLOCK_MANUAL_LOC :Point = new Point(100, 245);
    protected static const BUTTON_CONTAINER_Y :Number = 180;

    protected static const LEVEL_SELECT_BUTTON_WIDTH :Number = 190;

    protected static const RALPH_PORTRAIT_LOC :Point = new Point(62, 42);
    protected static const JACK_PORTRAIT_LOC :Point = new Point(643, 43);
    protected static const STORY_BANNER_LOC :Point = new Point(350, 330);
    protected static const STORY_BUTTON_LOC :Point = new Point(350, 350);
    protected static const ENDLESS_PANEL_LOC :Point = new Point(488, 390);
    protected static const SELECT_PANEL_LOC :Point = new Point(0, 391);
}

}
