package vampire.feeding.client {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;

import vampire.feeding.*;

public class CellBurst extends CollidableObj
{
    public function CellBurst (cellType :int, radiusMin :Number, radiusMax :Number)
    {
        _cellType = cellType;
        _radius = radiusMin;
        _radiusMax = radiusMax;

        _movie = ClientCtx.instantiateMovieClip("blood", MOVIE_NAMES[cellType], true, false);
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
        //SwfResource.releaseMovieClip(_movie);
        super.destroyed();
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    public function get radiusMax () :Number
    {
        return _radiusMax;
    }

    public function get targetScale () :Number
    {
        return (_radiusMax / _radius);
    }

    public function get cellType () :int
    {
        return _cellType;
    }

    override protected function addedToDB () :void
    {
        beginBurst();
    }

    protected function beginBurst () :void
    {
        // Superclasses override
    }

    protected var _movie :MovieClip;

    protected var _cellType :int;
    protected var _radiusMax :Number;

    protected static const MOVIE_NAMES :Array = [
        "cell_red_burst",
        "cell_white_burst",
        "cell_coop_burst",
    ];
}

}
