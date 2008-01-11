package ghostbusters.fight.ouija {

import com.whirled.contrib.core.objects.SceneObject;
import flash.display.MovieClip;
import flash.display.DisplayObject;
import com.whirled.contrib.core.tasks.RepeatingTask;
import com.whirled.contrib.core.tasks.TimedTask;
import com.whirled.contrib.core.tasks.FunctionTask;

import flash.display.Scene;
import flash.display.Loader;
import mx.core.MovieClipLoaderAsset;
import flash.geom.Point;

public class BoardTimer extends SceneObject
{
    public function BoardTimer (totalTime :Number)
    {
        _totalTime = totalTime;

        _swf = new SWF_TIMER();
        _swf.mouseEnabled = false;
        _swf.x = TIMER_LOC.x;
        _swf.y = TIMER_LOC.y;
    }

    override protected function update (dt :Number) :void
    {
        // @TODO - fix this mess
        if (!_inited) {
            var swf :MovieClip = (((_swf.getChildAt(0) as Loader).content) as MovieClip);

            if (null != swf) {
                swf = (swf.getChildAt(0) as MovieClip);
                swf.gotoAndStop(0);

                this.addTask(new RepeatingTask(
                    new TimedTask(_totalTime / swf.totalFrames),
                    new FunctionTask(
                        function () :void {
                            swf.nextFrame(); }
                    )));

                _inited = true;
           }
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _swf;
    }

    protected var _swf :MovieClipLoaderAsset;
    protected var _totalTime :Number;
    protected var _inited :Boolean;

    protected static const TIMER_LOC :Point = new Point(125, 180);

    [Embed(source="../../../../rsrc/Ouija_timer_10f.swf")]
    protected static const SWF_TIMER :Class;

}

}
