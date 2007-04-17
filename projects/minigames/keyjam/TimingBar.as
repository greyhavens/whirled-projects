package {

import flash.display.DisplayObject;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.TimerEvent;

import flash.utils.getTimer; // function import
import flash.utils.Timer;

public class TimingBar extends Sprite
{
    public function TimingBar (width :int, height :int, msPerBeat :Number)
    {
        _width = width;
        _pixelsPerMs = _width / msPerBeat;

//        // draw the bar
//        with (graphics) {
//            // the background
//            beginFill(0);
//            drawRect(0, 0, width, height);
//            endFill();
//
//            // the border
//            lineStyle(2, 0xFFFFFF);
//            drawRect(0, 0, width, height);
//
//            // the red zones!
//            lineStyle(0, 0, 0);
//
//            var target :Number = TARGET_AREA;
//            for (var ww :int = 8; ww >= 1; ww--) {
//                beginFill((0xFF / ww) << 16); // redness
//                var extent :Number = ww * 3;
//                drawRect(target - extent/2, 0, extent, height);
//                endFill();
//            }
//        }

        addNewNeedle();
        addEventListener(Event.ENTER_FRAME, repositionNeedle);
    }

    public function reset () :void
    {
        // set up a starting needle position
        _needle.x = 0;
        _needle.y = 5;
        _origStamp = getTimer();
    }

    protected function addNewNeedle () :void
    {
        // create the needle
        _needle = (new NEEDLE() as DisplayObject);
        addChild(_needle);
        
        reset();
    }

    /**
     * Check the needle's closeness to the target area.
     * Calling this method has the side-effect of creating a visual
     * representation of where the needle stopped.
     *
     * @return an array- index 0: The closeness, returned as a value from 0 - 1.
     *                   index 1: The number of times the needle has wrapped around.
     */
    public function checkNeedle () :Array
    {
        repositionNeedle(); // one last update

        if (_oldNeedle != null) {
            removeChild(_oldNeedle);
        }
        _oldNeedle = _needle;
        _oldNeedle.alpha = .55;
        _needle = null;

        var returnValue :Array = [
            1 - (Math.abs(TARGET_AREA - _oldNeedle.x) / TARGET_AREA),
            _wraps ];

        addNewNeedle();

        return returnValue;
    }

    /**
     * Repositon the needle, given the current timestmap.
     * This should always be done before querying the needle accuracy.
     */
    protected function repositionNeedle (event :Object = null) :void
    {
        var curStamp :Number = getTimer();
        // always compare to the original for max accuracy
        var elapsed :Number = curStamp - _origStamp;
        var pixels :Number = (_pixelsPerMs * elapsed);

        _wraps = int(pixels / _width);
        _needle.x = pixels % _width;
    }

    protected var _width :Number;

    protected var _pixelsPerMs :Number;

    protected var _wraps :int = 0;

    protected var _needle :DisplayObject;

    protected var _oldNeedle :DisplayObject;

    protected var _origStamp :Number;

    protected static const TARGET_AREA :Number = 167;

    [Embed(source="resources.swf#needle")]
    protected static const NEEDLE :Class;
}
}
