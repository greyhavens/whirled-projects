// $Id$

package {

import flash.display.Sprite;
import flash.display.DisplayObject;

import flash.events.TimerEvent;

import flash.utils.Timer;

public class Clock extends Sprite
{
    public function Clock ()
    {
        addChild(_minute = new MINUTE() as DisplayObject);
        addChild(_hour = new HOUR() as DisplayObject);

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

    protected function updateTime (...ignored) :void
    {
        var now :Date = new Date();
        _minute.rotation = 6 * now.minutes;
        _hour.rotation = 30 * (now.hours % 12);
    }

    [Embed(source="../rsrc/locksmith_art.swf#hand_minute")]
    protected static const MINUTE :Class;
    [Embed(source="../rsrc/locksmith_art.swf#hand_hour")]
    protected static const HOUR :Class;

    protected var _minute :DisplayObject;
    protected var _hour :DisplayObject;

    protected var _timer :Timer;
}
}
