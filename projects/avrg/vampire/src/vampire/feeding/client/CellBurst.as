package vampire.feeding.client {

import com.whirled.contrib.simplegame.resource.SwfResource;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;

import vampire.feeding.*;
import vampire.feeding.client.view.SpriteUtil;

public class CellBurst extends CollidableObj
{
    public function CellBurst (burstType :int, radiusMin :Number, radiusMax :Number)
    {
        _radius = radiusMin;
        _radiusMax = radiusMax;

        _movie = ClientCtx.instantiateMovieClip("blood", MOVIE_NAMES[burstType], true, true);
        _sprite = SpriteUtil.createSprite();
        _sprite.addChild(_movie);

        _movie.gotoAndStop(1);

        addTask(After(Constants.BURST_COMPLETE_TIME - 0.25,
            new FunctionTask(function () :void {
                _movie.gotoAndPlay(2);
            })));
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        this.displayObject.x = _loc.x;
        this.displayObject.y = _loc.y;
    }

    override protected function destroyed () :void
    {
        SwfResource.releaseMovieClip(_movie);
        super.destroyed();
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    public function get radiusMax () :Number
    {
        return _radiusMax;
    }

    public function get targetScale () :Number
    {
        return (_radiusMax / _radius);
    }

    override protected function addedToDB () :void
    {
        beginBurst();
    }

    protected function beginBurst () :void
    {
        // Superclasses override
    }

    protected var _sprite :Sprite;
    protected var _movie :MovieClip;

    protected var _cellType :int;
    protected var _radiusMax :Number;

    protected static const MOVIE_NAMES :Array = [
        "cell_red_burst",
        "cell_white_burst",
        "cell_coop_burst",
        "cell_black_burst",
    ];
}

}
