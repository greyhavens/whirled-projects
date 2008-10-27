package popcraft.sp.endless {

import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;

import popcraft.*;
import popcraft.data.EndlessLevelData;
import popcraft.data.UnitData;
import popcraft.ui.UIBits;
import popcraft.util.SpriteUtil;

public class EndlessLevelSelectModeBase extends AppMode
{
    public function EndlessLevelSelectModeBase (mode :int)
    {
        _mode = mode;
    }

    protected function onLevelLoaded (level :EndlessLevelData) :void
    {
        createUi(level);
    }

    protected function createUi (level :EndlessLevelData) :void
    {
        _saveViewLayer = SpriteUtil.createSprite(true);
        _helpLayer = SpriteUtil.createSprite(true);
        _modeSprite.addChild(_saveViewLayer);
        _modeSprite.addChild(_helpLayer);

        _level = level;

        _localSaves = getLocalSavedGames();
        _remoteSaves = getRemoteSavedGames();

        if (null == _remoteSaves) {
            _highestMapIndex = _localSaves.numSaves;
        } else {
            _highestMapIndex = Math.min(_localSaves.numSaves, _remoteSaves.numSaves);
        }

        // create a dummy Level 1 save, so that players can start new games
        var workshopData :UnitData = _level.gameDataOverride.units[Constants.UNIT_TYPE_WORKSHOP];
        _level1 = SavedEndlessGame.create(0, 0, 1, workshopData.maxHealth);

        selectMap(_highestMapIndex, ANIMATE_DOWN, true);
    }

    protected function selectMap (mapIndex :int, animationType :int,
        removeModeUnderneath :Boolean) :void
    {
        _mapIndex = mapIndex;

        var newStartLoc :Point;
        var oldStartLoc :Point;
        var newLocTask :LocationTask;
        var oldLocTask :LocationTask;
        switch (animationType) {
        case ANIMATE_DOWN:
            newStartLoc = UP_LOC;
            newLocTask = LocationTask.CreateEaseIn(DOWN_LOC.x, DOWN_LOC.y, ANIMATE_DOWN_TIME);
            break;

        case ANIMATE_NEXT:
            newStartLoc = NEXT_LOC;
            newLocTask = LocationTask.CreateSmooth(DOWN_LOC.x, DOWN_LOC.y, ANIMATE_NEXTPREV_TIME);
            oldStartLoc = DOWN_LOC;
            oldLocTask = LocationTask.CreateSmooth(PREV_LOC.x, PREV_LOC.y, ANIMATE_NEXTPREV_TIME);
            break;

        case ANIMATE_PREV:
            newStartLoc = PREV_LOC;
            newLocTask = LocationTask.CreateSmooth(DOWN_LOC.x, DOWN_LOC.y, ANIMATE_NEXTPREV_TIME);
            oldStartLoc = DOWN_LOC;
            oldLocTask = LocationTask.CreateSmooth(NEXT_LOC.x, NEXT_LOC.y, ANIMATE_NEXTPREV_TIME);
            break;
        }

        if (null != _saveView) {
            _saveView.x = oldStartLoc.x;
            _saveView.y = oldStartLoc.y;
            _saveView.removeAllTasks();
            _saveView.addTask(new SerialTask(oldLocTask, new SelfDestructTask()));
        }

        var saveViewTask :SerialTask = new SerialTask(newLocTask);
        if (removeModeUnderneath) {
            saveViewTask.addTask(new FunctionTask(
                function () :void {
                    AppContext.mainLoop.removeMode(-2);
                }));
        }

        var localSave :SavedEndlessGame;
        var remoteSave :SavedEndlessGame;
        if (mapIndex == 0) {
            localSave = _level1;
            remoteSave = (_remoteSaves != null ? _level1 : null);
        } else {
            localSave = _localSaves.getSave(mapIndex);
            remoteSave = (_remoteSaves != null ? _remoteSaves.getSave(mapIndex) : null);
        }

        var showStats :Boolean =
            (_mode == GAME_OVER_MODE && mapIndex == EndlessGameContext.mapIndex);

        _saveView = new SaveView(_level, localSave, remoteSave, showStats,
            this.enableNextPrevPlayButtons, this.enableQuitButton);

        _saveView.x = newStartLoc.x;
        _saveView.y = newStartLoc.y;
        _saveView.addTask(saveViewTask);
        addObject(_saveView, _saveViewLayer);

        // wire up buttons
        registerListener(_saveView.helpButton, MouseEvent.CLICK, onHelpClicked);

        if (this.enableQuitButton) {
            registerOneShotCallback(_saveView.quitButton, MouseEvent.CLICK, onQuitClicked);
        }

        if (this.enableNextPrevPlayButtons) {
            var nextButton :SimpleButton = _saveView.nextButton;
            var prevButton :SimpleButton = _saveView.prevButton;
            var playButton :SimpleButton = _saveView.playButton;

            if (_highestMapIndex > 1) {
                nextButton.visible = true;
                prevButton.visible = true;
                registerOneShotCallback(nextButton, MouseEvent.CLICK,
                    function (...ignored) :void {
                        var index :int = _mapIndex + 1;
                        if (index > _highestMapIndex) {
                            index = 0;
                        }
                        selectMap(index, ANIMATE_NEXT, false);
                    });

                registerOneShotCallback(prevButton, MouseEvent.CLICK,
                    function (...ignored) :void {
                        var index :int = _mapIndex - 1;
                        if (index < 0) {
                            index = _highestMapIndex;
                        }
                        selectMap(index, ANIMATE_PREV, false);
                    });

            } else {
                nextButton.visible = false;
                prevButton.visible = false;
            }

            playButton.visible = true;
            registerOneShotCallback(playButton, MouseEvent.CLICK,
                function (...ignored) :void {
                    onPlayClicked(mapIndex == 0 ? _level1 : _localSaves.getSave(mapIndex));
                });
        }
    }

    protected function animateToMode (nextMode :AppMode) :void
    {
        AppContext.mainLoop.insertMode(nextMode, -1);

        _saveView.removeAllTasks();
        _saveView.x = DOWN_LOC.x;
        _saveView.y = DOWN_LOC.y;
        _saveView.addTask(new SerialTask(
            LocationTask.CreateSmooth(UP_LOC.x, UP_LOC.y, ANIMATE_UP_TIME),
            new FunctionTask(AppContext.mainLoop.popMode)));
    }

    protected function onHelpClicked (...ignored) :void
    {
        if (_helpView == null) {
            _helpView = new HelpView();
            _helpView.x = HELP_VIEW_LOC.x;
            _helpView.y = HELP_VIEW_LOC.y;
            addObject(_helpView, _helpLayer);
        }

        _helpView.visible = true;
    }

    protected function onPlayClicked (save :SavedEndlessGame) :void
    {
        throw new Error("abstract");
    }

    protected function onQuitClicked (...ignored) :void
    {
        throw new Error("abstract");
    }

    protected function getLocalSavedGames () :SavedEndlessGameList
    {
        throw new Error("abstract");
    }

    protected function getRemoteSavedGames () :SavedEndlessGameList
    {
        return null;
    }

    protected function get enableNextPrevPlayButtons () :Boolean
    {
        return true;
    }

    protected function get enableQuitButton () :Boolean
    {
        return true;
    }

    protected var _mode :int;
    protected var _saveViewLayer :Sprite;
    protected var _helpLayer :Sprite;
    protected var _highestMapIndex :int;
    protected var _mapIndex :int = -1;
    protected var _level :EndlessLevelData;
    protected var _localSaves :SavedEndlessGameList;
    protected var _remoteSaves :SavedEndlessGameList;
    protected var _level1 :SavedEndlessGame;
    protected var _saveView :SaveView;
    protected var _initedLocalPlayerData :Boolean;
    protected var _helpView :HelpView;

    protected static const ANIMATE_DOWN_TIME :Number = 0.75;
    protected static const ANIMATE_UP_TIME :Number = 1.5;
    protected static const ANIMATE_NEXTPREV_TIME :Number = 0.5;
    protected static const UP_LOC :Point = new Point(350, -328);
    protected static const DOWN_LOC :Point = new Point(350, 274);
    protected static const NEXT_LOC :Point = new Point(1050, 274);
    protected static const PREV_LOC :Point = new Point(-450, 274);

    protected static const HELP_VIEW_LOC :Point = new Point(350, 250);

    protected static const ANIMATE_DOWN :int = 0;
    protected static const ANIMATE_NEXT :int = 1;
    protected static const ANIMATE_PREV :int = 2;

    protected static const LEVEL_SELECT_MODE :int = 0;
    protected static const GAME_OVER_MODE :int = 1;
}

}

import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;
import com.threerings.util.StringUtil;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.text.TextField;
import flash.display.Sprite;
import flash.geom.Point;
import flash.display.Bitmap;

import popcraft.*;
import popcraft.util.SpriteUtil;
import popcraft.data.*;
import popcraft.sp.endless.*;
import popcraft.ui.UIBits;
import popcraft.ui.RectMeterView;
import popcraft.ui.HealthMeters;
import popcraft.util.MyStringUtil;
import com.threerings.flash.DisplayUtil;
import flash.events.MouseEvent;

class HelpView extends SceneObject
{
    public function HelpView ()
    {
        _movie = SwfResource.instantiateMovieClip("splashUi", "help");

        var yearbook :MovieClip = _movie["yearbook"];
        for each (var name :String in STUDENT_NAMES) {
            var portraitParent :MovieClip = yearbook["p" + name];
            var portrait :Bitmap = ImageResource.instantiateBitmap("portrait_" + name.toLowerCase());
            portraitParent.addChild(portrait);
        }

        var closeButton :SimpleButton = _movie["close"];
        var localThis :HelpView = this;
        registerListener(closeButton, MouseEvent.CLICK,
            function (...ignored) :void {
                localThis.visible = false;
            });
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    protected var _movie :MovieClip;

    protected static const STUDENT_NAMES :Array =
        [ "Pigsley", "Horace", "Iris", "Ivy", "Ursula", "Dante", "Ralph", "Jack" ];
}

class SaveView extends SceneObject
{
    public function SaveView (level :EndlessLevelData, localSave :SavedEndlessGame,
        remoteSave :SavedEndlessGame, showGameOverStats :Boolean,
        createNextPrevPlayButtons :Boolean, createQuitButton :Boolean)
    {
        var mapData :EndlessMapData = level.getMapData(localSave.mapIndex);
        var cycleNumber :int = level.getMapCycleNumber(localSave.mapIndex);

        _movie = SwfResource.instantiateMovieClip("splashUi", "grate");
        _movie.cacheAsBitmap = true;

        // text
        var titleText :TextField = _movie["level_title"];
        titleText.text = level.getMapNumberedDisplayName(localSave.mapIndex);

        // cycle number (skulls across title)
        if (cycleNumber > 0) {
            var cycleSprite :Sprite = SpriteUtil.createSprite();
            for (var ii :int = 0; ii < cycleNumber; ++ii) {
                var cycleMovie :MovieClip = SwfResource.instantiateMovieClip("splashUi", "cycle");
                cycleMovie.x = cycleSprite.width + (cycleMovie.width * 0.5);
                cycleSprite.addChild(cycleMovie);
            }

            cycleSprite.x = CYCLE_LOC.x - (cycleSprite.width * 0.5);
            cycleSprite.y = CYCLE_LOC.y;
            _movie.addChild(cycleSprite);
        }

        // buttons
        var buttonSprite :Sprite = SpriteUtil.createSprite(true);

        if (createQuitButton) {
            _quitButton = UIBits.createButton("Quit", 1.5);
            DisplayUtil.positionBounds(_quitButton, 0, -quitButton.height * 0.5);
            buttonSprite.addChild(_quitButton);
        }

        if (createNextPrevPlayButtons) {
            _playButton = UIBits.createButton((showGameOverStats ? "Retry" : "Play"), 2.5);
            DisplayUtil.positionBounds(_playButton,
                buttonSprite.width + BUTTON_X_OFFSET,
                -_playButton.height * 0.5);
            buttonSprite.addChild(_playButton);

        } else {
            // these buttons are part of the movie
            this.nextButton.visible = false;
            this.prevButton.visible = false;
        }

        _helpButton = UIBits.createButton("Help", 1.5);
        DisplayUtil.positionBounds(_helpButton,
            buttonSprite.width + BUTTON_X_OFFSET,
            -_helpButton.height * 0.5);
        buttonSprite.addChild(_helpButton);

        DisplayUtil.positionBounds(buttonSprite,
            BUTTONS_CTR_LOC.x - (buttonSprite.width * 0.5),
            BUTTONS_CTR_LOC.y - (buttonSprite.height * 0.5));
        _movie.addChild(buttonSprite);

        // stats
        var statPanel :MovieClip = _movie["stat_panel"];
        var scoreText :TextField = _movie["level_score"];
        var remoteSavePanel :MovieClip = _movie["second_row"];
        if (showGameOverStats) {
            statPanel.visible = true;
            scoreText.visible = false;
            remoteSavePanel.visible = false;

            // opponent portraits
            var xLoc :Number = 0;
            var opponentPortraitSprite :Sprite = SpriteUtil.createSprite();
            var opponentNames :Array = [];
            for each (var opponentData :EndlessComputerPlayerData in mapData.computers) {
                var displayData :PlayerDisplayData =
                    GameContext.gameData.getPlayerDisplayData(opponentData.playerName);
                var opponentPortrait :DisplayObject = displayData.headshot;
                opponentPortrait.x = xLoc;
                opponentPortraitSprite.addChild(opponentPortrait);

                xLoc += opponentPortrait.width + OPPONENT_PORTRAIT_X_OFFSET;

                opponentNames.push(displayData.displayName);
            }

            opponentPortraitSprite.x =
                OPPONENT_PORTRAITS_LOC.x - (opponentPortraitSprite.width * 0.5);
            opponentPortraitSprite.y = OPPONENT_PORTRAITS_LOC.y;
            _movie.addChild(opponentPortraitSprite);

            var numOpponentsDefeated :int;
            for (var mapIndex :int = 0; mapIndex < localSave.mapIndex; ++mapIndex) {
                numOpponentsDefeated += level.getMapData(mapIndex).computers.length;
            }

            var statText :TextField = statPanel["flavor_text"];
            statText.text =
                "You were defeated by " + MyStringUtil.commafyWords(opponentNames) + "!\n" +
                "Final score: " + StringUtil.formatNumber(EndlessGameContext.score) + "\n" +
                "Schoolmates whipped: " + numOpponentsDefeated + "\n\nHave another go?";

        } else {
            statPanel.visible = false;
            scoreText.visible = true;

            // thumbnail
            var mapNumber :int = localSave.mapIndex % level.mapSequence.length;
            var thumbnail :Bitmap =
                ImageResource.instantiateBitmap("endlessThumb" + String(mapNumber + 1));
            thumbnail.x = THUMBNAIL_LOC.x - (thumbnail.width * 0.5);
            thumbnail.y = THUMBNAIL_LOC.y - (thumbnail.height * 0.5);
            _movie.addChild(thumbnail);

            // score text
            scoreText.text = "Score: " + StringUtil.formatNumber(localSave.score);

            // save panels
            if (remoteSave != null) {
                for (var playerIndex :int = 0; playerIndex < SeatingManager.numExpectedPlayers; ++playerIndex) {
                    var headshot :DisplayObject = SeatingManager.getPlayerHeadshot(playerIndex);
                    var hsLoc :Point = (playerIndex == SeatingManager.localPlayerSeat ?
                        LOCAL_HEADSHOT_LOC :
                        REMOTE_HEADSHOT_LOC);

                    var scale :Number = Math.min(1, MAX_HEADSHOT_HEIGHT / headshot.height);
                    headshot.scaleX = scale;
                    headshot.scaleY = scale;
                    headshot.x = hsLoc.x - (headshot.width * 0.5);
                    headshot.y = hsLoc.y - (headshot.height * 0.5);
                    _movie.addChild(headshot);
                }
            }

            var saveStatsSprite :Sprite = createSaveStatsSprite(level, localSave);
            saveStatsSprite.x = SAVESTATS1_CTR_LOC.x - (saveStatsSprite.width * 0.5);
            saveStatsSprite.y = SAVESTATS1_CTR_LOC.y;
            _movie.addChild(saveStatsSprite);

            remoteSavePanel.visible = (remoteSave != null);
            if (remoteSave != null) {
                saveStatsSprite = createSaveStatsSprite(level, remoteSave);
                saveStatsSprite.x = SAVESTATS2_CTR_LOC.x - (saveStatsSprite.width * 0.5);
                saveStatsSprite.y = SAVESTATS2_CTR_LOC.y;
                _movie.addChild(saveStatsSprite);
            }
        }
    }

    protected function createSaveStatsSprite (level :EndlessLevelData, save :SavedEndlessGame)
        :Sprite
    {
        // elementsSprite contains all the visual elements of the save data -
        // health/shields, infusions, and multipliers, spaced out from each other
        var elementsSprite :Sprite = SpriteUtil.createSprite();

        var elementLoc :Point = new Point(0, 0);

        // health/shield meters
        var healthSprite :Sprite = SpriteUtil.createSprite();
        var workshopData :UnitData = level.gameDataOverride.units[Constants.UNIT_TYPE_WORKSHOP];
        var healthMeter :RectMeterView = new RectMeterView();
        healthMeter.minValue = 0;
        healthMeter.maxValue = workshopData.maxHealth;
        healthMeter.value = save.health;
        healthMeter.foregroundColor = 0xFF0000;
        healthMeter.backgroundColor = 0x888888;
        healthMeter.outlineColor = 0x000000;
        healthMeter.outlineSize = 2;
        healthMeter.meterWidth = 80;
        healthMeter.meterHeight = 15;
        healthMeter.updateDisplay();
        healthSprite.addChild(healthMeter);

        var numShields :int = save.multiplier - 1;
        if (numShields > 0) {
            var shieldSprite :Sprite = SpriteUtil.createSprite();
            for (var ii :int = 0; ii < numShields; ++ii) {
                var shieldMeter :RectMeterView = new RectMeterView();
                shieldMeter.minValue = 0;
                shieldMeter.maxValue = 1;
                shieldMeter.value = 1;
                shieldMeter.foregroundColor = 0xFFFFFF;
                shieldMeter.outlineColor = 0x000000;
                shieldMeter.outlineSize = 2;
                shieldMeter.meterWidth = 20;
                shieldMeter.meterHeight = 15;
                shieldMeter.updateDisplay();
                shieldMeter.x = 20 * ii;
                shieldSprite.addChild(shieldMeter);
            }
            shieldSprite.x = (healthSprite.width - shieldSprite.width) * 0.5;
            shieldSprite.y = 0;
            healthSprite.addChild(shieldSprite);

            healthMeter.y = shieldSprite.height - 2;
        }

        DisplayUtil.positionBounds(healthSprite, elementLoc.x, elementLoc.y - (healthSprite.height * 0.5));
        elementsSprite.addChild(healthSprite);
        elementLoc.x += healthSprite.width + ELEMENT_X_OFFSET;

        // infusions
        var infusionSprite :Sprite = SpriteUtil.createSprite();
        var loc :Point = new Point(0, 0);
        drawIcons(infusionSprite, "infusion_bloodlust",
            save.spells[Constants.SPELL_TYPE_BLOODLUST], loc, INFUSION_X_OFFSET);
        loc.x = infusionSprite.width + 2;
        drawIcons(infusionSprite, "infusion_rigormortis",
            save.spells[Constants.SPELL_TYPE_RIGORMORTIS], loc, INFUSION_X_OFFSET);
        loc.x = infusionSprite.width + 2;
        drawIcons(infusionSprite, "infusion_shuffle",
            save.spells[Constants.SPELL_TYPE_PUZZLERESET], loc, INFUSION_X_OFFSET);

        DisplayUtil.positionBounds(infusionSprite, elementLoc.x, elementLoc.y - (infusionSprite.height * 0.5));
        elementsSprite.addChild(infusionSprite);
        elementLoc.x += infusionSprite.width + ELEMENT_X_OFFSET;

        // multipliers
        var numMultipliers :int = save.multiplier - 1;
        if (numMultipliers > 0) {
            var multiplierSprite :Sprite = SpriteUtil.createSprite();
            loc = new Point(0, 0);
            drawIcons(multiplierSprite, "multiplier", numMultipliers, loc, MULTIPLIER_X_OFFSET);
            DisplayUtil.positionBounds(multiplierSprite, elementLoc.x, elementLoc.y - (multiplierSprite.height * 0.5));
            elementsSprite.addChild(multiplierSprite);
        }

        return elementsSprite;
    }

    protected function drawIcons (sprite :Sprite, name :String, count :int, start :Point,
        xOffset :Number) :void
    {
        for (var ii :int = count - 1; ii >= 0; --ii) {
            var icon :MovieClip = SwfResource.instantiateMovieClip("splashUi", name);
            icon.x = start.x + (xOffset * ii);
            icon.y = start.y;
            sprite.addChild(icon);
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    public function get nextButton () :SimpleButton
    {
        return _movie["next"];
    }

    public function get prevButton () :SimpleButton
    {
        return _movie["previous"];
    }

    public function get playButton () :SimpleButton
    {
        return _playButton;
    }

    public function get quitButton () :SimpleButton
    {
        return _quitButton;
    }

    public function get helpButton () :SimpleButton
    {
        return _helpButton;
    }

    protected var _mode :int;
    protected var _movie :MovieClip;
    protected var _playButton :SimpleButton;
    protected var _quitButton :SimpleButton;
    protected var _helpButton :SimpleButton;

    protected static const LOCAL_HEADSHOT_LOC :Point = new Point(-232, -63);
    protected static const REMOTE_HEADSHOT_LOC :Point = new Point(-232, -23);
    protected static const MAX_HEADSHOT_HEIGHT :int = 30;
    protected static const BUTTONS_CTR_LOC :Point = new Point(0, 190);
    protected static const BUTTON_X_OFFSET :Number = 15;
    protected static const THUMBNAIL_LOC :Point = new Point(0, 80);
    protected static const CYCLE_LOC :Point = new Point(0, -213);
    protected static const INFUSION_X_OFFSET :Number = 15;
    protected static const MULTIPLIER_X_OFFSET :Number = 16;
    protected static const ELEMENT_X_OFFSET :Number = 30;
    protected static const SAVESTATS1_CTR_LOC :Point = new Point(0, -63);
    protected static const SAVESTATS2_CTR_LOC :Point = new Point(0, -23);
    protected static const OPPONENT_PORTRAITS_LOC :Point = new Point(0, -80);
    protected static const OPPONENT_PORTRAIT_X_OFFSET :Number = 20;
}
