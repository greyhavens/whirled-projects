//
// $Id$

package {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.utils.getTimer;

/**
 * Zooms something in from a tiny scale to normal scale.
 */
public class Popper
{
    /**
     * Creates a popper that will pop from the supplied starting scale to the supplied ending scale
     * in the specified number of milliseconds.
     */
    public function Popper (target :DisplayObject, from :Number, to :Number, duration :int,
                            removeOnComplete :Boolean = false)
    {
        _from = from;
        _to = to;
        _duration = duration;
        _removeOnComplete = removeOnComplete;

        _startStamp = getTimer();
        _target = target;
        _naturalX = _target.x;
        _naturalY = _target.y;
        _naturalWidth = _target.width;
        _naturalHeight = _target.height;
        _naturalScaleX = _target.scaleX;
        _naturalScaleY = _target.scaleY;
        _target.addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    /**
     * Cancels the popping, and sets the targets scale immediately to the end scale.
     */
    public function stop () :void
    {
        if (_target != null) {
            _target.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            if (_removeOnComplete) {
                _target.parent.removeChild(_target);
            } else {
                _target.x = _naturalX;
                _target.y = _naturalY;
                _target.scaleX = _naturalScaleX * _to;
                _target.scaleY = _naturalScaleY * _to;
            }
            _target = null;
        }
    }

    protected function onEnterFrame (event :Event) :void
    {
        var elapsed :int = getTimer() - _startStamp;
        if (elapsed > _duration) {
            stop();
            return;
        }

        var scale :Number = _from + (_to - _from) * elapsed / _duration;
        _target.scaleX = _naturalScaleX * scale;
        _target.scaleY = _naturalScaleY * scale;
        _target.x = _naturalX + (_naturalWidth - _target.width)/2;
        _target.y = _naturalY + (_naturalHeight - _target.height)/2;
    }

    protected var _target :DisplayObject;
    protected var _from :Number, _to :Number;
    protected var _duration :int, _startStamp :int;
    protected var _removeOnComplete :Boolean;

    protected var _naturalX :Number, _naturalY :Number;
    protected var _naturalScaleX :Number, _naturalScaleY :Number;
    protected var _naturalWidth :Number, _naturalHeight :Number;
}
}
