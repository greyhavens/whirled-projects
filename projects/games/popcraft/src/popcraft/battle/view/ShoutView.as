package popcraft.battle.view {

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.SwfResource;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;

import popcraft.*;

public class ShoutView extends SceneObject
{
    public function ShoutView ()
    {
        _movie = SwfResource.instantiateMovieClip("workshop", "bubble", true, true);
        showShout(-1);
    }

    override protected function destroyed () :void
    {
        SwfResource.releaseMovieClip(_movie);
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    public function showShout (val :int) :void
    {
        if (val == _shoutType && val >= 0 && val < Constants.SHOUT__LIMIT) {
            if (_emphasis == MAX_EMPHASIS) {
                return;
            }
            _emphasis += 1;

        } else {
            _shoutType = val;
            _emphasis = 0;
        }

        resetDisplay();
    }

    protected function resetDisplay () :void
    {
        this.visible = false;
        removeAllTasks();

        if (_shoutType >= 0) {
            _movie.gotoAndStop((_shoutType * 3) + _emphasis + 1);

            var targetScale :Number = (_emphasis == 0 ? 0.8 : 1 + (_emphasis * 0.4));
            var startScale :Number = targetScale * 0.5;
            var targetOvershoot :Number = targetScale * 1.2;

            // display, then fade out
            this.alpha = 1;
            this.visible = true;
            this.scaleX = startScale;
            this.scaleY = startScale;
            addTask(new SerialTask(
                ScaleTask.CreateEaseIn(targetOvershoot, targetOvershoot, 0.1),
                ScaleTask.CreateEaseOut(targetScale, targetScale, 0.2),
                new TimedTask(SCREEN_TIME),
                new AlphaTask(0, FADE_TIME),
                new FunctionTask(
                    function () :void {
                        showShout(-1);
                    })));
        }
    }

    protected var _movie :MovieClip;
    protected var _shoutType :int = -1;
    protected var _emphasis :int;

    protected static const MAX_EMPHASIS :int = 2;

    protected static const SCREEN_TIME :Number = 2;
    protected static const FADE_TIME :Number = 0.25;
}

}
