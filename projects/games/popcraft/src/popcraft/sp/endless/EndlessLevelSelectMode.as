package popcraft.sp.endless {

import com.threerings.util.ArrayUtil;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.geom.Point;

import popcraft.*;
import popcraft.data.EndlessLevelData;
import popcraft.data.UnitData;

public class EndlessLevelSelectMode extends AppMode
{
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
        _level = level;

        _saves = (this.isMultiplayer ? AppContext.endlessLevelMgr.savedMpGames :
            AppContext.endlessLevelMgr.savedSpGames).slice();

        // insert a dummy Level 1 save into the save array, so that players can start
        // new games
        var workshopData :UnitData = _level.gameDataOverride.units[Constants.UNIT_TYPE_WORKSHOP];
        var level1 :SavedEndlessGame = SavedEndlessGame.create(0, 0, 1, workshopData.maxHealth,
            ArrayUtil.create(Constants.CASTABLE_SPELL_TYPE__LIMIT, 0));
        _saves.splice(0, 0, level1);

        this.selectSave(_saves.length - 1);
    }

    protected function selectSave (saveIndex :int) :void
    {
        _saveIndex = saveIndex;

        if (null != _saveView) {
            _saveView.removeAllTasks();
            _saveView.addTask(After(ANIMATE_TIME, new SelfDestructTask()));
        }

        _saveView = new SaveView(_level, _saves[saveIndex]);
        _saveView.x = START_LOC.x;
        _saveView.y = START_LOC.y;
        _saveView.addTask(LocationTask.CreateEaseIn(END_LOC.x, END_LOC.y, ANIMATE_TIME));
        this.addObject(_saveView, _modeSprite);

        // wire up buttons
        var nextButton :SimpleButton = _saveView.nextButton;
        var prevButton :SimpleButton = _saveView.prevButton;
        if (_saves.length > 1) {
            this.registerEventListener(nextButton, MouseEvent.CLICK,
                function (...ignored) :void {
                    var index :int = _saveIndex + 1;
                    if (index >= _saves.length) {
                        index = 0;
                    }
                    selectSave(index);
                });

            this.registerEventListener(prevButton, MouseEvent.CLICK,
                function (...ignored) :void {
                    var index :int = _saveIndex - 1;
                    if (index < 0) {
                        index = _saves.length - 1;
                    }
                    selectSave(index);
                });

        } else {
            nextButton.visible = false;
            prevButton.visible = false;
        }

        this.registerEventListener(_saveView.playButton, MouseEvent.CLICK,
            function (...ignored) :void {
                startGame(_saves[_saveIndex]);
            });
    }

    protected function startGame (save :SavedEndlessGame) :void
    {
        GameContext.gameType = (this.isMultiplayer ? GameContext.GAME_TYPE_ENDLESS_MP :
            GameContext.GAME_TYPE_ENDLESS_SP);

        AppContext.mainLoop.unwindToMode(new EndlessGameMode(_level, save, true));
    }

    protected function get isMultiplayer () :Boolean
    {
        return SeatingManager.numExpectedPlayers > 1;
    }

    protected function get isSinglePlayer () :Boolean
    {
        return !isMultiplayer;
    }

    protected var _saves :Array;
    protected var _saveIndex :int = -1;
    protected var _level :EndlessLevelData;
    protected var _saveView :SaveView;

    protected static const ANIMATE_TIME :Number = 0.6;
    protected static const START_LOC :Point = new Point(350, -250);
    protected static const END_LOC :Point = new Point(350, 250);
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

class SaveView extends SceneObject
{
    public function SaveView (level :EndlessLevelData, save :SavedEndlessGame)
    {
        var mapData :EndlessMapData = level.getMapData(save.mapIndex);
        var cycleNumber :int = level.getMapCycleNumber(save.mapIndex);

        _movie = SwfResource.instantiateMovieClip("splashUi", "grate");
        _movie.cacheAsBitmap = true;

        // text
        var titleText :TextField = _movie["level_title"];
        titleText.text = mapData.displayName;

        var scoreText :TextField = _movie["level_score"];
        scoreText.text = "Score: " + StringUtil.formatNumber(save.score);

        var ii :int;

        // cycle number
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

        this.drawIcons("multiplier", save.multiplier - 1, MULTIPLIER_START, MULTIPLIER_OFFSET);
        this.drawIcons("infusion_bloodlust", save.spells[Constants.SPELL_TYPE_BLOODLUST], BLOODLUST_START, BLOODLUST_OFFSET);
        this.drawIcons("infusion_rigormortis", save.spells[Constants.SPELL_TYPE_RIGORMORTIS], RIGORMORTIS_START, RIGORMORTIS_OFFSET);
        this.drawIcons("infusion_shuffle", save.spells[Constants.SPELL_TYPE_PUZZLERESET], SHUFFLE_START, SHUFFLE_OFFSET);

        // thumbnail
        var thumbnail :Bitmap = ImageResource.instantiateBitmap("endlessThumb");
        thumbnail.x = THUMBNAIL_LOC.x - (thumbnail.width * 0.5);
        thumbnail.y = THUMBNAIL_LOC.y - (thumbnail.height * 0.5);
        _movie.addChild(thumbnail);

        // play button
        _playButton = UIBits.createButton("Play", 2);
        _playButton.x = PLAY_LOC.x - (_playButton.width * 0.5);
        _playButton.y = PLAY_LOC.y - (_playButton.height * 0.5);
        _movie.addChild(_playButton);
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

    protected var _movie :MovieClip;
    protected var _playButton :SimpleButton;

    protected static const PLAY_LOC :Point = new Point(0, 190);
    protected static const THUMBNAIL_LOC :Point = new Point(0, 60);
    protected static const CYCLE_LOC :Point = new Point(0, -213);
    protected static const MULTIPLIER_START :Point = new Point(-160, -64);
    protected static const MULTIPLIER_OFFSET :Point = new Point(15, 0);
    protected static const BLOODLUST_START :Point = new Point(-62, -64);
    protected static const BLOODLUST_OFFSET :Point = new Point(15, 0);
    protected static const RIGORMORTIS_START :Point = new Point(-2, -64);
    protected static const RIGORMORTIS_OFFSET :Point = new Point(15, 0);
    protected static const SHUFFLE_START :Point = new Point(58, -64);
    protected static const SHUFFLE_OFFSET :Point = new Point(15, 0);
}
