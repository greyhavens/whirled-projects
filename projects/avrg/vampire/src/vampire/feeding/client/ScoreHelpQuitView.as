package vampire.feeding.client {

import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.SwfResource;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;

import vampire.feeding.*;

public class ScoreHelpQuitView extends SceneObject
{
    public function ScoreHelpQuitView ()
    {
        _movie = ClientCtx.instantiateMovieClip(
            "blood", (ClientCtx.isCorruption ? "score_corruption" : "score"), false, true);
        _tf = _movie["score_field"];

        var quitButton :SimpleButton = _movie["button_quit"];
        registerListener(quitButton, MouseEvent.CLICK,
            function (...ignored) :void {
                ClientCtx.quit(true);
            });

        var helpButton :SimpleButton = _movie["button_info"];
        registerListener(helpButton, MouseEvent.CLICK,
            function (...ignored) :void {
                InfoView.show(GameCtx.helpLayer);
            });
    }

    public function get isPlayingScoreAnim () :Boolean
    {
        return (GameCtx.gameMode.getObjectRefsInGroup("FlyingCell").length > 0);
    }

    override protected function destroyed () :void
    {
        SwfResource.releaseMovieClip(_movie);
        super.destroyed();
    }

    public function addBlood (x :Number, y :Number, count :int, initialDelay :Number) :void
    {
        _bloodCount += count;

        var loc :Point = this.displayObject.globalToLocal(new Point(x, y));

        var delay :Number = initialDelay;
        for (var cellSize :int = 0; cellSize < CELL_SIZE_VALUES.length; ++cellSize) {
            var cellValue :int = CELL_SIZE_VALUES[cellSize];
            var numCells :int = count / cellValue;
            for (var ii :int = 0; ii < numCells; ++ii) {
                var cell :FlyingCell = createFlyingCell(cellSize, delay);
                cell.x = loc.x;
                cell.y = loc.y;
                delay += 0.1;
            }

            count %= cellValue;
        }
    }

    protected function createFlyingCell (size :int, delay :Number) :FlyingCell
    {
        var cellObj :FlyingCell = new FlyingCell(size);
        GameCtx.gameMode.addSceneObject(cellObj, this.displayObject as DisplayObjectContainer);

        // fly the cell to the meter, make it disappear, increase the blood count
        cellObj.addTask(new SerialTask(
            new TimedTask(delay),
            LocationTask.CreateSmooth(221, -138, 1),
            new FunctionTask(
                function () :void {
                    _displayedBloodCount += CELL_SIZE_VALUES[size];
                }),
            new SelfDestructTask()));

        cellObj.addTask(new SerialTask(
            new TimedTask(delay + 0.85),
            new PlaySoundTask("sfx_got_blood")));

        return cellObj;
    }

    public function get bloodCount () :int
    {
        return _bloodCount;
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    override protected function update (dt :Number) :void
    {
        if (_displayedBloodCount != _lastDisplayedBloodCount) {
            _tf.text = String(_displayedBloodCount);
            _lastDisplayedBloodCount = _displayedBloodCount;
        }
    }

    protected var _movie :MovieClip;
    protected var _tf :TextField;
    protected var _bloodCount :int;
    protected var _lastDisplayedBloodCount :int = -1;
    protected var _displayedBloodCount :int;

    protected static const CELL_SIZE_VALUES :Array = [ 50, 5, 1 ];
}

}

import com.whirled.contrib.simplegame.objects.SceneObject;
import flash.display.MovieClip;
import flash.display.DisplayObject;

import vampire.feeding.client.*;
import com.whirled.contrib.simplegame.resource.SwfResource;
import flash.display.Sprite;
import vampire.feeding.client.SpriteUtil;

class FlyingCell extends SceneObject
{
    public function FlyingCell (size :int)
    {
        _sprite = SpriteUtil.createSprite();
        _movie =
            ClientCtx.instantiateMovieClip("blood", (ClientCtx.isCorruption ? "cell_black_burst" : "cell_red"), true, true);
        _sprite.addChild(_movie);
        _sprite.scaleX = _sprite.scaleY = SCALE[size];
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function destroyed () :void
    {
        SwfResource.releaseMovieClip(_movie);
    }

    override public function getObjectGroup (groupNum :int) :String
    {
        if (groupNum == 0) {
            return "FlyingCell";
        } else {
            return super.getObjectGroup(groupNum - 1);
        }
    }

    protected var _sprite :Sprite;
    protected var _movie :MovieClip;

    protected static const SCALE :Array = [ 4, 2, 1 ];
}
