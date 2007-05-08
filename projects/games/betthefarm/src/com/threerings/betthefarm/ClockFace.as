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

        _startTime = getTimer();
        _endTime = _startTime + duration * 1000;

        setInterval(updateClock, 100);

        addChild(new Content.IMG_TIMER_FACE());

        _hand = new Content.IMG_TIMER_HAND();
        addChild(_hand);
    }

    protected function updateClock () :void
    {
        var now :uint = getTimer();
        if (now < _endTime) {
            _hand.rotation = (360 * (now - _startTime)) / (_endTime - _startTime);
        }
    }

    protected var _startTime :uint;
    protected var _endTime :uint;
    protected var _hand :DisplayObject;
}
}
