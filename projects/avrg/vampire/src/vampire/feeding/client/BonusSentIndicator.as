package vampire.feeding.client {
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.SwfResource;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.geom.Point;

import vampire.feeding.*;

public class BonusSentIndicator extends SceneObject
{
    public function BonusSentIndicator ()
    {
        _movie = ClientCtx.instantiateMovieClip("blood", "sent_panel", true, true);
        _movie.x = HIDE_LOC.x;
        _movie.y = HIDE_LOC.y;
    }

    public function animate () :void
    {
        if (!_showing) {
            _showing = true;
            addTask(LocationTask.CreateSmooth(SHOW_LOC.x, SHOW_LOC.y, 0.5));
        }

        // If the indicator is already showing, don't reshow it - just extend the amount of
        // time it remains on the screen
        addNamedTask("Hide",
            new SerialTask(
                new TimedTask(1.5),
                LocationTask.CreateSmooth(HIDE_LOC.x, HIDE_LOC.x, 0.5),
                new FunctionTask(function () :void {
                    _showing = false;
                })),
            true);
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    override protected function destroyed () :void
    {
        SwfResource.releaseMovieClip(_movie);
        super.destroyed();
    }

    protected var _movie :MovieClip;
    protected var _showing :Boolean;

    protected static const HIDE_LOC :Point = new Point(267, 276);
    protected static const SHOW_LOC :Point = new Point(267, 246);
}

}
