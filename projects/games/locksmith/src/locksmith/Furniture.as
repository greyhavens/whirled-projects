//
// $Id$

package locksmith {

import flash.display.Sprite;

import flash.events.Event;

[SWF(width="340", height="340")]
public class Furniture extends Sprite
{
    public function Furniture ()
    {
        // all our symbols are centered on (0, 0) for code simplicity - we need to move the whole
        // sprite so thats its properly positioned.
        x = 170;
        y = 170;

        addChild(_clock = new CLOCK() as Sprite);

        updateHands();

        addEventListener(Event.ENTER_FRAME, updateHands);
        addEventListener(Event.UNLOAD, function (event :Event) :void {
            removeEventListener(Event.ENTER_FRAME, updateHands);
        });
    }
    
    protected function updateHands (...ignored) :void
    {
        var date :Date = new Date();
        _clock["hand_hour"].rotation = (date.hours % 12) * 30 + date.minutes / 2;
        _clock["hand_minute"].rotation = date.minutes * 6;
    }

    [Embed(source="../../rsrc/furniture.swf#clock")]
    protected static const CLOCK :Class;

    protected var _clock :Sprite;
}
}
