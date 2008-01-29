package ghostbusters.fight.ouija {

import com.whirled.contrib.core.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.geom.Point;

import mx.core.MovieClipLoaderAsset;

public class BoardTimer extends SceneObject
{
    public function BoardTimer (totalTime :Number)
    {
        _totalTime = totalTime;

        _swf = new Content.SWF_TIMER();
        _swf.mouseEnabled = false;
        _swf.mouseChildren = false;
        _swf.x = TIMER_LOC.x;
        _swf.y = TIMER_LOC.y;
    }

    override protected function update (dt :Number) :void
    {
       _elapsedTime += dt;
       
        // @TODO - fix this mess
        var swf :MovieClip = (((_swf.getChildAt(0) as Loader).content) as MovieClip);
        if (null != swf) {
             swf = (swf.getChildAt(0) as MovieClip);
            
            var curFrame :Number = Math.floor((_elapsedTime / _totalTime) * Number(swf.totalFrames));
            curFrame = Math.min(curFrame, swf.totalFrames - 1);
            
            swf.gotoAndStop(curFrame);
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _swf;
    }

    protected var _swf :MovieClipLoaderAsset;
    protected var _totalTime :Number;
    protected var _elapsedTime :Number = 0;

    protected static const TIMER_LOC :Point = new Point(140, 174);

}

}
