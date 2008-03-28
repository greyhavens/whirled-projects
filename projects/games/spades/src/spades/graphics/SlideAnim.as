package spades.graphics {

import flash.display.DisplayObject;
import com.threerings.flash.Animation;
import com.threerings.flash.AnimationManager;
import com.threerings.flash.Vector2;

/** Move a display object from its current position to a new position over a period of time. */
public class SlideAnim implements Animation
{
    /** Create a new slide animation. 
     *  @param sprite the object to slide. Its current position is the starting position.
     *  @param dest the coordinate of the final destination
     *  @param milliseconds the time span over which to do the move
     *  @param callback optional function to call when the animation is complete
     */
    public function SlideAnim (
        sprite :DisplayObject,
        dest :Vector2,
        milliseconds :Number,
        callback :Function = null)
    {
        _sprite = sprite;
        _start = new Vector2(sprite.x, sprite.y);
        _dest = dest.clone();
        _milliseconds = milliseconds;
        _callback = callback;
    }

    public function updateAnimation (elapsed :Number) :void
    {
        var fraction :Number = elapsed / _milliseconds;

        if (fraction >= 1.0) {
            finish(true);
            return;
        }

        var interp :Vector2 = Vector2.interpolate(_start, _dest, fraction);
        _sprite.x = interp.x;
        _sprite.y = interp.y;
    }

    public function finish (moveToDest :Boolean) :void
    {
        AnimationManager.stop(this);

        if (moveToDest) {
            _sprite.x = _dest.x;
            _sprite.y = _dest.y;
        }

        if (_callback != null) {
            _callback();
        }
    }

    /** Access the display object that is the target of this animation. */
    public function get sprite () :DisplayObject
    {
        return _sprite;
    }

    protected var _sprite :DisplayObject;
    protected var _start :Vector2;
    protected var _dest :Vector2;
    protected var _milliseconds :Number;
    protected var _callback :Function;
}

}
