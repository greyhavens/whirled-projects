package vampire.feeding.client {

import com.whirled.contrib.simplegame.resource.SwfResource;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;

import vampire.client.SpriteUtil;
import vampire.feeding.*;

public class CellBurst extends CollidableObj
{
    public function CellBurst (burstType :int, radiusMin :Number, radiusMax :Number,
                               multiplier :int, cascade :BurstCascade)
    {
        _radius = radiusMin;
        _radiusMax = radiusMax;
        _multiplier = multiplier;
        _cascade = cascade;

        _movie = ClientCtx.instantiateMovieClip("blood", MOVIE_NAMES[burstType], true, true);
        _sprite = SpriteUtil.createSprite();
        _sprite.addChild(_movie);

        _movie.gotoAndStop(1);

        addTask(After(Constants.BURST_COMPLETE_TIME - 0.25,
            new FunctionTask(function () :void {
                _movie.gotoAndPlay(2);
            })));
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

    public function get multiplier () :int
    {
        return _multiplier;
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
        if (_cascade == null) {
            _cascade = new BurstCascade();
            _cascade.x = this.x;
            _cascade.y = this.y;
            GameCtx.gameMode.addSceneObject(_cascade, GameCtx.effectLayer);
        }

        if (_cascade != null) {
            _cascade.addCellBurst(this);
        }
    }

    protected var _sprite :Sprite;
    protected var _movie :MovieClip;

    protected var _cellType :int;
    protected var _multiplier :int;
    protected var _radiusMax :Number;

    protected var _cascade :BurstCascade;

    protected static const MOVIE_NAMES :Array = [
        "cell_red_burst",
        "cell_white_burst",
        "cell_coop_burst",
        "cell_black_burst",
    ];
}

}
