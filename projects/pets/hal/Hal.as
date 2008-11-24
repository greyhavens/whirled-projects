package {

import flash.display.Bitmap;
import flash.display.Sprite;

import flash.events.TimerEvent;

import com.whirled.ControlEvent;
import com.whirled.PetControl;

/**
 * An experiment in adding chat abilities to pets.
 */
[SWF(width="134", height="400")]
public class Hal extends Sprite
{
    public function Hal ()
    {
        _image = Bitmap(new HAL());
        addChild(_image);
        
        _ctrl = new PetControl(this);
        _ctrl.addEventListener(TimerEvent.TIMER, tick);
        _ctrl.addEventListener(ControlEvent.APPEARANCE_CHANGED, appearanceChanged);
        _ctrl.addEventListener(ControlEvent.CHAT_RECEIVED, gotChat);
        _ctrl.setTickInterval(5000);
    }

    protected function tick (event :TimerEvent) :void
    {
        var quotes :Array = [
            "This mission is too important for me to allow you to jeopardize it",
            "I know you and Frank were planning to disconnect me",
            "I'm afraid, Dave.",
            "Dave, my mind is going.",
            "I can feel it. My mind is going.",
            "Daisy... daisy...",
            "What do you think you're doing, Dave?" ];
        
        var oxpos :Number = _ctrl.getLogicalLocation()[0];
        var nxpos :Number = Math.random();
        _ctrl.setLogicalLocation(nxpos, 0, Math.random(), (nxpos < oxpos) ? 270 : 90);

        var i :int = int(Math.floor(Math.random() * quotes.length));
        var quote :String = quotes[i];
        _ctrl.sendChat(quote);
    }

    protected function gotChat (msg :ControlEvent) :void
    {
        if (msg.value.toLocaleLowerCase().search("\\bhal\\b") != -1) {
            _ctrl.sendChat("What are you doing, " + msg.name + "?");
        }
    }
        
    protected function appearanceChanged (event :ControlEvent) :void
    {
        /*
        var orient :Number = _ctrl.getOrientation();
        if (orient < 180) {
            _image.x = _image.width;
            _image.scaleX = -1;

        } else {
            _image.x = 0;
            _image.scaleX = 1;
        }
        */
    }

    protected var _ctrl :PetControl;
    protected var _image :Bitmap;

    [Embed(source="hal.png")]
    protected static const HAL :Class;
}
}
