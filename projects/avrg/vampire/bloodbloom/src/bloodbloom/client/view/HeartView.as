package bloodbloom.client.view {

import bloodbloom.client.*;

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;

import mx.effects.easing.*;

public class HeartView extends SceneObject
{
    public function HeartView (heartMovie :MovieClip)
    {
        _movie = heartMovie;
        _movie.gotoAndStop(1);
        registerListener(GameCtx.heart, GameEvent.HEARTBEAT,
            function (...ignored) :void {
                _showHeartbeat = true;
            });
    }

    override protected function update (dt :Number) :void
    {
        if (_showHeartbeat) {
            _movie.gotoAndPlay(1);
            _showHeartbeat = false;
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    protected var _movie :MovieClip;
    protected var _showHeartbeat :Boolean;

    protected static const SCALE_BIG :Number = 1.3;
    protected static const SCALE_SMALL :Number = 1;
}

}
