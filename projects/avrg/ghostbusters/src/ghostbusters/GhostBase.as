//
// $Id$

package ghostbusters {

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.utils.ByteArray;

import flash.events.Event;

import flash.geom.Rectangle;

import com.threerings.util.EmbeddedSwfLoader;

public class GhostBase extends Sprite
{
    public function GhostBase ()
    {
        var loader :EmbeddedSwfLoader = new EmbeddedSwfLoader();
        loader.addEventListener(Event.COMPLETE, handleGhostLoaded);
        loader.load(ByteArray(new GHOST()));
    }

    public function getGhostBounds () :Rectangle
    {
        return _bounds;
    }

    protected function mediaReady () :void
    {
    }

    protected function handleGhostLoaded (evt :Event) :void
    {
        _clip = MovieClip(EmbeddedSwfLoader(evt.target).getContent());
        _clip.gotoAndPlay(1, STATE_WALKING); // standardize
        addChild(_clip);
        _bounds = _clip.getBounds(this);

        // dangle the sprite from its head
        _clip.x = - (_bounds.left + _bounds.width/2);
        _clip.y = - _bounds.top;

        // refigure the bounds
        _bounds = _clip.getBounds(this);

        // and let subclassers know we're done
        mediaReady();
    }

    protected var _bounds :Rectangle;

    protected var _clip :MovieClip;

    protected static const STATE_WALKING :String = "state_Default_walking";
    protected static const STATE_APPEAR :String = "state_Appear";

    [Embed(source="../../rsrc/Ghost.swf", mimeType="application/octet-stream")]
    protected static const GHOST :Class;
}
}
