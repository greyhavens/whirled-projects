package vampire.feeding.client {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.SwfResource;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;

import mx.effects.easing.Cubic;
import mx.effects.easing.Linear;

import vampire.feeding.*;

public class NewBonusAnimation extends SceneObject
{
    public static const TYPE_SEND :int = 0;
    public static const TYPE_RECEIVE :int = 1;

    public function NewBonusAnimation (type :int, multiplier :int, loc :Vector2,
        onComplete :Function = null)
    {
        _sprite = Cell.createCellSprite(Constants.CELL_MULTIPLIER, multiplier);
        _movie = MovieClip(_sprite.getChildAt(0));
        _movie.gotoAndStop(1);

        var finalTask :SerialTask;

        if (type == TYPE_SEND) {
            this.x = loc.x;
            this.y = loc.y;
            this.scaleX = this.scaleY = SCALE_UP;

            // Fly off screen
            addTask(new SerialTask(
                new TimedTask(0.75),
                new AdvancedLocationTask(
                    SEND_LOC.x,
                    SEND_LOC.y,
                    0.75,
                    mx.effects.easing.Linear.easeNone,
                    mx.effects.easing.Cubic.easeIn)));

            // Shrink and fade
            finalTask = new SerialTask(
                new TimedTask(1),
                new ParallelTask(
                    new ScaleTask(SCALE_DOWN, SCALE_DOWN, 0.5),
                    new AlphaTask(0, 0.5)),
                new SelfDestructTask());

            if (onComplete != null) {
                finalTask.addTask(new FunctionTask(onComplete));
            }

            addTask(finalTask);

        } else {
            this.x = RECEIVE_LOC.x;
            this.y = RECEIVE_LOC.y;
            this.scaleX = this.scaleY = SCALE_DOWN;
            this.alpha = 0;

            // Scale up, fade in, and fly on screen
            addTask(new ParallelTask(
                new ScaleTask(SCALE_UP, SCALE_UP, 0.5),
                new AlphaTask(1, 0.5),
                new AdvancedLocationTask(
                    loc.x, loc.y,
                    1.2,
                    mx.effects.easing.Linear.easeNone,
                    mx.effects.easing.Cubic.easeIn)));

            // scale down at the last second, and land on the screen
            finalTask = new SerialTask(
                new TimedTask(0.7),
                new ScaleTask(SCALE_DOWN, SCALE_DOWN, 0.5),
                new SelfDestructTask());

            if (onComplete != null) {
                finalTask.addTask(new FunctionTask(onComplete));
            }

            addTask(finalTask);
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function destroyed () :void
    {
        SwfResource.releaseMovieClip(_movie);
        super.destroyed();
    }

    protected var _movie :MovieClip;
    protected var _sprite :Sprite;

    protected static const SEND_LOC :Vector2 = new Vector2(500, 300);
    protected static const RECEIVE_LOC :Vector2 = new Vector2(500, 100);

    protected static const SCALE_UP :Number = 2;
    protected static const SCALE_DOWN :Number = 1;
}

}
