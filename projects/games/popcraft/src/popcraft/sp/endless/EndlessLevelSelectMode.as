package popcraft.sp.endless {

import com.threerings.util.ArrayUtil;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;

import popcraft.*;
import popcraft.data.EndlessLevelData;
import popcraft.data.UnitData;
import popcraft.sp.story.LevelSelectMode;
import popcraft.ui.UIBits;
import popcraft.util.SpriteUtil;

public class EndlessLevelSelectMode extends AppMode
{
    public static const LEVEL_SELECT_MODE :int = 0;
    public static const GAME_OVER_MODE :int = 1;

    public function EndlessLevelSelectMode (mode :int)
    {
        _mode = mode;
    }

    override protected function setup () :void
    {
        super.setup();

        // we need to load the endless level in order to create the UI
        if (this.isMultiplayer) {
            AppContext.endlessLevelMgr.playMpLevel(createUi);
        } else {
            AppContext.endlessLevelMgr.playSpLevel(createUi);
        }
    }

    protected function createUi (level :EndlessLevelData) :void
    {
        _saveViewLayer = SpriteUtil.createSprite(true);
        _topLayer = SpriteUtil.createSprite(true);
        _modeSprite.addChild(_saveViewLayer);
        _modeSprite.addChild(_topLayer);

        _level = level;

        _saves = (this.isMultiplayer ? AppContext.endlessLevelMgr.savedMpGames :
            AppContext.endlessLevelMgr.savedSpGames).slice();

        // insert a dummy Level 1 save into the save array, so that players can start
        // new games
        var workshopData :UnitData = _level.gameDataOverride.units[Constants.UNIT_TYPE_WORKSHOP];
        var level1 :SavedEndlessGame = SavedEndlessGame.create(0, 0, 1, workshopData.maxHealth,
            ArrayUtil.create(Constants.CASTABLE_SPELL_TYPE__LIMIT, 0));
        _saves.splice(0, 0, level1);

        this.selectSave(_saves.length - 1, ANIMATE_DOWN, true);
    }

    protected function selectSave (saveIndex :int, animationType :int,
        removeModeUnderneath :Boolean) :void
    {
        _saveIndex = saveIndex;

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

        var save :SavedEndlessGame = _saves[saveIndex];
        var showStats :Boolean =
            (_mode == GAME_OVER_MODE && save.mapIndex == EndlessGameContext.mapIndex);

        _saveView = new SaveView(_level, _saves[saveIndex], showStats);
        _saveView.x = newStartLoc.x;
        _saveView.y = newStartLoc.y;
        _saveView.addTask(saveViewTask);
        this.addObject(_saveView, _saveViewLayer);

        // wire up buttons
        var nextButton :SimpleButton = _saveView.nextButton;
        var prevButton :SimpleButton = _saveView.prevButton;
        if (_saves.length > 1) {
            this.registerOneShotCallback(nextButton, MouseEvent.CLICK,
                function (...ignored) :void {
                    var index :int = _saveIndex + 1;
                    if (index >= _saves.length) {
                        index = 0;
                    }
                    selectSave(index, ANIMATE_NEXT, false);
                });

            this.registerOneShotCallback(prevButton, MouseEvent.CLICK,
                function (...ignored) :void {
                    var index :int = _saveIndex - 1;
                    if (index < 0) {
                        index = _saves.length - 1;
                    }
                    selectSave(index, ANIMATE_PREV, false);
                });

        } else {
            nextButton.visible = false;
            prevButton.visible = false;
        }

        this.registerOneShotCallback(_saveView.playButton, MouseEvent.CLICK,
            function (...ignored) :void {
                startGame(_saves[_saveIndex]);
            });

        this.registerOneShotCallback(_saveView.backButton, MouseEvent.CLICK, backToMainMenu);
    }

    protected function startGame (save :SavedEndlessGame) :void
    {
        GameContext.gameType = (this.isMultiplayer ? GameContext.GAME_TYPE_ENDLESS_MP :
            GameContext.GAME_TYPE_ENDLESS_SP);

        this.animateToMode(new EndlessGameMode(_level, save, true));
    }

    protected function backToMainMenu (...ignored) :void
    {
        LevelSelectMode.create(false, animateToMode);
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

    protected function get isMultiplayer () :Boolean
    {
        return SeatingManager.numExpectedPlayers > 1;
    }

    protected function get isSinglePlayer () :Boolean
    {
        return !isMultiplayer;
    }

    protected var _mode :int;
    protected var _saveViewLayer :Sprite;
    protected var _topLayer :Sprite;
    protected var _saves :Array;
    protected var _saveIndex :int = -1;
    protected var _level :EndlessLevelData;
    protected var _saveView :SaveView;

    protected static const ANIMATE_DOWN_TIME :Number = 0.75;
    protected static const ANIMATE_UP_TIME :Number = 1.5;
    protected static const ANIMATE_NEXTPREV_TIME :Number = 0.5;
    protected static const UP_LOC :Point = new Point(350, -328);
    protected static const DOWN_LOC :Point = new Point(350, 274);
    protected static const NEXT_LOC :Point = new Point(1050, 274);
    protected static const PREV_LOC :Point = new Point(-450, 274);

    protected static const ANIMATE_DOWN :int = 0;
    protected static const ANIMATE_NEXT :int = 1;
    protected static const ANIMATE_PREV :int = 2;
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

class SaveView extends SceneObject
{
    public function SaveView (level :EndlessLevelData, save :SavedEndlessGame,
        showGameOverStats :Boolean)
    {
        var mapData :EndlessMapData = level.getMapData(save.mapIndex);
        var cycleNumber :int = level.getMapCycleNumber(save.mapIndex);

        _movie = SwfResource.instantiateMovieClip("splashUi", "grate");
        _movie.cacheAsBitmap = true;

        // text
        var titleText :TextField = _movie["level_title"];
        titleText.text = level.getMapNumberedDisplayName(save.mapIndex);

        var scoreText :TextField = _movie["level_score"];
        scoreText.text = "Score: " + StringUtil.formatNumber(save.score);

        var ii :int;

        // cycle number (skulls across title)
        if (cycleNumber > 0) {
            var cycleSprite :Sprite = SpriteUtil.createSprite();
            for (ii = 0; ii < cycleNumber; ++ii) {
                var cycleMovie :MovieClip = SwfResource.instantiateMovieClip("splashUi", "cycle");
                cycleMovie.x = cycleSprite.width + (cycleMovie.width * 0.5);
                cycleSprite.addChild(cycleMovie);
            }

            cycleSprite.x = CYCLE_LOC.x - (cycleSprite.width * 0.5);
            cycleSprite.y = CYCLE_LOC.y;
            _movie.addChild(cycleSprite);
        }

        // health/shield meters
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
        healthMeter.x = HEALTH_LOC.x;
        healthMeter.y = HEALTH_LOC.y;
        _movie.addChild(healthMeter);

        var shieldParent :Sprite = SpriteUtil.createSprite();
        for (ii = 0; ii < save.multiplier - 1; ++ii) {
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
            shieldParent.addChild(shieldMeter);
        }
        shieldParent.x = SHIELD_CENTER_LOC.x - (shieldParent.width * 0.5);
        shieldParent.y = SHIELD_CENTER_LOC.y;
        _movie.addChild(shieldParent);

        // icons
        this.drawIcons("multiplier", save.multiplier - 1, MULTIPLIER_START, MULTIPLIER_OFFSET);
        this.drawIcons("infusion_bloodlust", save.spells[Constants.SPELL_TYPE_BLOODLUST], BLOODLUST_START, BLOODLUST_OFFSET);
        this.drawIcons("infusion_rigormortis", save.spells[Constants.SPELL_TYPE_RIGORMORTIS], RIGORMORTIS_START, RIGORMORTIS_OFFSET);
        this.drawIcons("infusion_shuffle", save.spells[Constants.SPELL_TYPE_PUZZLERESET], SHUFFLE_START, SHUFFLE_OFFSET);


        // play button
        _playButton = UIBits.createButton((showGameOverStats ? "Retry" : "Play"), 2.5);
        _playButton.x = PLAY_CENTER_LOC.x - (_playButton.width * 0.5);
        _playButton.y = PLAY_CENTER_LOC.y - (_playButton.height * 0.5);
        _movie.addChild(_playButton);

        // back button
        _backButton = UIBits.createButton("Main Menu", 1.2);
        _backButton.x = BACK_LOC.x;
        _backButton.y = BACK_LOC.y;
        _movie.addChild(_backButton);

        // stats
        var statPanel :MovieClip = _movie["stat_panel"];
        if (showGameOverStats) {
            statPanel.visible = true;

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
            opponentPortraitSprite.y =
                OPPONENT_PORTRAITS_LOC.y - (opponentPortraitSprite.height * 0.5);
            statPanel.addChild(opponentPortraitSprite);

            var numOpponentsDefeated :int;
            for (var mapIndex :int = 0; mapIndex < save.mapIndex; ++mapIndex) {
                numOpponentsDefeated += level.getMapData(mapIndex).computers.length;
            }

            var statText :TextField = statPanel["flavor_text"];
            statText.text =
                "You were defeated by " + MyStringUtil.commafyWords(opponentNames) + "!\n" +
                "Final score: " + StringUtil.formatNumber(EndlessGameContext.score) + "\n" +
                "Classmates whipped: " + numOpponentsDefeated + "\n\nHave another go?";

        } else {
            statPanel.visible = false;
            // thumbnail
            var thumbnail :Bitmap = ImageResource.instantiateBitmap("endlessThumb");
            thumbnail.x = THUMBNAIL_LOC.x - (thumbnail.width * 0.5);
            thumbnail.y = THUMBNAIL_LOC.y - (thumbnail.height * 0.5);
            _movie.addChild(thumbnail);
        }
    }

    protected function drawIcons (name :String, count :int, start :Point, offset :Point) :void
    {
        for (var ii :int = count - 1; ii >= 0; --ii) {
            var icon :MovieClip = SwfResource.instantiateMovieClip("splashUi", name);
            icon.x = start.x + (offset.x * ii);
            icon.y = start.y + (offset.y * ii);
            _movie.addChild(icon);
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

    public function get backButton () :SimpleButton
    {
        return _backButton;
    }

    protected var _mode :int;
    protected var _movie :MovieClip;
    protected var _playButton :SimpleButton;
    protected var _backButton :SimpleButton;

    protected static const BACK_LOC :Point = new Point(-330, 179);
    protected static const PLAY_CENTER_LOC :Point = new Point(0, 185);
    protected static const THUMBNAIL_LOC :Point = new Point(0, 60);
    protected static const CYCLE_LOC :Point = new Point(0, -213);
    protected static const SHIELD_CENTER_LOC :Point = new Point(-219, -78);
    protected static const HEALTH_LOC :Point = new Point(-260, -63);
    protected static const MULTIPLIER_START :Point = new Point(-160, -64);
    protected static const MULTIPLIER_OFFSET :Point = new Point(15, 0);
    protected static const BLOODLUST_START :Point = new Point(-62, -64);
    protected static const BLOODLUST_OFFSET :Point = new Point(15, 0);
    protected static const RIGORMORTIS_START :Point = new Point(-2, -64);
    protected static const RIGORMORTIS_OFFSET :Point = new Point(15, 0);
    protected static const SHUFFLE_START :Point = new Point(58, -64);
    protected static const SHUFFLE_OFFSET :Point = new Point(15, 0);
    protected static const OPPONENT_PORTRAITS_LOC :Point = new Point(0, -80);
    protected static const OPPONENT_PORTRAIT_X_OFFSET :Number = 20;
}
