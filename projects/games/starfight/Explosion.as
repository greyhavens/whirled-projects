package {

import flash.display.MovieClip;
import flash.display.Sprite;

import flash.events.Event;

public class Explosion extends Sprite
{
    public function Explosion (x :int, y :int, rot :int, isSmall :Boolean,
        shipType :int, parent :BoardSprite)
    {
        _parent = parent;
        _isSmall = isSmall;

        if (isSmall) {
            _explodeMovie = MovieClip(new (Resources.getClass("small_explosion"))());
        } else {
            _explodeMovie =
                MovieClip(new Codes.SHIP_TYPES[shipType].explodeAnim());
            _explodeMovie.scaleX = Codes.SHIP_TYPES[shipType].size + 0.1;
            _explodeMovie.scaleY = Codes.SHIP_TYPES[shipType].size + 0.1;
            _explodeMovie.x = _explodeMovie.width/2;
            _explodeMovie.y = -_explodeMovie.height/2;
        }
        _explodeMovie.rotation = 90;
        _explodeMovie.addEventListener(Event.COMPLETE, endExplode);
        _explodeMovie.gotoAndPlay(1);

        // Just like we have a ship to contain our ship movie...
        addChild(_explodeMovie);
        this.x = x;
        this.y = y;
        this.rotation = rot;
    }

    public function endExplode (event :Event) :void
    {
        _explodeMovie.removeEventListener(Event.COMPLETE, endExplode);
        parent.removeChild(this);
    }

    protected var _parent :BoardSprite;

    protected var _explodeMovie :MovieClip;

    protected var _frameCount :int = 0;

    protected var _isSmall :Boolean;

    /** Why do we freaking need this crap??? No way to tell when we finish. */
    protected static const EXPLODE_FRAMES :int = 30;
    protected static const SM_EXPLODE_FRAMES :int = 6;
}
}
