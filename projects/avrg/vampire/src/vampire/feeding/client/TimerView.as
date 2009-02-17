package vampire.feeding.client {

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.SwfResource;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;

import vampire.feeding.*;
import vampire.feeding.client.*;

public class TimerView extends SceneObject
{
    public function TimerView ()
    {
        _meter = ClientCtx.instantiateMovieClip("blood", "timer_meter", true, true);
        _pointer = ClientCtx.instantiateMovieClip("blood", "timer_pointer", true, true);

        _sprite = SpriteUtil.createSprite();
        _sprite.addChild(_pointer);
        _sprite.addChild(_meter);

        _pointer.rotation = ROTATE_MIN;
    }

    override protected function destroyed () :void
    {
        SwfResource.releaseMovieClip(_meter);
        SwfResource.releaseMovieClip(_pointer);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function update (dt :Number) :void
    {
        var time :Number = Constants.GAME_TIME - GameCtx.timeLeft;
        var rotation :Number =
            ROTATE_MIN + ((time / Constants.GAME_TIME) * (ROTATE_MAX - ROTATE_MIN));
        _pointer.rotation = rotation;
    }

    protected var _sprite :Sprite;
    protected var _meter :MovieClip;
    protected var _pointer :MovieClip;

    protected static const ROTATE_MIN :Number = 0;
    protected static const ROTATE_MAX :Number = 60;
}

}
