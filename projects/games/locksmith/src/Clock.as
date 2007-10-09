// $Id$

package {

import flash.display.Sprite;

import flash.events.TimerEvent;

import flash.utils.Timer;

public class Clock extends Sprite
{
    public function Clock (outOfTime :Function)
    {
        addChild(_minute = new MINUTE() as Sprite);
        addChild(_hour = new HOUR() as Sprite);

        _ringIndicator = new SELECTOR() as Sprite;
        _outOfTime = outOfTime;
        _inTurn = false;

        _timer = new Timer(1000);
        Locksmith.registerEventListener(_timer, TimerEvent.TIMER, updateTime);
        _timer.start();
    }

    public function turnOver () :void
    {
        _inTurn = false;
        _hour.rotation = 0;
    }

    public function newTurn () :void
    {
        _inTurn = true;
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

    protected function updateTime (...ignored) :void
    {
        if (_inTurn && (_hour.rotation += 6) == 0) {
            _outOfTime();
            _inTurn = false;
            _hour.rotation = 0;
        }
    }

    [Embed(source="../rsrc/locksmith_art.swf#hand_minute")]
    protected static const MINUTE :Class;
    [Embed(source="../rsrc/locksmith_art.swf#hand_hour")]
    protected static const HOUR :Class;
    [Embed(source="../rsrc/locksmith_art.swf#selector")]
    protected static const SELECTOR :Class;

    protected var _minute :Sprite;
    protected var _hour :Sprite;
    protected var _ringIndicator :Sprite;

    protected var _timer :Timer;
    
    protected var _outOfTime :Function;
    protected var _inTurn :Boolean;
}
}
