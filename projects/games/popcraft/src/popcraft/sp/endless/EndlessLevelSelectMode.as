package popcraft.sp.endless {

import com.threerings.util.ArrayUtil;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.Graphics;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.geom.Point;

import popcraft.*;
import popcraft.data.EndlessLevelData;
import popcraft.data.EndlessMapData;
import popcraft.data.UnitData;
import popcraft.ui.UIBits;

public class EndlessLevelSelectMode extends AppMode
{
    override protected function setup () :void
    {
        super.setup();

        var g :Graphics = this.modeSprite.graphics;
        g.beginFill(0);
        g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
        g.endFill();

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
        var level1 :SavedEndlessGame = SavedEndlessGame.create(0, 0, 0, workshopData.maxHealth,
            ArrayUtil.create(Constants.CASTABLE_SPELL_TYPE__LIMIT, 0));
        _saves.splice(0, 0, level1);

        _info = new SavedGameInfo();
        _info.x = 350;
        _info.y = 60;
        this.addObject(_info, _modeSprite);

        // buttons
        var playButton :SimpleButton = UIBits.createButton("Play", 2);
        playButton.x = 350 - (playButton.width * 0.5);
        playButton.y = 190;
        this.registerOneShotCallback(playButton, MouseEvent.CLICK,
            function (...ignored) :void {
                startGame(_saves[_saveIndex]);
            });
        _modeSprite.addChild(playButton);

        var prevButton :SimpleButton = UIBits.createButton("Prev", 2);
        prevButton.x = 50;
        prevButton.y = 370;
        this.registerEventListener(prevButton, MouseEvent.CLICK,
            function (...ignored) :void {
                var index :int = _saveIndex - 1;
                if (index < 0) {
                    index = _saves.length - 1;
                }
                selectSave(index, ANIMATE_PREV);
            });
        _modeSprite.addChild(prevButton);

        var nextButton :SimpleButton = UIBits.createButton("Next", 2);
        nextButton.x = 650 - nextButton.width;
        nextButton.y = 370;
        this.registerEventListener(nextButton, MouseEvent.CLICK,
            function (...ignored) :void {
                var index :int = _saveIndex + 1;
                if (index >= _saves.length) {
                    index = 0;
                }
                selectSave(index, ANIMATE_NEXT);
            });
        _modeSprite.addChild(nextButton);

        this.selectSave(0, ANIMATE_NONE);
    }

    protected function selectSave (saveIndex :int, animate :int) :void
    {
        var save :SavedEndlessGame = _saves[saveIndex];

        // are we animating from left-to-right, or right-to-left?
        var outLoc :Point;
        var inLoc :Point;
        if (animate == ANIMATE_NEXT) {
            outLoc = THUMBNAIL_PREV_LOC;
            inLoc = THUMBNAIL_NEXT_LOC;
        } else {
            outLoc = THUMBNAIL_NEXT_LOC;
            inLoc = THUMBNAIL_PREV_LOC;
        }

        // animate out the old thumbnail
        if (_thumbnail != null) {
            _thumbnail.removeAllTasks();
            if (animate == ANIMATE_NONE) {
                _thumbnail.destroySelf();

            } else {
                _thumbnail.alpha = 1;
                _thumbnail.addTask(new SerialTask(
                    new ParallelTask(
                        LocationTask.CreateSmooth(outLoc.x, outLoc.y, ANIMATE_TIME),
                        new AlphaTask(0, ANIMATE_TIME)),
                    new SelfDestructTask()));
            }
        }

        // create the thumbnail, and animate it in
        _thumbnail = new SavedGameThumbnail(save);
        this.addObject(_thumbnail, _modeSprite);
        if (animate == ANIMATE_NONE) {
            _thumbnail.x = THUMBNAIL_LOC.x;
            _thumbnail.y = THUMBNAIL_LOC.y;

        } else {
            _thumbnail.x = inLoc.x;
            _thumbnail.y = inLoc.y;
            _thumbnail.alpha = 0;
            _thumbnail.addTask(new ParallelTask(
                LocationTask.CreateSmooth(THUMBNAIL_LOC.x, THUMBNAIL_LOC.y, ANIMATE_TIME),
                new AlphaTask(1, ANIMATE_TIME)));
        }

        // animate in the new level info
        _info.removeAllTasks();
        if (animate == ANIMATE_NONE) {
            _info.updateInfo(_level, save);

        } else {
            _info.addTask(new SerialTask(
                new AlphaTask(0, ANIMATE_TIME * 0.5),
                new FunctionTask(
                    function () :void {
                        _info.updateInfo(_level, save);
                    }),
                new AlphaTask(1, ANIMATE_TIME * 0.5)));
        }

        _saveIndex = saveIndex;
    }

    protected function createSavedGameButton (save :SavedEndlessGame) :SimpleButton
    {
        var mapData :EndlessMapData = _level.getMapData(save.mapIndex);
        var cycleNumber :int = _level.getMapCycleNumber(save.mapIndex);

        var buttonName :String = mapData.displayName + " (" + String(cycleNumber + 1) + ")";
        return UIBits.createButton(buttonName, 2);
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
    protected var _thumbnail :SavedGameThumbnail;
    protected var _info :SavedGameInfo;

    protected static const ANIMATE_TIME :Number = 0.4;
    protected static const THUMBNAIL_LOC :Point = new Point(350, 360);
    protected static const THUMBNAIL_NEXT_LOC :Point = new Point(650, 360);
    protected static const THUMBNAIL_PREV_LOC :Point = new Point(50, 360);

    protected static const ANIMATE_NONE :int = 0;
    protected static const ANIMATE_NEXT :int = 1;
    protected static const ANIMATE_PREV :int = 2;
}

}

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.ImageResource;

import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.display.InteractiveObject;

import popcraft.*;
import popcraft.sp.endless.SavedEndlessGame;
import popcraft.ui.*;
import popcraft.data.EndlessLevelData;
import popcraft.data.EndlessMapData;
import popcraft.battle.UnitDamageShield;
import flash.text.TextField;
import flash.display.Bitmap;

class SavedGameThumbnail extends SceneObject
{
    public function SavedGameThumbnail (save :SavedEndlessGame)
    {
        _save = save;

        _sprite = new Sprite();
        var image :Bitmap = ImageResource.instantiateBitmap("endlessThumb");
        image.x = -image.width * 0.5;
        image.y = -image.height * 0.5;
        _sprite.addChild(image);
    }

    public function get save () :SavedEndlessGame
    {
        return _save;
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _save :SavedEndlessGame;
    protected var _sprite :Sprite;

    protected static const WIDTH :Number = 180;
    protected static const HEIGHT :Number = 135;
}

class SavedGameInfo extends SceneObject
{
    public function SavedGameInfo ()
    {
        _sprite = new Sprite();
        _titleText = new TextField();
        _infoText = new TextField();

        _sprite.addChild(_titleText);
        _sprite.addChild(_infoText);
    }

    public function updateInfo (level :EndlessLevelData, save :SavedEndlessGame) :void
    {
        _sprite.removeChild(_titleText);
        _sprite.removeChild(_infoText);

        var mapData :EndlessMapData = level.getMapData(save.mapIndex);
        var cycleNumber :int = level.getMapCycleNumber(save.mapIndex);

        _titleText = UIBits.createText(mapData.displayName + " (" + cycleNumber + ")", 4, 0, 0xFFFFFF);
        _infoText = UIBits.createText("Score: " + save.score + " x" + save.multiplier, 2, 0, 0xFFFFFF);

        _sprite.addChild(_titleText);
        _sprite.addChild(_infoText);

        _titleText.x = -_titleText.width * 0.5;
        _infoText.x = -_infoText.width * 0.5;
        _infoText.y = _titleText.height + 2;
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _sprite :Sprite;
    protected var _titleText :TextField;
    protected var _infoText :TextField;
}
