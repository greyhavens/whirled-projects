//
// $Id$

package dictattack {

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.ByteArray;

import com.threerings.util.MultiLoader;

/**
 * Displays the splash screen.
 */
public class SplashView extends Sprite
{
    public function SplashView (parent :Sprite, onClear :Function)
    {
        _onClear = onClear;
        _parent = parent;
        _parent.addEventListener(MouseEvent.CLICK, onClick);
        MultiLoader.getContents(SPLASH, addSplash);
    }

    protected function addSplash (splash :MovieClip) :void
    {
        _clip = splash;
        _clip.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        addChild(_clip);
    }

    protected function onEnterFrame (event :Event) :void
    {
        if (_clip.currentFrame >= _clip.totalFrames) {
            onClick(null);
        }
    }

    protected function onClick (event :MouseEvent) :void
    {
        if (_clip != null) {
            _clip.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        _parent.removeEventListener(MouseEvent.CLICK, onClick);
        _onClear();
    }

    protected var _parent :Sprite;
    protected var _onClear :Function;
    protected var _clip :MovieClip;

    [Embed(source="../../rsrc/splash.swf", mimeType="application/octet-stream")]
    protected var SPLASH :Class;
}
}
