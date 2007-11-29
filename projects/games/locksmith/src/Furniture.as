// $Id$

package {

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

        addChild(new CLOCKFACE() as Sprite);

        addChild(_hourHand = new HAND_HOUR() as Sprite);
        addChild(_minuteHand = new HAND_MINUTE() as Sprite);
        updateHands();

        addEventListener(Event.ENTER_FRAME, updateHands);
        addEventListener(Event.UNLOAD, function (event :Event) :void {
            removeEventListener(Event.ENTER_FRAME, updateHands);
        });
    }
    
    protected function updateHands (...ignored) :void
    {
        var date :Date = new Date();
        _hourHand.rotation = (date.hours % 12) * 30 + date.minutes / 2;
        _minuteHand.rotation = date.minutes * 6;
    }

    [Embed(source="../rsrc/furniture.swf#furni_clockface")]
    protected static const CLOCKFACE :Class;
    [Embed(source="../rsrc/furniture.swf#hand_hour")]
    protected static const HAND_HOUR :Class;
    [Embed(source="../rsrc/furniture.swf#hand_minute")]
    protected static const HAND_MINUTE :Class;

    protected var _hourHand :Sprite;
    protected var _minuteHand :Sprite;
}
}
