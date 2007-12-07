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
        var sprite :MovieClip = MovieClip(EmbeddedSwfLoader(evt.target).getContent());
        sprite.gotoAndPlay(1, "state_Default_walking"); // standardize
        addChild(sprite);
        _bounds = sprite.getBounds(this);

        // dangle the sprite from its head
        sprite.x = - (_bounds.left + _bounds.width/2);
        sprite.y = - _bounds.top;

        // refigure the bounds
        _bounds = sprite.getBounds(this);

        // and let subclassers know we're done
        mediaReady();
    }

    protected var _bounds :Rectangle;


    [Embed(source="../../rsrc/Ghost.swf", mimeType="application/octet-stream")]
    protected static const GHOST :Class;
}
}
