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

        var face :DisplayObject = new Content.IMG_TIMER_FACE();
        face.x = -face.width/2;
        face.y = -face.height/2;
        addChild(face);

        _hand = new Content.SWF_TIMER_HAND();
        _hand.rotation = 180;
        addChild(_hand);
    }

    protected function updateClock () :void
    {
        var now :uint = getTimer();
        if (now < _endTime) {
            _hand.rotation = 180 + (360 * (now - _startTime)) / (_endTime - _startTime);
        }
    }

    protected var _startTime :uint;
    protected var _endTime :uint;
    protected var _hand :DisplayObject;
}
}
