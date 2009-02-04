package bloodbloom.client {

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;

import mx.effects.easing.*;

public class Heart extends SceneObject
{
    public function Heart ()
    {
        _sprite = new Sprite();

        var heart :Bitmap = ClientCtx.instantiateBitmap("heart");
        heart.x = -heart.width * 0.5;
        heart.y = -heart.height * 0.5;
        _sprite.addChild(heart);
    }

    override protected function update (dt :Number) :void
    {
        // the heart scales with the game beat
        // get a value between -1 and 1
        // [-1, 0] -> heart is shrinking
        // [0, 1] -> heart is growing
        var beatPhase :Number = (ClientCtx.beat.pctTimeToNextBeat - 0.5) * 2;
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
        return _sprite;
    }

    protected var _sprite :Sprite;

    protected static const SCALE_BIG :Number = 1.3;
    protected static const SCALE_SMALL :Number = 1;
}

}
