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
import ghostbusters.Codes;
import ghostbusters.Content;

public class GhostBase extends Sprite
{
    public var handler :ClipHandler;

    public function GhostBase ()
    {
        handler = new ClipHandler(new Content.GHOST_NOBLE_LADY(), setupUI);
        this.addChild(handler);
    }

    public function getGhostBounds () :Rectangle
    {
        return _bounds;
    }

    protected function mediaReady () :void
    {
    }

    protected function setupUI (ghost :MovieClip) :void
    {
        ghost.gotoAndStop(1, Codes.ST_GHOST_HIDDEN);
        _bounds = ghost.getBounds(this);

        // register the sprite
        ghost.x = - (_bounds.left + _bounds.width/2);
        ghost.y = - _bounds.top;

        // refigure the bounds
        _bounds = ghost.getBounds(this);

        Game.log.debug("Ghost finished loading [bounds=" + _bounds + "]");

        // and let subclassers know we're done
        mediaReady();
    }

    protected var _bounds :Rectangle;
}
}
