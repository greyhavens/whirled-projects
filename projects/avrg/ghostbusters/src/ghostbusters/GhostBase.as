//
// $Id$

package ghostbusters {

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.utils.ByteArray;

import flash.events.Event;

import flash.geom.Rectangle;

import com.threerings.util.EmbeddedSwfLoader;

import ghostbusters.ClipHandler;
import ghostbusters.Content;

public class GhostBase extends Sprite
{
    public function GhostBase ()
    {
        var loader :EmbeddedSwfLoader = new EmbeddedSwfLoader();
        loader.addEventListener(Event.COMPLETE, handleGhostLoaded);
        loader.load(ByteArray(new Content.GHOST()));
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
        _clip.gotoAndStop(1, STATE_WALKING);
        this.addChild(_clip);
        _bounds = _clip.getBounds(this);

        // register the sprite
        _clip.x = - (_bounds.left + _bounds.width/2);
        _clip.y = - _bounds.top;

        // refigure the bounds
        _bounds = _clip.getBounds(this);

        _handler = new ClipHandler(_clip);

        Game.log.debug("Ghost finished loading [bounds=" + _bounds + "]");

        // and let subclassers know we're done
        mediaReady();
    }

    protected var _bounds :Rectangle;

    protected var _clip :MovieClip;
    protected var _handler :ClipHandler;

    protected static const STATE_WALKING :String = "state_Default_walking";
    protected static const STATE_APPEAR :String = "state_Appear";
    protected static const STATE_FIGHT :String = "state_Fightstance";
}
}
