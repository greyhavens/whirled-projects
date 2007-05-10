//
// $Id$

package com.threerings.betthefarm {

import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.Sprite;

import flash.events.Event;

import flash.utils.getTimer;

/**
 * Displays a progress bar. TODO: Not quite sure how to do this yet.
 */
public class ProgressBar extends Sprite
{
    public function ProgressBar (duration :uint)
    {
        super();

        _startTime = getTimer();
        _endTime = _startTime + duration * 1000;

        addEventListener(Event.ENTER_FRAME, updateBar);

        _bgBar = new Content.IMG_PROGRESS_BAR_BACKGROUND();
        addChild(_bgBar);

        _fgBar = new Content.IMG_PROGRESS_BAR_FOREGROUND();
        addChild(_fgBar);

        _mask = new Shape();
        _mask.graphics.beginFill(0xffffff);
        _mask.graphics.drawRect(0, 0, 1, _fgBar.height);
        addChild(_mask);
        _fgBar.mask = _mask;
    }

    public function shutdown () :void
    {
        removeEventListener(Event.ENTER_FRAME, updateBar);
    }

    protected function updateBar (event :Event) :void
    {
        var now :uint = getTimer();
        if (now <= _endTime) {
            _mask.width = _fgBar.width * (now - _startTime) / (_endTime - _startTime);
        }
    }

    protected var _startTime :uint;
    protected var _endTime :uint;
    protected var _mask :Shape;
    protected var _bgBar :DisplayObject;
    protected var _fgBar :DisplayObject;
}
}
