package bloodbloom.client.view {

import bloodbloom.client.*;

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;

import mx.effects.easing.*;

public class HeartView extends SceneObject
{
    public function HeartView (heartMovie :MovieClip)
    {
        _movie = heartMovie;
    }

    override protected function update (dt :Number) :void
    {
        // the heart scales with the game beat
        // get a value between -1 and 1
        // [-1, 0] -> heart is shrinking
        // [0, 1] -> heart is growing
        var beatPhase :Number = (GameCtx.heart.pctTimeToNextBeat - 0.5) * 2;
        var easeFn :Function =
            (beatPhase < 0 ? mx.effects.easing.Cubic.easeIn : mx.effects.easing.Cubic.easeOut);

        var t :Number = Math.abs(beatPhase);
        t = Math.max(0, t);
        t = Math.min(1, t);
        var scale :Number = easeFn(
            t,                          // time
            SCALE_SMALL,                // initial value
            (SCALE_BIG - SCALE_SMALL),  // total change
            1);                         // duration

        this.scaleX = scale;
        this.scaleY = scale;
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    protected var _movie :MovieClip;

    protected static const SCALE_BIG :Number = 1.3;
    protected static const SCALE_SMALL :Number = 1;
}

}
