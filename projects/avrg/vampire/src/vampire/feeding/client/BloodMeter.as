package vampire.feeding.client {

import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.geom.Point;
import flash.text.TextField;

import vampire.feeding.*;
import vampire.feeding.client.view.*;

public class BloodMeter extends SceneObject
{
    public function BloodMeter ()
    {
        _sprite = new Sprite();
        _tf = UIBits.createText("", 1.5);
        _sprite.addChild(_tf);
    }

    public function addBlood (x :Number, y :Number, count :int) :void
    {
        var loc :Point = this.displayObject.globalToLocal(new Point(x, y));
        var delay :Number = 0;
        for (var ii :int = 0; ii < count; ++ii) {
            var cellObj :FlyingCell = new FlyingCell();
            cellObj.x = loc.x;
            cellObj.y = loc.y;
            GameCtx.gameMode.addObject(cellObj, this.displayObject as DisplayObjectContainer);

            // fly the cell to the meter, make it disappear, increase the blood count
            cellObj.addTask(new SerialTask(
                new TimedTask(delay),
                LocationTask.CreateSmooth(0, 0, 1),
                new FunctionTask(
                    function () :void {
                        _displayedBloodCount++;
                    }),
                new SelfDestructTask()));

            cellObj.addTask(After(delay + 0.9, new AlphaTask(0, 0.1)));

            delay += 0.1;
        }

        _bloodCount += count;
    }

    public function get bloodCount () :int
    {
        return _bloodCount;
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function update (dt :Number) :void
    {
        if (_displayedBloodCount != _lastDisplayedBloodCount) {
            UIBits.initTextField(_tf, "Predator Blood: " + _displayedBloodCount, 1.5, 0, 0xff0000);
            _lastDisplayedBloodCount = _displayedBloodCount;
        }
    }

    protected var _sprite :Sprite;
    protected var _tf :TextField;
    protected var _bloodCount :int;
    protected var _lastDisplayedBloodCount :int = -1;
    protected var _displayedBloodCount :int;
}

}

import com.whirled.contrib.simplegame.objects.SceneObject;
import flash.display.MovieClip;
import flash.display.DisplayObject;

import vampire.feeding.client.*;
import com.whirled.contrib.simplegame.resource.SwfResource;
import flash.display.Sprite;
import vampire.feeding.client.view.SpriteUtil;

class FlyingCell extends SceneObject
{
    public function FlyingCell ()
    {
        _sprite = SpriteUtil.createSprite();
        _movie = ClientCtx.instantiateMovieClip("blood", "cell_red", true, true);
        _sprite.addChild(_movie);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function destroyed () :void
    {
        SwfResource.releaseMovieClip(_movie);
    }

    protected var _sprite :Sprite;
    protected var _movie :MovieClip;
}
