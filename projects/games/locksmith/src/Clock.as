// $Id$

package {

import flash.display.Sprite;

import flash.events.TimerEvent;

import flash.utils.Timer;

public class Clock extends Sprite
{
    public function Clock ()
    {
        addChild(_minute = new MINUTE() as Sprite);
        addChild(_hour = new HOUR() as Sprite);

        _ringIndicator = new SELECTOR() as Sprite;

        updateTime();

        // Update the time as soon as we switch to a new minute, then do it every 60 seconds from
        // then on.
        _timer = new Timer((60 - (new Date()).seconds + 1) * 1000, 1);
        var tempTimer :Function 
        tempTimer = function (...ignored) :void {
            updateTime();
            Locksmith.unregisterEventListener(_timer, TimerEvent.TIMER, tempTimer);
            _timer = new Timer(60 * 1000);
            Locksmith.registerEventListener(_timer, TimerEvent.TIMER, updateTime);
            _timer.start();
        }
        Locksmith.registerEventListener(_timer, TimerEvent.TIMER, tempTimer);
        _timer.start();
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
        var now :Date = new Date();
        _hour.rotation = 30 * (now.hours % 12);
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
}
}
