//
// $Id$

package dictattack {

import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.ByteArray;

import com.threerings.util.EmbeddedSwfLoader;

/**
 * Displays the splash screen.
 */
public class SplashView extends Sprite
{
    public function SplashView (onClear :Function)
    {
        _onClear = onClear;

        // nothing is ever simple in Flash
        _loader = new EmbeddedSwfLoader();
        _loader.addEventListener(Event.COMPLETE, splashLoaded);
        _loader.load(ByteArray(new SPLASH()));
    }

    protected function splashLoaded (event :Event) :void
    {
        _clip = (_loader.getContent() as MovieClip);
        _clip.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        stage.addEventListener(MouseEvent.CLICK, onClick);
        addChild(_clip);
    }

    protected function onEnterFrame (event :Event) :void
    {
        if (_clip.currentFrame < _lastFrame) {
            onClick(null); // we've looped, eject!
        } else {
            _lastFrame = _clip.currentFrame;
        }
    }

    protected function onClick (event :MouseEvent) :void
    {
        trace("Click " + event);
        _clip.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        stage.removeEventListener(MouseEvent.CLICK, onClick);
        _onClear();
    }

    protected static function dump (object :Object, indent :String) :void
    {
        trace("D: " + indent + object);
        if (object is DisplayObjectContainer) {
            var doc :DisplayObjectContainer = (object as DisplayObjectContainer);
            for (var ii :int = 0; ii < doc.numChildren; ii++) {
                dump(doc.getChildAt(ii), indent + " ");
            }
        }
    }

    protected var _onClear :Function;
    protected var _loader :EmbeddedSwfLoader;
    protected var _clip :MovieClip;
    protected var _lastFrame :int;

    [Embed(source="../../rsrc/splash.swf", mimeType="application/octet-stream")]
    protected var SPLASH :Class;
}
}
