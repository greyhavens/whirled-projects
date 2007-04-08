package {

import flash.display.Bitmap;
import flash.display.Sprite;

import flash.events.TimerEvent;

import com.whirled.PetControl;

/**
 * An extremely simple pet that moves randomly around the room.
 */
[SWF(width="83", height="47")]
public class Roomba extends Sprite
{
    public function Roomba ()
    {
        addChild(Bitmap(new ROOMBA()));
        scaleX = .25;
        scaleY = .25;

        _ctrl = new PetControl(this);
        _ctrl.addEventListener(TimerEvent.TIMER, tick);
        _ctrl.setTickInterval(3000);
    }

    protected function tick (event :TimerEvent) :void
    {
        _ctrl.setLocation(Math.random(), 0, Math.random(), Math.random());
    }

    protected var _ctrl :PetControl;

    [Embed(source="roomba.png")]
    protected static const ROOMBA :Class;
}
}
