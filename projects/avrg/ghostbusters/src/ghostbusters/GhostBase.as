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
    public var handler :ClipHandler;
    public var clip :MovieClip;

    public function GhostBase ()
    {
        handler = new ClipHandler(new Content.GHOST(), setupUI);
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
        clip = ghost;
        clip.gotoAndStop(1, STATE_HIDDEN);
        this.addChild(clip);
        _bounds = clip.getBounds(this);

        // register the sprite
        clip.x = - (_bounds.left + _bounds.width/2);
        clip.y = - _bounds.top;

        // refigure the bounds
        _bounds = clip.getBounds(this);

        Game.log.debug("Ghost finished loading [bounds=" + _bounds + "]");

        // and let subclassers know we're done
        mediaReady();
    }

    protected var _bounds :Rectangle;

    protected static const STATE_HIDDEN :String = "hidden";
    protected static const STATE_APPEAR :String = "appear_to_fighting";
    protected static const STATE_FIGHT :String = "fighting";
    protected static const STATE_REEL :String = "reel";
    protected static const STATE_RETALIATE :String = "retaliate";
    protected static const STATE_DEFEAT :String = "defeat_disappear";
    protected static const STATE_TRIUMPH :String = "triumph_chase";
}
}
