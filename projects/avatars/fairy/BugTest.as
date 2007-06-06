package {

import flash.display.Sprite;

import flash.events.Event;
import flash.events.TimerEvent;

import flash.utils.Timer;

[SWF(width="100", height="100")]
public class BugTest extends Sprite
{
    public function BugTest ()
    {
        _host = new Sprite();
        _host.addChild(new Bugger("first"));
        _host.addChild(new Bugger("second"));

        var t :Timer = new Timer(1000, 1);
        t.addEventListener(TimerEvent.TIMER, handleTimer);
        t.start();
    }

    protected function handleTimer (evt :Event) :void
    {
        addChild(_host);
    }

    protected var _host :Sprite;
}
}

import flash.display.Sprite;

import flash.events.Event;

class Bugger extends Sprite
{
    public function Bugger (id :String)
    {
        _id = id;
        addEventListener(Event.ADDED_TO_STAGE, handleAdded);
        addEventListener(Event.REMOVED_FROM_STAGE, handleRemoved);
    }

    protected function handleAdded (evt :Event) :void
    {
        trace("Added '" + _id + "'");

        if (parent) {
            parent.removeChild(this);
        }
    }

    protected function handleRemoved (evt :Event) :void
    {
        trace("Removed '" + _id + "'");
    }

    protected var _id :String;
}
