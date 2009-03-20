package vampire.feeding.client {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.SwfResource;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.geom.Point;

import vampire.feeding.*;

public class BonusSentIndicator extends SceneObject
{
    public function BonusSentIndicator (loc :Vector2)
    {
        _loc = loc;
        _movie = ClientCtx.instantiateMovieClip("blood", "sent_panel", true, true);
        this.x = _loc.x;
        this.y = _loc.y;
    }

    public function animate () :void
    {
        if (!_showing) {
            _showing = true;
            addTask(LocationTask.CreateSmooth(_loc.x + SHOW_OFFSET.x, _loc.y + SHOW_OFFSET.y, 0.5));
        }

        // If the indicator is already showing, don't reshow it - just extend the amount of
        // time it remains on the screen
        addNamedTask("Hide",
            new SerialTask(
                new TimedTask(1.5),
                LocationTask.CreateSmooth(_loc.x, _loc.y, 0.5),
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

    protected var _loc :Vector2;

    protected static const SHOW_OFFSET :Vector2 = new Vector2(0, -30);
}

}
