package vampire.feeding.client {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;

import mx.effects.easing.Cubic;
import mx.effects.easing.Linear;

import vampire.feeding.*;

public class SendMultiplierAnim extends SceneObject
{
    public function SendMultiplierAnim (multiplier :int, loc :Vector2)
    {
        _movie = ClientCtx.instantiateMovieClip("blood", "cell_coop_create");

        this.x = loc.x;
        this.y = loc.y;
        this.scaleX = this.scaleY = SCALE_UP;

        // Fly off screen, shrink, and fade
        addTask(new SerialTask(
            new WaitForFrameTask(54),
            new FunctionTask(function () :void {
                _movie.addChild(Cell.createMultiplierText(multiplier, 15, 15));
            }),
            new TimedTask(0.5),
            new ParallelTask(
                new FunctionTask(GameCtx.bonusSentIndicator.animate),
                new AdvancedLocationTask(
                    SEND_LOC.x,
                    SEND_LOC.y,
                    0.75,
                    mx.effects.easing.Linear.easeNone,
                    mx.effects.easing.Cubic.easeIn),
                new SerialTask(
                    new TimedTask(0.5),
                    new ScaleTask(SCALE_DOWN, SCALE_DOWN, 0.25))),
            new SelfDestructTask()));
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    protected var _movie :MovieClip;

    protected static const SEND_LOC :Vector2 = new Vector2(506, 69);

    protected static const SCALE_UP :Number = 2;
    protected static const SCALE_DOWN :Number = 1;
}

}
