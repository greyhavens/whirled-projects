package {

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;

import flash.events.Event;

import com.threerings.util.Log;
import com.threerings.util.EmbeddedSwfLoader;

import com.whirled.FurniControl;
import com.whirled.ControlEvent;

[SWF(width="400", height="400")]
public class Fan extends Sprite
{
    public function Fan ()
    {
        var loader :EmbeddedSwfLoader = new EmbeddedSwfLoader();
        loader.addEventListener(Event.COMPLETE, loaded);
        loader.load(new CLIP());
    }

    protected function loaded (evt :Event) :void
    {
        _clip = MovieClip(EmbeddedSwfLoader(evt.target).getContent());
        this.addChild(_clip);
        _clip.stop();

        _control = new FurniControl(this);
        if (_control.isConnected()) {
            _listener = new EntityStateListener(_control, "circuit01");
            _listener.addEventListener(EntityStateEvent.STATE_CHANGED, setCircuitState);
        }
    }

    protected function setCircuitState (event :EntityStateEvent) :void
    {
        if (event.value) {
            _clip.play();
        } else {
            _clip.stop();
        }
    }

    protected var _control :FurniControl;
    protected var _listener :EntityStateListener;
    protected var _clip :MovieClip;

    [Embed(source="fan_clip.swf", mimeType="application/octet-stream")]
        protected static const CLIP :Class;
}
}
