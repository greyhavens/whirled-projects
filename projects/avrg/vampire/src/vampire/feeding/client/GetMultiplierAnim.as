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

public class GetMultiplierAnim extends SceneObject
{
    public function GetMultiplierAnim (multiplier :int, loc :Vector2, onComplete :Function = null)
    {
        _sprite = Cell.createCellSprite(Constants.CELL_MULTIPLIER, multiplier, true);
        _movie = MovieClip(_sprite.getChildAt(0));
        _movie.gotoAndStop(1);

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
        var finalTask :SerialTask = new SerialTask(
            new TimedTask(0.7),
            new ScaleTask(SCALE_DOWN, SCALE_DOWN, 0.5),
            new SelfDestructTask());

        if (onComplete != null) {
            finalTask.addTask(new FunctionTask(onComplete));
        }

        addTask(finalTask);
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

    protected static const RECEIVE_LOC :Vector2 = new Vector2(510, 350);

    protected static const SCALE_UP :Number = 2;
    protected static const SCALE_DOWN :Number = 1;
}

}
