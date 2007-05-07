//
// $Id$

package com.threerings.betthefarm {

import flash.display.DisplayObject;
import flash.display.Sprite;

import flash.utils.getTimer;
import flash.utils.setInterval;


/**
 * Displays a little hand moving across a clock face.
 */
public class ClockFace extends Sprite
{
    public function ClockFace (duration :uint)
    {
        super();

        _startTime = getTimer()/1000;
        _endTime = _startTime + duration;

        setInterval(updateClock, 100);

        addChild(new Content.IMG_TIMER_FACE());

        _hand = new Content.IMG_TIMER_HAND();
        addChild(_hand);
    }

    protected function updateClock () :void
    {
        var now :uint = getTimer() / 1000;
        if (now < _endTime) {
            _hand.rotation = uint(360 * (now - _startTime) / _endTime);
        }
    }

    protected var _startTime :uint;
    protected var _endTime :uint;
    protected var _hand :DisplayObject;
}
}
