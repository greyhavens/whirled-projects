//
// $Id$

package locksmith {

import flash.display.Sprite;

import flash.events.Event;
import flash.events.TimerEvent;

import flash.utils.Timer;

import com.threerings.util.Log;

import com.whirled.contrib.EventHandlers;

public class Clock extends Sprite
{
    public function Clock (outOfTime :Function)
    {
        addChild(_minute = new MINUTE() as Sprite);
        addChild(_hour = new HOUR() as Sprite);

        _ringIndicator = new SELECTOR() as Sprite;
        _outOfTime = outOfTime;
        _inTurn = false;

        _secondTimer = new Timer(1000);
        EventHandlers.registerListener(_secondTimer, TimerEvent.TIMER, updateTime);
        _secondTimer.start();

        EventHandlers.registerListener(this, Event.ENTER_FRAME, fastRotation);
    }

    public function turnOver () :void
    {
        _inTurn = false;
        _fastRotation = true;
        _fastRotationFrame = (360 - ((_hour.rotation + 360) % 360)) / 90;
    }

    public function newTurn () :void
    {
        _inTurn = true;
        _fastRotation = false;
        _hour.rotation = 0;
    }

    public function setRingIndicator (ringNum :int) :void
    {
        if (ringNum < 0) {
            if (_ringIndicator.parent == _minute) {
                _minute.removeChild(_ringIndicator);
            }
            return;
        }

        if (_ringIndicator.parent != _minute) { 
            _minute.addChild(_ringIndicator);
        }
        _ringIndicator.y = -(ringNum + 0.5) * Ring.SIZE_PER_RING;
    }

    public function setRotationAngle (angle :Number, finished :Boolean = false) :void
    {
        if (finished) {
            _minute.rotation = 0;
        } else {
            _minute.rotation = (angle * 4 + 360) % 360;
        }
    }

    public function reinit () :void
    {
        _minute.rotation = 0;
        _hour.rotation = 0;
        _inTurn = false;
    }

    protected function updateTime (...ignored) :void
    {
        if (_inTurn) {
            _hour.rotation += 6;
            _inTurn = _hour.rotation != 0;
            if (!_inTurn) {
                _outOfTime();
            }
        }
    }

    protected function fastRotation (...ignored) :void
    {
        if (_fastRotation) {
            if (_hour.rotation < 0 && _hour.rotation + _fastRotationFrame >= 0) {
                _fastRotation = false;
                _hour.rotation = 0;
            } else {
                _hour.rotation += _fastRotationFrame;
            }
        }
    }

    private static const log :Log = Log.getLog(Clock);

    [Embed(source="../../rsrc/locksmith_art.swf#hand_minute")]
    protected static const MINUTE :Class;
    [Embed(source="../../rsrc/locksmith_art.swf#hand_hour")]
    protected static const HOUR :Class;
    [Embed(source="../../rsrc/locksmith_art.swf#selector")]
    protected static const SELECTOR :Class;

    protected var _minute :Sprite;
    protected var _hour :Sprite;
    protected var _ringIndicator :Sprite;

    protected var _secondTimer :Timer;
    
    protected var _outOfTime :Function;
    protected var _inTurn :Boolean;
    protected var _fastRotation :Boolean;
    protected var _fastRotationFrame :Number;
}
}
