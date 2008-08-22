package {

import flash.display.Bitmap;
import flash.display.Sprite;

import flash.events.TimerEvent;

import com.whirled.ControlEvent;
import com.whirled.PetControl;

/**
 * An experiment in building a chatterbot.
 */
[SWF(width="150", height="400")]
public class Freud extends Sprite
{
    public function Freud ()
    {
        _image = Bitmap(new PICTURE());
        addChild(_image);

        scaleX = scaleY = 0.5
        
        _ctrl = new PetControl(this);
        _ctrl.addEventListener(ControlEvent.RECEIVED_CHAT, gotChat);
        _ctrl.setTickInterval(1000);

        _matcher = new PatternMatcher();
    }

    protected function gotChat (msg :ControlEvent) :void
    {
        if ((msg.value as String) != _lastUtterance) {
            var response :String = _matcher.findResponse(msg.name as String, msg.value as String);
            if (response != null) {
                speak(response);
            }
        }
    }

    protected function speak (text :String) :void
    {
        _lastUtterance = text;
        _ctrl.sendChat(text);
    }
    
    protected var _ctrl :PetControl;
    protected var _image :Bitmap;

    protected var _lastUtterance :String;

    protected var _matcher :PatternMatcher;

    [Embed(source="freud.jpg")]
    protected static const PICTURE :Class;
}
}
